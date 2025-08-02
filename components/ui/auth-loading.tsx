"use client"

import { useAuth } from "@/components/providers/AuthProvider"

export function AuthLoading() {
  const { loading, initialized } = useAuth()

  if (loading || !initialized) {
    return (
      <div className="fixed inset-0 bg-slate-900/50 backdrop-blur-sm z-50 flex items-center justify-center">
        <div className="bg-white/10 backdrop-blur-lg rounded-2xl p-8 shadow-2xl border border-white/20">
          <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-blue-400 mx-auto mb-4"></div>
          <p className="text-white text-center">Verificando autenticação...</p>
        </div>
      </div>
    )
  }

  return null
} 