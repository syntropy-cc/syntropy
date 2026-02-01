// app/layout.tsx (Server Component)
import { cookies } from "next/headers";
import { createServerClient } from "@supabase/ssr";
import Providers from "./providers";
import { Navbar } from "@/components/syntropy/Navbar";
import { Footer } from "@/components/syntropy/Footer";
import { QueryProvider } from "@/lib/query-provider";
import { isSupabaseEnabled } from "@/lib/feature-flags";
// import { debug } from "@/lib/debug"; // opcional
import "./globals.css";

// Evita SSG nessas rotas (precisamos ler cookies/sessão a cada request)
export const dynamic = "force-dynamic";

export default async function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  let session = null;
  
  // Só conecta ao Supabase se estiver habilitado
  if (isSupabaseEnabled()) {
    // 1) Padrão correto para Server Components com auth-helpers-nextjs
    const cookieStore = cookies();
    const supabase = createServerClient(
      process.env.NEXT_PUBLIC_SUPABASE_URL!,
      process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!,
      {
        cookies: {
          getAll: cookieStore.getAll.bind(cookieStore),
        },
      }
    );

    const { data } = await supabase.auth.getSession();
    session = data.session;
  }
  // Quando desabilitado, session permanece null e nenhuma conexão é feita

  // 2) Se quiser logar, faça FORA do JSX:
  // debug("[SSR] session:", session);

  return (
    <html lang="pt-BR" className="dark">
      <body className="bg-slate-900">
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