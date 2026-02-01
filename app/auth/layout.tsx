import type React from "react"
import { redirect } from "next/navigation"
import { isAuthEnabled } from "@/lib/feature-flags"

export const metadata = {
  title: "Autenticação - Syntropy",
  description: "Entre ou crie sua conta no Syntropy",
}

export default function AuthLayout({
  children,
}: {
  children: React.ReactNode
}) {
  // Se autenticação está desabilitada, redireciona para a página inicial
  if (!isAuthEnabled()) {
    redirect("/")
  }

  return children
}
