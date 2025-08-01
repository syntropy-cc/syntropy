"use client"

import { useEffect, useState } from "react"
import { createClient, isSupabaseConfigured } from "@/lib/supabase/client"
import type { User, Session } from "@supabase/supabase-js"

export function useAuth() {
  const [user, setUser] = useState<User | null>(null)
  const [session, setSession] = useState<Session | null>(null)
  const [loading, setLoading] = useState(true)
  const [isConfigured, setIsConfigured] = useState(false)

  useEffect(() => {
    const configured = isSupabaseConfigured()
    setIsConfigured(configured)

    if (!configured) {
      console.warn('Supabase not configured - auth features disabled')
      setLoading(false)
      return
    }

    const supabase = createClient()
    if (!supabase) {
      console.error('Failed to create Supabase client')
      setLoading(false)
      return
    }

    // Get initial session
    const getInitialSession = async () => {
      try {
        console.log('🔍 useAuth: Verificando sessão inicial...')
        const {
          data: { session },
          error
        } = await supabase.auth.getSession()
        
        if (error) {
          console.error('❌ useAuth: Erro ao obter sessão:', error)
        } else {
          console.log('📋 useAuth: Sessão inicial:', !!session, session?.user?.email)
          setSession(session)
          setUser(session?.user ?? null)
        }
      } catch (error) {
        console.error("💥 useAuth: Erro inesperado ao obter sessão:", error)
      } finally {
        setLoading(false)
      }
    }

    getInitialSession()

    // Listen for auth changes
    console.log('👂 useAuth: Configurando listener de mudanças de auth...')
    const {
      data: { subscription },
    } = supabase.auth.onAuthStateChange(async (event, session) => {
      console.log('🔄 useAuth: Auth state changed:', event, !!session, session?.user?.email)
      
      setSession(session)
      setUser(session?.user ?? null)
      setLoading(false)

      // Log adicional para debugging
      if (event === 'SIGNED_IN') {
        console.log('✅ useAuth: Usuário logado:', session?.user?.email)
      } else if (event === 'SIGNED_OUT') {
        console.log('👋 useAuth: Usuário deslogado')
      } else if (event === 'TOKEN_REFRESHED') {
        console.log('🔄 useAuth: Token renovado')
      }
    })

    return () => {
      console.log('🧹 useAuth: Limpando subscription')
      subscription.unsubscribe()
    }
  }, [])

  const signOut = async () => {
    if (!isConfigured) {
      console.warn('Supabase not configured - cannot sign out')
      return
    }

    const supabase = createClient()
    if (!supabase) {
      console.error('Failed to create Supabase client for sign out')
      return
    }

    console.log('👋 useAuth: Fazendo logout...')
    const { error } = await supabase.auth.signOut()
    
    if (error) {
      console.error('❌ useAuth: Erro ao fazer logout:', error)
      throw error
    } else {
      console.log('✅ useAuth: Logout realizado com sucesso')
    }
  }

  return {
    user,
    session,
    loading,
    isConfigured,
    signOut,
  }
}