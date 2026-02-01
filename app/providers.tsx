// app/providers.tsx
"use client";
import React, { createContext, useContext } from "react";
import { useState, useEffect } from "react";
import { useRouter } from "next/navigation";
import { createBrowserClient } from "@supabase/ssr";
import { debug } from "@/lib/debug";
import { isSupabaseEnabled } from "@/lib/feature-flags";

interface SupabaseContextType {
  supabase: ReturnType<typeof createBrowserClient> | null;
  session: any;
  setSession: React.Dispatch<React.SetStateAction<any>>;
  isEnabled: boolean;
}

const SupabaseContext = createContext<SupabaseContextType | undefined>(undefined);

/**
 * Mock do cliente Supabase para quando está desabilitado.
 * Retorna métodos que não fazem nada, evitando erros em componentes.
 */
const createMockSupabaseClient = () => ({
  auth: {
    getSession: async () => ({ data: { session: null }, error: null }),
    getUser: async () => ({ data: { user: null }, error: null }),
    signOut: async () => ({ error: null }),
    signInWithOAuth: async () => ({ data: null, error: null }),
    onAuthStateChange: () => ({
      data: {
        subscription: {
          unsubscribe: () => {},
        },
      },
    }),
  },
});

export function SupabaseProvider({ children, initialSession }: { children: React.ReactNode; initialSession: any }) {
  const router = useRouter();
  const enabled = isSupabaseEnabled();
  
  const [supabase] = useState(() => {
    // Se Supabase está desabilitado, retorna mock
    if (!enabled) {
      debug("SupabaseProvider: Supabase DESABILITADO (feature flag), usando mock");
      return createMockSupabaseClient() as any;
    }
    
    debug("SupabaseProvider: inicializando supabase client");
    return createBrowserClient(
      process.env.NEXT_PUBLIC_SUPABASE_URL!,
      process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!,
    );
  });
  
  // Se desabilitado, session é sempre null
  const [session, setSession] = useState(enabled ? initialSession : null);

  useEffect(() => {
    // Se Supabase está desabilitado, não faz nada
    if (!enabled) {
      debug("SupabaseProvider: Supabase desabilitado, pulando subscription");
      return;
    }
    
    debug("SupabaseProvider: useEffect montado, subscrevendo onAuthStateChange");
    const { data: subscription } = supabase.auth.onAuthStateChange((event: any, session: any) => {
      debug("SupabaseProvider: onAuthStateChange", event, session);
      setSession(session);
      router.refresh();
      debug("SupabaseProvider: router.refresh chamado após mudança de sessão");
    });
    return () => {
      debug("SupabaseProvider: limpando subscription onAuthStateChange");
      subscription.subscription.unsubscribe();
    };
  }, [supabase, router, enabled]);

  return (
    <SupabaseContext.Provider value={{ supabase, session, setSession, isEnabled: enabled }}>
      {children}
    </SupabaseContext.Provider>
  );
}

export function useSupabase() {
  const ctx = useContext(SupabaseContext);
  if (!ctx) throw new Error("useSupabase deve ser usado dentro de SupabaseProvider");
  return ctx;
}

export default SupabaseProvider;
