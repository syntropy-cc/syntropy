// app/providers.tsx
"use client";
import React, { createContext, useContext } from "react";
import { useState, useEffect } from "react";
import { useRouter } from "next/navigation";
import { createBrowserClient } from "@supabase/ssr";
import { debug } from "@/lib/debug";

interface SupabaseContextType {
  supabase: ReturnType<typeof createBrowserClient>;
  session: any;
  setSession: React.Dispatch<React.SetStateAction<any>>;
}

const SupabaseContext = createContext<SupabaseContextType | undefined>(undefined);

export function SupabaseProvider({ children, initialSession }: { children: React.ReactNode; initialSession: any }) {
  const router = useRouter();
  const [supabase] = useState(() => {
    debug("SupabaseProvider: inicializando supabase client");
    return createBrowserClient(
      process.env.NEXT_PUBLIC_SUPABASE_URL!,
      process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!,
    );
  });
  const [session, setSession] = useState(initialSession);

  useEffect(() => {
    debug("SupabaseProvider: useEffect montado, subscrevendo onAuthStateChange");
    const { data: subscription } = supabase.auth.onAuthStateChange((event, session) => {
      debug("SupabaseProvider: onAuthStateChange", event, session);
      setSession(session);
      router.refresh();
      debug("SupabaseProvider: router.refresh chamado após mudança de sessão");
    });
    return () => {
      debug("SupabaseProvider: limpando subscription onAuthStateChange");
      subscription.subscription.unsubscribe();
    };
  }, [supabase, router]);

  return (
    <SupabaseContext.Provider value={{ supabase, session, setSession }}>
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
