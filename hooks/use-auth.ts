// hooks/use-auth.ts
"use client";
import { useSession, useSupabaseClient } from "@supabase/auth-helpers-react";

export function useAuth() {
  const { session } = useSession();
  const supabase = useSupabaseClient();
  return {
    user: session?.user ?? null,
    isConfigured: !!session,
    signOut: () => supabase.auth.signOut(),
  };
}