// app/layout.tsx (Server Component)
import { cookies } from "next/headers";
import { createServerComponentClient } from "@supabase/auth-helpers-nextjs";
import Providers from "./providers";
import { Navbar } from "@/components/syntropy/Navbar";
import { Footer } from "@/components/syntropy/Footer";
import { QueryProvider } from "@/lib/query-provider";
// import { debug } from "@/lib/debug"; // opcional

// Evita SSG nessas rotas (precisamos ler cookies/sessão a cada request)
export const dynamic = "force-dynamic";

export default async function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  // 1) Padrão correto para Server Components com auth-helpers-nextjs
  const cookieStore = cookies();
  const supabase = createServerComponentClient({
    cookies: () => cookieStore,
  });

  const {
    data: { session },
  } = await supabase.auth.getSession();

  // 2) Se quiser logar, faça FORA do JSX:
  // debug("[SSR] session:", session);

  return (
    <html lang="pt-BR" className="dark">
      <body className="bg-slate-900">
        <Providers initialSession={session ?? null}>
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