

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;


COMMENT ON SCHEMA "public" IS 'standard public schema';



CREATE EXTENSION IF NOT EXISTS "pg_graphql" WITH SCHEMA "graphql";






CREATE EXTENSION IF NOT EXISTS "pg_stat_statements" WITH SCHEMA "extensions";






CREATE EXTENSION IF NOT EXISTS "pgcrypto" WITH SCHEMA "extensions";






CREATE EXTENSION IF NOT EXISTS "supabase_vault" WITH SCHEMA "vault";






CREATE EXTENSION IF NOT EXISTS "unaccent" WITH SCHEMA "extensions";






CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA "extensions";






CREATE TYPE "public"."course_level" AS ENUM (
    'iniciante',
    'intermediario',
    'avançado'
);


ALTER TYPE "public"."course_level" OWNER TO "postgres";


CREATE TYPE "public"."user_role" AS ENUM (
    'common_user',
    'mentor',
    'admin'
);


ALTER TYPE "public"."user_role" OWNER TO "postgres";


CREATE TYPE "public"."visibility_enum" AS ENUM (
    'public',
    'private',
    'internal'
);


ALTER TYPE "public"."visibility_enum" OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."enforce_created_by_immutable"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
BEGIN
  IF NEW.created_by <> OLD.created_by THEN
    RAISE EXCEPTION 'created_by is immutable';
  END IF;
  RETURN NEW;
END;
$$;


ALTER FUNCTION "public"."enforce_created_by_immutable"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."ensure_unique_slug"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
DECLARE
  base_slug TEXT;
  final_slug TEXT;
  counter INTEGER := 1;
BEGIN
  -- Generate base slug from name
  base_slug := generate_slug(NEW.name);
  final_slug := base_slug;
  
  -- Check if slug exists and increment counter if needed
  WHILE EXISTS (SELECT 1 FROM public.projects WHERE slug = final_slug AND id != COALESCE(NEW.id, '00000000-0000-0000-0000-000000000000')) LOOP
    final_slug := base_slug || '-' || counter;
    counter := counter + 1;
  END LOOP;
  
  NEW.slug := final_slug;
  RETURN NEW;
EXCEPTION
  WHEN unique_violation THEN
    -- Handle race condition by retrying with incremented counter
    final_slug := base_slug || '-' || extract(epoch from now())::bigint;
    NEW.slug := final_slug;
    RETURN NEW;
END;
$$;


ALTER FUNCTION "public"."ensure_unique_slug"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."generate_learning_path_slug"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    SET "search_path" TO 'public'
    AS $$
BEGIN
  NEW.slug := CONCAT(generate_slug(NEW.title), '-', SUBSTRING(NEW.id::text, 1, 8));
  RETURN NEW;
END;
$$;


ALTER FUNCTION "public"."generate_learning_path_slug"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."generate_slug"("input_text" "text") RETURNS "text"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public', 'extensions'
    AS $$
BEGIN
  RETURN lower(
    regexp_replace(
      regexp_replace(
        trim(extensions.unaccent(input_text)),
        '[^a-zA-Z0-9\s-]', '', 'g'
      ),
      '\s+', '-', 'g'
    )
  );
END;
$$;


ALTER FUNCTION "public"."generate_slug"("input_text" "text") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_user_role"("user_id" "uuid") RETURNS "public"."user_role"
    LANGUAGE "plpgsql" STABLE SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
BEGIN
  RETURN (
    SELECT role FROM public.profiles 
    WHERE id = user_id
  );
END;
$$;


