CREATE EXTENSION IF NOT EXISTS pgcrypto;

CREATE TYPE user_role AS ENUM ('donor', 'organization');
CREATE TYPE donation_category AS ENUM (
  'fruits_vegetables', 'grains', 'bakery', 'dairy', 'prepared_food',
  'canned_packaged', 'other'
);
CREATE TYPE quantity_unit AS ENUM ('kg', 'units', 'liters', 'portions');
CREATE TYPE donation_status AS ENUM (
  'available', 'reserved', 'delivered', 'cancelled', 'expired'
);
CREATE TYPE reservation_status AS ENUM ('active', 'cancelled', 'completed');

CREATE TABLE profiles (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  email text NOT NULL UNIQUE CHECK (btrim(email) <> ''),
  password_hash text NOT NULL,
  role user_role NOT NULL,
  display_name text NOT NULL CHECK (btrim(display_name) <> ''),
  phone text NOT NULL CHECK (btrim(phone) <> ''),
  avatar_path text,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE organizations (
  profile_id uuid PRIMARY KEY REFERENCES profiles(id) ON DELETE RESTRICT,
  organization_name text NOT NULL CHECK (btrim(organization_name) <> ''),
  organization_type text NOT NULL CHECK (btrim(organization_type) <> ''),
  responsible_name text NOT NULL CHECK (btrim(responsible_name) <> ''),
  district text NOT NULL CHECK (btrim(district) <> ''),
  address text NOT NULL CHECK (btrim(address) <> ''),
  description text NOT NULL CHECK (btrim(description) <> '')
);

CREATE TABLE donations (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  donor_id uuid NOT NULL REFERENCES profiles(id) ON DELETE RESTRICT,
  title text NOT NULL CHECK (btrim(title) <> ''),
  description text NOT NULL CHECK (btrim(description) <> ''),
  category donation_category NOT NULL,
  quantity numeric(12,2) NOT NULL CHECK (quantity > 0),
  unit quantity_unit NOT NULL,
  image_path text,
  district text NOT NULL CHECK (btrim(district) <> ''),
  pickup_address text NOT NULL CHECK (btrim(pickup_address) <> ''),
  pickup_notes text,
  pickup_deadline timestamptz NOT NULL,
  status donation_status NOT NULL DEFAULT 'available',
  delivered_at timestamptz,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE reservations (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  donation_id uuid NOT NULL REFERENCES donations(id) ON DELETE RESTRICT,
  organization_id uuid NOT NULL REFERENCES organizations(profile_id) ON DELETE RESTRICT,
  status reservation_status NOT NULL DEFAULT 'active',
  reserved_at timestamptz NOT NULL DEFAULT now(),
  cancelled_at timestamptz,
  completed_at timestamptz
);

CREATE UNIQUE INDEX one_active_reservation_per_donation
  ON reservations(donation_id) WHERE status = 'active';
CREATE INDEX donations_available_idx
  ON donations(created_at DESC) WHERE status = 'available';
