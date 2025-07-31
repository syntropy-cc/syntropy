'use client';

import { useEffect, useState } from 'react';
import { useRouter, useSearchParams } from 'next/navigation';
import { supabase } from '@/lib/supabase/client';

export default function AuthCallback() {
  const router = useRouter();
  const searchParams = useSearchParams();
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    const handleAuthCallback = async () => {
      try {
        console.log('🚀 Iniciando processamento do callback...');
        
        // Verificar se há parâmetros de erro
        const errorParam = searchParams.get('error');
        const errorDescription = searchParams.get('error_description');
        
        if (errorParam) {
          console.error('❌ Erro no OAuth:', errorParam, errorDescription);
          setError(`Erro na autenticação: ${errorDescription || errorParam}`);
          setLoading(false);
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
            setLoading(false);
            return;
          }

          if (data.session) {
            console.log('✅ Sessão criada com sucesso:', data.session.user?.email);
            
            // Aguardar um pouco para garantir que a sessão foi salva
            await new Promise(resolve => setTimeout(resolve, 1000));
            
            // Redirecionar para a página principal
            router.replace('/');
            return;
          }
        }

        // Fallback: tentar obter sessão existente
        console.log('🔍 Verificando sessão existente...');
        const { data: { session }, error: sessionError } = await supabase.auth.getSession();

        if (sessionError) {
          console.error('❌ Erro ao obter sessão:', sessionError);
          setError(`Erro na sessão: ${sessionError.message}`);
          setLoading(false);
          return;
        }

        if (session) {
          console.log('✅ Sessão encontrada:', session.user?.email);
          router.replace('/');
        } else {
          console.log('❌ Nenhuma sessão encontrada');
          setError('Login não foi completado. Tente novamente.');
          setLoading(false);
        }

      } catch (err) {
        console.error('💥 Erro inesperado:', err);
        setError('Erro inesperado durante a autenticação');
        setLoading(false);
      }
    };

    handleAuthCallback();
  }, [router, searchParams]);

  if (loading) {
    return (
      <div className="flex items-center justify-center min-h-screen bg-gradient-to-br from-slate-900 to-slate-800">
        <div className="text-center">
          <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-white mx-auto mb-4"></div>
          <span className="text-lg text-white">Processando autenticação...</span>
          <p className="text-sm text-gray-400 mt-2">Por favor, aguarde</p>
        </div>
      </div>
    );
  }

  if (error) {
    return (
      <div className="flex items-center justify-center min-h-screen bg-gradient-to-br from-slate-900 to-slate-800">
        <div className="bg-red-500/10 backdrop-blur-lg rounded-2xl p-8 shadow-2xl border border-red-500/20 max-w-md w-full text-center">
          <div className="text-red-400 text-4xl mb-4">⚠️</div>
          <h2 className="text-xl font-bold text-white mb-4">Erro na Autenticação</h2>
          <p className="text-gray-300 mb-6">{error}</p>
          <button
            onClick={() => router.push('/auth/login')}
            className="bg-blue-600 hover:bg-blue-700 text-white font-bold py-2 px-4 rounded-lg transition-colors"
          >
            Tentar Novamente
          </button>
        </div>
      </div>
    );
  }

  return null;
}