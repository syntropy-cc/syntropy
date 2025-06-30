import type React from "react"
import { Inter } from "next/font/google"
import "./globals.css"
import { QueryProvider } from "@/lib/query-provider"
import { Navbar } from "@/components/syntropy/Navbar"
import { Footer } from "@/components/syntropy/Footer"
import { Toaster } from "@/components/ui/toaster"

const inter = Inter({ subsets: ["latin"] })

export const metadata = {
  title: "Syntropy - Aprenda. Construa. Pesquise.",
  description: "O ecossistema open-source que conecta aprendizado, colaboração e inovação em um só lugar.",
  keywords: ["aprendizado", "programação", "cursos", "desenvolvimento", "open-source"],
    generator: 'v0.dev'
}


export default function RootLayout({
  children,
}: {
  children: React.ReactNode
}) {
  return (
    <html lang="pt-BR" className="dark">
      <body className={`${inter.className} bg-slate-900`}>
        <QueryProvider>
          <div className="min-h-screen flex flex-col bg-slate-900">
            <Navbar />
            <main className="flex-1">{children}</main>
            <Footer />
          </div>
          <Toaster />
        </QueryProvider>
      </body>
    </html>
  )
}
