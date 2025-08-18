// hooks/use-auth.ts
"use client";
import { useSession, useSupabaseClient } from "@supabase/auth-helpers-react";
import { debug } from "@/lib/debug";

export function useAuth() {
  debug("useAuth: hook inicializado");
  const { session } = useSession();
  debug("useAuth: session atual:", session);
  const supabase = useSupabaseClient();
  return {
    user: session?.user ?? null,
    isConfigured: !!session,
    signOut: () => {
      debug("useAuth: signOut chamado");
      return supabase.auth.signOut();
    },
  };
}