ALTER FUNCTION "public"."get_user_role"("user_id" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."handle_new_user"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
DECLARE
  new_portfolio_id UUID;
  generated_username TEXT;
  username_counter INTEGER := 1;
  base_username TEXT;
BEGIN
  -- Cria o portfólio
  INSERT INTO public.portfolios (title, description)
  VALUES ('Meu Portfólio', 'Portfólio criado automaticamente')
  RETURNING id INTO new_portfolio_id;

  -- Determina o username base
  -- Se tem email, usa a parte antes do @
  -- Senão, usa dados do OAuth ou gera um padrão
  IF NEW.email IS NOT NULL AND NEW.email != '' THEN
    base_username := lower(split_part(NEW.email, '@', 1));
  ELSIF NEW.raw_user_meta_data->>'preferred_username' IS NOT NULL THEN
    base_username := lower(NEW.raw_user_meta_data->>'preferred_username');
  ELSIF NEW.raw_user_meta_data->>'user_name' IS NOT NULL THEN
    base_username := lower(NEW.raw_user_meta_data->>'user_name');
  ELSE
    base_username := 'user_' || substring(NEW.id::text, 1, 8);
  END IF;

  -- Remove caracteres especiais e espaços
  base_username := regexp_replace(base_username, '[^a-z0-9_]', '', 'g');
  
  -- Garante que não seja vazio
  IF base_username = '' OR base_username IS NULL THEN
    base_username := 'user_' || substring(NEW.id::text, 1, 8);
  END IF;

  generated_username := base_username;

  -- Se o username já existe, adiciona um número sequencial
  WHILE EXISTS (SELECT 1 FROM public.profiles WHERE username = generated_username) LOOP
    generated_username := base_username || '_' || username_counter;
    username_counter := username_counter + 1;
  END LOOP;

  -- Cria o perfil
  INSERT INTO public.profiles (
    id, 
    role, 
    username, 
    full_name, 
    email, 
    avatar_url, 
    portfolio_id,
    is_active,
    created_at, 
    updated_at
  ) VALUES (
    NEW.id,
    'common_user',
    generated_username,
    COALESCE(
      NEW.raw_user_meta_data->>'full_name', 
      NEW.raw_user_meta_data->>'name',
      generated_username
    ),
    NEW.email,
    NEW.raw_user_meta_data->>'avatar_url',
    new_portfolio_id,
    TRUE,
    now(),
    now()
  );

  RETURN NEW;
END;
$$;


ALTER FUNCTION "public"."handle_new_user"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."is_admin"("user_id" "uuid") RETURNS boolean
    LANGUAGE "plpgsql" STABLE SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
BEGIN
  RETURN EXISTS (
    SELECT 1 FROM public.profiles 
    WHERE id = user_id AND role = 'admin'
  );
END;
$$;


ALTER FUNCTION "public"."is_admin"("user_id" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."set_updated_at"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$;


ALTER FUNCTION "public"."set_updated_at"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."update_updated_at_column"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    SET "search_path" TO 'public'
    AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$;


ALTER FUNCTION "public"."update_updated_at_column"() OWNER TO "postgres";




ALTER PUBLICATION "supabase_realtime" OWNER TO "postgres";


GRANT USAGE ON SCHEMA "public" TO "postgres";
GRANT USAGE ON SCHEMA "public" TO "anon";
GRANT USAGE ON SCHEMA "public" TO "authenticated";
GRANT USAGE ON SCHEMA "public" TO "service_role";





































































































































































GRANT ALL ON FUNCTION "public"."enforce_created_by_immutable"() TO "anon";
GRANT ALL ON FUNCTION "public"."enforce_created_by_immutable"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."enforce_created_by_immutable"() TO "service_role";



GRANT ALL ON FUNCTION "public"."ensure_unique_slug"() TO "anon";
GRANT ALL ON FUNCTION "public"."ensure_unique_slug"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."ensure_unique_slug"() TO "service_role";



GRANT ALL ON FUNCTION "public"."generate_learning_path_slug"() TO "anon";
GRANT ALL ON FUNCTION "public"."generate_learning_path_slug"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."generate_learning_path_slug"() TO "service_role";



GRANT ALL ON FUNCTION "public"."generate_slug"("input_text" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."generate_slug"("input_text" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."generate_slug"("input_text" "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."get_user_role"("user_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."get_user_role"("user_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_user_role"("user_id" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."handle_new_user"() TO "anon";
GRANT ALL ON FUNCTION "public"."handle_new_user"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."handle_new_user"() TO "service_role";



GRANT ALL ON FUNCTION "public"."is_admin"("user_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."is_admin"("user_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."is_admin"("user_id" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."set_updated_at"() TO "anon";
GRANT ALL ON FUNCTION "public"."set_updated_at"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."set_updated_at"() TO "service_role";



GRANT ALL ON FUNCTION "public"."update_updated_at_column"() TO "anon";
GRANT ALL ON FUNCTION "public"."update_updated_at_column"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."update_updated_at_column"() TO "service_role";
























ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES TO "service_role";






ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS TO "service_role";






ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES TO "service_role";






























RESET ALL;
