'use client';

import { supabase } from '@/lib/supabase/client';
import { Github, Google } from 'lucide-react';

export default function SocialAuthButtons() {
  const handleLogin = async (provider: 'google' | 'github') => {
    await supabase.auth.signInWithOAuth({
      provider,
      options: {
        redirectTo: `${window.location.origin}/auth/callback`
      }
    });
  };

  return (
    <div className="flex flex-col gap-4">
      <button
        onClick={() => handleLogin('google')}
        className="flex items-center gap-2 px-4 py-2 rounded-lg bg-white text-gray-900 shadow hover:bg-gray-100 transition"
        aria-label="Entrar com Google"
      >
        <Google className="w-5 h-5 text-[#EA4335]" />
        Entrar com Google
      </button>
      <button
        onClick={() => handleLogin('github')}
        className="flex items-center gap-2 px-4 py-2 rounded-lg bg-gray-900 text-white shadow hover:bg-gray-800 transition"
        aria-label="Entrar com GitHub"
      >
        <Github className="w-5 h-5" />
        Entrar com GitHub
      </button>
    </div>
  );
}
