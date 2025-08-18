// app/layout.tsx (server component)
import { cookies } from "next/headers";
import { createServerClient } from "@supabase/auth-helpers-nextjs";
import Providers from "./providers";
import { Navbar } from "@/components/syntropy/Navbar";
import { Footer } from "@/components/syntropy/Footer";
import { QueryProvider } from "@/lib/query-provider";
import { debug } from "@/lib/debug";

export default async function RootLayout({ children }: { children: React.ReactNode }) {
  const supabase = createServerClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!,
    { cookies }
  );
  debug("[SSR] RootLayout iniciado");
  const {
    data: { session },
  } = await supabase.auth.getSession();
  debug("[SSR] getSession retornou:", session);

  return (
    <html lang="pt-BR" className="dark">
      <body className="bg-slate-900">
        {/* Loga a sessão passada ao Provider */}
        {debug("[SSR] session passada ao Provider:", session)}
        <Providers initialSession={session}>
          <QueryProvider>
            <div className="min-h-screen flex flex-col bg-slate-900">
              <Navbar />
              <main className="flex-1">{children}</main>
              <Footer />
            </div>
          </QueryProvider>
        </Providers>
      </body>
    </html>
  );
}
