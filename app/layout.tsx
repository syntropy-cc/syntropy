// app/layout.tsx (server component)
import { cookies } from "next/headers";
import { createServerClient } from "@supabase/auth-helpers-nextjs";
import Providers from "./providers";
import { Navbar } from "@/components/syntropy/Navbar";
import { Footer } from "@/components/syntropy/Footer";
import { QueryProvider } from "@/lib/query-provider";

export default async function RootLayout({ children }: { children: React.ReactNode }) {
  const supabase = createServerClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!,
    { cookies }
  );
  const {
    data: { session },
  } = await supabase.auth.getSession();

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
