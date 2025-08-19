// hooks/use-auth.ts
"use client";
import { useSupabase } from "@/app/providers";
import { debug } from "@/lib/debug";

export function useAuth() {
  debug("useAuth: hook inicializado");
  const { session, supabase } = useSupabase();
  debug("useAuth: session atual:", session);
  return {
    user: session?.user ?? null,
    isConfigured: !!session,
    signOut: () => {
      debug("useAuth: signOut chamado");
      return supabase.auth.signOut();
    },
    session,
    supabase,
  };
}