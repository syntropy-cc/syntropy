-- Roles padrão
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'supabase_admin') THEN
    CREATE ROLE supabase_admin;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'authenticator') THEN
    CREATE ROLE authenticator LOGIN PASSWORD :'ZeZE9n0atfssZsje';
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'service_role') THEN
    CREATE ROLE service_role LOGIN PASSWORD :'ZeZE9n0atfssZsje';
  END IF;
END $$;

GRANT supabase_admin TO postgres;
GRANT authenticator TO supabase_admin;
GRANT service_role TO supabase_admin;

-- Schema padrão e extensão pgcrypto p/ uuid_generate_v4()
CREATE EXTENSION IF NOT EXISTS "pgcrypto" WITH SCHEMA public;

-- Schema auth (GoTrue migra se não existir)
CREATE SCHEMA IF NOT EXISTS auth;
COMMENT ON SCHEMA auth IS 'Supabase auth schema';
