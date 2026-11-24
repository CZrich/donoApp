DO $migration$
BEGIN
  IF to_regclass('public.sessions') IS NULL THEN
    CREATE TABLE sessions (
      id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
      account_id uuid NOT NULL REFERENCES accounts(id) ON DELETE CASCADE,
      refresh_token_hash text NOT NULL UNIQUE,
      expires_at timestamptz NOT NULL,
      created_at timestamptz NOT NULL DEFAULT now()
    );

    CREATE INDEX sessions_account_idx ON sessions(account_id);
    CREATE INDEX sessions_expires_idx ON sessions(expires_at);
  END IF;
END
$migration$;
