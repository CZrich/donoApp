DO $migration$
BEGIN
  IF to_regclass('public.accounts') IS NULL THEN
    CREATE TABLE accounts (
      id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
      email text NOT NULL UNIQUE CHECK (btrim(email) <> ''),
      password_hash text NOT NULL,
      created_at timestamptz NOT NULL DEFAULT now(),
      updated_at timestamptz NOT NULL DEFAULT now()
    );

    INSERT INTO accounts (id, email, password_hash, created_at, updated_at)
    SELECT id, email, password_hash, created_at, updated_at
    FROM profiles;

    ALTER TABLE profiles
      ALTER COLUMN role DROP NOT NULL,
      ALTER COLUMN display_name DROP NOT NULL,
      ALTER COLUMN phone DROP NOT NULL;

    ALTER TABLE profiles
      ADD CONSTRAINT profiles_account_fk
      FOREIGN KEY (id) REFERENCES accounts(id) ON DELETE CASCADE;
  END IF;
END
$migration$;
