// hooks/use-auth.ts
"use client";
import { useSupabase } from "@/app/providers";
import { debug } from "@/lib/debug";

export function useAuth() {
  debug("useAuth: hook inicializado");
  const { session, supabase, isEnabled } = useSupabase();
  debug("useAuth: session atual:", session, "isEnabled:", isEnabled);
  
  return {
    user: session?.user ?? null,
    isConfigured: isEnabled && !!session,
    isEnabled, // Indica se o sistema de auth está habilitado
    signOut: () => {
      if (!isEnabled) {
        debug("useAuth: signOut ignorado (Supabase desabilitado)");
        return Promise.resolve({ error: null });
      }
      debug("useAuth: signOut chamado");
      return supabase.auth.signOut();
    },
    session,
    supabase,
  };
}