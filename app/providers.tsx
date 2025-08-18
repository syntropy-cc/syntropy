// app/providers.tsx
"use client";
import { useState, useEffect } from "react";
import { useRouter } from "next/navigation";
import { createBrowserClient } from "@supabase/auth-helpers-nextjs";
import { SessionContextProvider, type Session } from "@supabase/auth-helpers-react";

export default function Providers({
  children,
  initialSession,
}: {
  children: React.ReactNode;
  initialSession: Session | null;
}) {
  const router = useRouter();
  const [supabase] = useState(() =>
    createBrowserClient(
      process.env.NEXT_PUBLIC_SUPABASE_URL!,
      process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!,
    )
  );

  // reidrata a UI quando a sessão muda
  useEffect(() => {
    const { data: subscription } = supabase.auth.onAuthStateChange(() => {
      router.refresh();
    });
    return () => subscription.subscription.unsubscribe();
  }, [supabase, router]);

  return (
    <SessionContextProvider supabaseClient={supabase} initialSession={initialSession}>
      {children}
    </SessionContextProvider>
  );
}
