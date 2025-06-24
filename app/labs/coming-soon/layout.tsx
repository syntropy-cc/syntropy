import type React from "react"

export const metadata = {
  title: "Syntropy Labs - Em Breve",
  description:
    "A plataforma definitiva para pesquisa científica colaborativa está chegando. Registre seu interesse e seja notificado.",
}

export default function ComingSoonLayout({
  children,
}: {
  children: React.ReactNode
}) {
  return <div className="min-h-screen">{children}</div>
}
