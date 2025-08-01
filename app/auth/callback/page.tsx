'use client';

import { useEffect, useState } from 'react';
import { useRouter, useSearchParams } from 'next/navigation';
import { createClient } from '@/lib/supabase/client';

export default function AuthCallback() {
  const router = useRouter();
  const searchParams = useSearchParams();
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    const handleAuthCallback = async () => {
      try {
        console.log('🚀 Iniciando processamento do callback...');
        
        const supabase = createClient();
        
        if (!supabase) {
          console.error('❌ Supabase não configurado');
          setError('Erro de configuração do sistema');
          setLoading(false);
          return;
        }

        // Verificar se há parâmetros de erro
        const errorParam = searchParams.get('error');
        const errorDescription = searchParams.get('error_description');
        
        if (errorParam) {
          console.error('❌ Erro no OAuth:', errorParam, errorDescription);
          setError(`Erro na autenticação: ${errorDescription || errorParam}`);
          setTimeout(() => router.push('/auth?error=oauth_error'), 2000);
          return;
        }

        // Verificar se há code (indica sucesso do OAuth)
        const code = searchParams.get('code');
        console.log('📝 Code recebido:', !!code);

        if (code) {
          // Processar o código de autorização
          console.log('🔄 Trocando código por sessão...');
          
          const { data, error: exchangeError } = await supabase.auth.exchangeCodeForSession(code);
          
          if (exchangeError) {
            console.error('❌ Erro ao trocar código:', exchangeError);
            setError(`Erro ao processar login: ${exchangeError.message}`);
            setTimeout(() => router.push('/auth?error=exchange_error'), 2000);
            return;
          }

          if (data.session && data.user) {
            console.log('✅ Sessão criada com sucesso:', data.user.email);
            console.log('🔐 Access token:', data.session.access_token ? 'presente' : 'ausente');
            
            // Aguardar um pouco para garantir que a sessão seja salva
            await new Promise(resolve => setTimeout(resolve, 1000));
            
            // Verificar se a sessão foi realmente salva
            const { data: sessionCheck } = await supabase.auth.getSession();
            console.log('🔍 Verificação de sessão:', !!sessionCheck.session);
            
            if (sessionCheck.session) {
              console.log('✅ Redirecionando para home...');
              router.push('/');
            } else {
              console.error('❌ Sessão não foi salva corretamente');
              setError('Erro ao salvar sessão');
              setTimeout(() => router.push('/auth?error=session_save_error'), 2000);
            }
          } else {
            console.error('❌ Dados de sessão inválidos');
            setError('Dados de autenticação inválidos');
            setTimeout(() => router.push('/auth?error=invalid_session'), 2000);
          }
        } else {
          // Sem code, verificar se já tem sessão ativa
          console.log('🔍 Verificando sessão existente...');
          
          const { data: { session }, error: sessionError } = await supabase.auth.getSession();
          
          if (sessionError) {
            console.error('❌ Erro ao verificar sessão:', sessionError);
            setError(`Erro de sessão: ${sessionError.message}`);
            setTimeout(() => router.push('/auth?error=session_check_error'), 2000);
            return;
          }

          if (session) {
            console.log('✅ Sessão existente encontrada:', session.user.email);
            router.push('/');
          } else {
            console.log('❌ Nenhuma sessão encontrada, redirecionando para login');
            router.push('/auth');
          }
        }

      } catch (err) {
        console.error('💥 Erro inesperado no callback:', err);
        setError(`Erro inesperado: ${err instanceof Error ? err.message : 'Erro desconhecido'}`);
        setTimeout(() => router.push('/auth?error=unexpected_error'), 2000);
      } finally {
        setLoading(false);
      }
    };

    handleAuthCallback();
  }, [router, searchParams]);

  if (error) {
    return (
      <div className="flex items-center justify-center min-h-screen bg-gradient-to-br from-slate-900 to-slate-800">
        <div className="text-center p-8 bg-red-950/30 rounded-2xl border border-red-800/50 max-w-md">
          <div className="text-red-400 text-6xl mb-4">⚠️</div>
          <h1 className="text-red-300 text-xl font-semibold mb-2">Erro na Autenticação</h1>
          <p className="text-red-200 text-sm mb-4">{error}</p>
          <p className="text-red-300/70 text-xs">Redirecionando automaticamente...</p>
        </div>
      </div>
    );
  }

  if (loading) {
    return (
      <div className="flex items-center justify-center min-h-screen bg-gradient-to-br from-slate-900 to-slate-800">
        <div className="text-center p-8 bg-white/10 backdrop-blur-lg rounded-2xl border border-white/20">
          <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-blue-500 mx-auto mb-4"></div>
          <h1 className="text-white text-xl font-semibold mb-2">Processando Login</h1>
          <p className="text-white/70 text-sm">Configurando sua sessão...</p>
        </div>
      </div>
    );
  }

  return null;
}