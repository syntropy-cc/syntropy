// app/providers.tsx
"use client";
import { useState, useEffect } from "react";
import { useRouter } from "next/navigation";
import { createBrowserClient } from "@supabase/ssr";
import { SessionContextProvider, type Session } from "@supabase/auth-helpers-react";
import { debug } from "@/lib/debug";

export default function Providers({
  children,
  initialSession,
}: {
  children: React.ReactNode;
  initialSession: Session | null;
}) {
  const router = useRouter();
  const [supabase] = useState(() => {
    debug("Providers: inicializando supabase client");
    return createBrowserClient(
      process.env.NEXT_PUBLIC_SUPABASE_URL!,
      process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!,
    );
  });

  // reidrata a UI quando a sessão muda
  useEffect(() => {
    debug("Providers: useEffect montado, subscrevendo onAuthStateChange");
    const { data: subscription } = supabase.auth.onAuthStateChange((event, session) => {
      debug("Providers: onAuthStateChange", event, session);
      router.refresh();
      debug("Providers: router.refresh chamado após mudança de sessão");
    });
    return () => {
      debug("Providers: limpando subscription onAuthStateChange");
      subscription.subscription.unsubscribe();
    };
  }, [supabase, router]);

  return (
    <SessionContextProvider supabaseClient={supabase} initialSession={initialSession}>
      {children}
    </SessionContextProvider>
  );
}
