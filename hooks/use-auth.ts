"use client"

import { useEffect, useState } from "react"
import { createClient, isSupabaseConfigured } from "@/lib/supabase/client"
import type { User, Session } from "@supabase/supabase-js"

export function useAuth() {
  const [user, setUser] = useState<User | null>(null)
  const [session, setSession] = useState<Session | null>(null)
  const [loading, setLoading] = useState(true)
  const [isConfigured, setIsConfigured] = useState(false)
  const [initialized, setInitialized] = useState(false)

  useEffect(() => {
    console.log('🔄 useAuth: Inicializando hook de autenticação...');
    
    const configured = isSupabaseConfigured()
    setIsConfigured(configured)

    if (!configured) {
      console.warn('⚠️ useAuth: Supabase não configurado');
      setLoading(false)
      return
    }

    const supabase = createClient()
    if (!supabase) {
      console.error('❌ useAuth: Falha ao criar client Supabase');
      setLoading(false)
      return
    }

    console.log('✅ useAuth: Client Supabase criado com sucesso');

    // Get initial session com debug detalhado
    const getInitialSession = async () => {
      try {
        console.log('🔍 useAuth: Buscando sessão inicial...');
        const { data: { session }, error } = await supabase.auth.getSession()
        
        if (error) {
          console.error('❌ useAuth: Erro ao buscar sessão:', error);
        } else if (session) {
          console.log('✅ useAuth: Sessão encontrada!', {
            userId: session.user.id,
            email: session.user.email,
            expiresAt: new Date(session.expires_at! * 1000).toLocaleString(),
            provider: session.user.app_metadata.provider,
            lastSignIn: session.user.last_sign_in_at
          });
          
          // Verificar dados do usuário no banco
          try {
            const { data: profile } = await supabase
              .from('profiles')
              .select('username, full_name, role')
              .eq('id', session.user.id)
              .single();
              
            if (profile) {
              console.log('👤 useAuth: Perfil do usuário:', profile);
            }
          } catch (profileError) {
            console.warn('⚠️ useAuth: Erro ao buscar perfil:', profileError);
          }
        } else {
          console.log('ℹ️ useAuth: Nenhuma sessão ativa encontrada');
        }
        
        setSession(session)
        setUser(session?.user ?? null)
        setInitialized(true)
      } catch (error) {
        console.error("❌ useAuth: Erro ao obter sessão inicial:", error)
        setInitialized(true)
      } finally {
        console.log('✅ useAuth: Inicialização concluída');
        setLoading(false)
      }
    }

    getInitialSession()

    // Listen for auth changes com debug
    console.log('👂 useAuth: Configurando listener de mudanças de auth...');
    const { data: { subscription } } = supabase.auth.onAuthStateChange(
      async (event: any, session: any) => {
        console.log('🔄 useAuth: Estado de auth mudou:', { 
          event, 
          hasSession: !!session,
          userId: session?.user?.id,
          email: session?.user?.email
        });
        
        if (session) {
          console.log('👤 useAuth: Usuário logado via evento:', {
            email: session.user.email,
            provider: session.user.app_metadata.provider
          });
        } else {
          console.log('👋 useAuth: Usuário deslogado via evento');
        }
        
        setSession(session)
        setUser(session?.user ?? null)
        setLoading(false)
        setInitialized(true)
      }
    )

    return () => {
      console.log('🧹 useAuth: Limpando listeners...');
      subscription.unsubscribe();
    }
  }, [])

  const signOut = async () => {
    if (!isConfigured) {
      console.warn('⚠️ useAuth: Tentando logout sem configuração');
      return;
    }

    const supabase = createClient()
    if (!supabase) {
      console.error('❌ useAuth: Não foi possível criar client para logout');
      return;
    }

    console.log('🚪 useAuth: Fazendo logout...');
    try {
      const { error } = await supabase.auth.signOut();
      if (error) {
        console.error('❌ useAuth: Erro no logout:', error);
      } else {
        console.log('✅ useAuth: Logout realizado com sucesso');
      }
      return { error };
    } catch (error) {
      console.error('❌ useAuth: Erro inesperado no logout:', error);
      return { error };
    }
  }

  // Debug do estado atual
  useEffect(() => {
    if (!loading) {
      console.log('📊 useAuth: Estado atual:', {
        hasUser: !!user,
        userEmail: user?.email,
        hasSession: !!session,
        isConfigured,
        loading
      });
    }
  }, [user, session, loading, isConfigured]);

  return {
    user,
    session,
    loading,
    isConfigured,
    initialized,
    signOut,
  }
}
