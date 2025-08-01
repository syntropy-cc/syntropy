'use client';

import { useState } from 'react';
import { supabase } from '@/lib/supabase/client';

export default function SocialAuthButtons() {
  const [loading, setLoading] = useState<string | null>(null);

  const handleSocialLogin = async (provider: 'google' | 'github') => {
    try {
      setLoading(provider);
      console.log(`🚀 Iniciando login com ${provider}...`);

      const { data, error } = await supabase.auth.signInWithOAuth({
        provider,
        options: {
          redirectTo: 'https://syntropy.cc/auth/callback',
          queryParams: {
            access_type: 'offline',
            prompt: 'consent',
          }
        }
      });

      if (error) {
        console.error(`❌ Erro no login ${provider}:`, error);
        alert(`Erro no login: ${error.message}`);
        return;
      }

      console.log(`✅ Redirecionamento ${provider} iniciado`);
      // O redirect acontece automaticamente
      
    } catch (err) {
      console.error('💥 Erro inesperado:', err);
      alert('Erro inesperado. Tente novamente.');
    } finally {
      setLoading(null);
    }
  };

  return (
    <div className="space-y-4">
      {/* Google Login */}
      <button
        onClick={() => handleSocialLogin('google')}
        disabled={loading !== null}
        className={`
          w-full flex items-center justify-center gap-3 px-4 py-3 
          border border-gray-300 rounded-lg shadow-sm bg-white 
          text-gray-700 font-medium transition-all duration-200
          ${loading === 'google' 
            ? 'opacity-50 cursor-not-allowed' 
            : 'hover:bg-gray-50 hover:shadow-md active:scale-95'
          }
        `}
      >
        {loading === 'google' ? (
          <div className="animate-spin rounded-full h-5 w-5 border-b-2 border-gray-700"></div>
        ) : (
          <svg className="w-5 h-5" viewBox="0 0 24 24">
            <path
              fill="#4285F4"
              d="M22.56 12.25c0-.78-.07-1.53-.2-2.25H12v4.26h5.92c-.26 1.37-1.04 2.53-2.21 3.31v2.77h3.57c2.08-1.92 3.28-4.74 3.28-8.09z"
            />
            <path
              fill="#34A853"
              d="M12 23c2.97 0 5.46-.98 7.28-2.66l-3.57-2.77c-.98.66-2.23 1.06-3.71 1.06-2.86 0-5.29-1.93-6.16-4.53H2.18v2.84C3.99 20.53 7.7 23 12 23z"
            />
            <path
              fill="#FBBC05"
              d="M5.84 14.09c-.22-.66-.35-1.36-.35-2.09s.13-1.43.35-2.09V7.07H2.18C1.43 8.55 1 10.22 1 12s.43 3.45 1.18 4.93l2.85-2.22.81-.62z"
            />
            <path
              fill="#EA4335"
              d="M12 5.38c1.62 0 3.06.56 4.21 1.64l3.15-3.15C17.45 2.09 14.97 1 12 1 7.7 1 3.99 3.47 2.18 7.07l3.66 2.84c.87-2.6 3.3-4.53 6.16-4.53z"
            />
          </svg>
        )}
        <span>
          {loading === 'google' ? 'Conectando...' : 'Continuar com Google'}
        </span>
      </button>

      {/* GitHub Login */}
      <button
        onClick={() => handleSocialLogin('github')}
        disabled={loading !== null}
        className={`
          w-full flex items-center justify-center gap-3 px-4 py-3 
          border border-gray-700 rounded-lg shadow-sm bg-gray-900 
          text-white font-medium transition-all duration-200
          ${loading === 'github' 
            ? 'opacity-50 cursor-not-allowed' 
            : 'hover:bg-gray-800 hover:shadow-md active:scale-95'
          }
        `}
      >
        {loading === 'github' ? (
          <div className="animate-spin rounded-full h-5 w-5 border-b-2 border-white"></div>
        ) : (
          <svg className="w-5 h-5" fill="currentColor" viewBox="0 0 24 24">
            <path d="M12 0c-6.626 0-12 5.373-12 12 0 5.302 3.438 9.8 8.207 11.387.599.111.793-.261.793-.577v-2.234c-3.338.726-4.033-1.416-4.033-1.416-.546-1.387-1.333-1.756-1.333-1.756-1.089-.745.083-.729.083-.729 1.205.084 1.839 1.237 1.839 1.237 1.07 1.834 2.807 1.304 3.492.997.107-.775.418-1.305.762-1.604-2.665-.305-5.467-1.334-5.467-5.931 0-1.311.469-2.381 1.236-3.221-.124-.303-.535-1.524.117-3.176 0 0 1.008-.322 3.301 1.23.957-.266 1.983-.399 3.003-.404 1.02.005 2.047.138 3.006.404 2.291-1.552 3.297-1.23 3.297-1.23.653 1.653.242 2.874.118 3.176.77.84 1.235 1.911 1.235 3.221 0 4.609-2.807 5.624-5.479 5.921.43.372.823 1.102.823 2.222v3.293c0 .319.192.694.801.576 4.765-1.589 8.199-6.086 8.199-11.386 0-6.627-5.373-12-12-12z" />
          </svg>
        )}
        <span>
          {loading === 'github' ? 'Conectando...' : 'Continuar com GitHub'}
        </span>
      </button>
    </div>
  );
}