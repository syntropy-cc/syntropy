"use client"

import { createContext, useContext, useEffect, useState } from "react"
import { createClient } from "@/lib/supabase/client"
import type { User, Session } from "@supabase/supabase-js"

interface AuthContextType {
  user: User | null
  session: Session | null
  loading: boolean
  initialized: boolean
  signOut: () => Promise<void>
}

const AuthContext = createContext<AuthContextType | undefined>(undefined)

export function AuthProvider({ children }: { children: React.ReactNode }) {
  const [user, setUser] = useState<User | null>(null)
  const [session, setSession] = useState<Session | null>(null)
  const [loading, setLoading] = useState(true)
  const [initialized, setInitialized] = useState(false)

  useEffect(() => {
    console.log('🔄 AuthProvider: Inicializando...')
    
    const supabase = createClient()
    if (!supabase) {
      console.error('❌ AuthProvider: Falha ao criar client')
      setLoading(false)
      setInitialized(true)
      return
    }

    // Verificar sessão inicial
    const getInitialSession = async () => {
      try {
        console.log('🔍 AuthProvider: Verificando sessão inicial...')
        const { data: { session }, error } = await supabase.auth.getSession()
        
        if (error) {
          console.error('❌ AuthProvider: Erro ao obter sessão:', error)
        } else if (session) {
          console.log('✅ AuthProvider: Sessão encontrada:', session.user.email)
        } else {
          console.log('ℹ️ AuthProvider: Nenhuma sessão ativa')
        }
        
        setSession(session)
        setUser(session?.user ?? null)
      } catch (error) {
        console.error('❌ AuthProvider: Erro inesperado:', error)
      } finally {
        setLoading(false)
        setInitialized(true)
        console.log('✅ AuthProvider: Inicialização concluída')
      }
    }

    getInitialSession()

    // Listener para mudanças de auth
    const { data: { subscription } } = supabase.auth.onAuthStateChange(
      async (event, session) => {
        console.log('🔄 AuthProvider: Mudança de auth:', event, session?.user?.email)
        setSession(session)
        setUser(session?.user ?? null)
        setLoading(false)
        setInitialized(true)
      }
    )

    return () => {
      console.log('🧹 AuthProvider: Limpando listeners...')
      subscription.unsubscribe()
    }
  }, [])

  const signOut = async () => {
    const supabase = createClient()
    if (!supabase) return

    try {
      await supabase.auth.signOut()
      console.log('✅ AuthProvider: Logout realizado')
    } catch (error) {
      console.error('❌ AuthProvider: Erro no logout:', error)
    }
  }

  return (
    <AuthContext.Provider value={{
      user,
      session,
      loading,
      initialized,
      signOut
    }}>
      {children}
    </AuthContext.Provider>
  )
}

export function useAuth() {
  const context = useContext(AuthContext)
  if (context === undefined) {
    throw new Error('useAuth deve ser usado dentro de um AuthProvider')
  }
  return context
} 