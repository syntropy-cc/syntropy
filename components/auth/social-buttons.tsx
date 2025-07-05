'use client';

import { supabase } from '@/lib/supabase/client';
import { Github } from 'lucide-react';

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
        <svg className="w-5 h-5" viewBox="0 0 24 24"><g><path fill="#4285F4" d="M21.805 10.023h-9.765v3.977h5.617c-.242 1.242-1.484 3.648-5.617 3.648-3.375 0-6.125-2.789-6.125-6.25s2.75-6.25 6.125-6.25c1.922 0 3.211.773 3.953 1.477l2.703-2.625c-1.711-1.578-3.922-2.547-6.656-2.547-5.523 0-10 4.477-10 10s4.477 10 10 10c5.75 0 9.563-4.031 9.563-9.719 0-.656-.07-1.156-.156-1.656z"/><path fill="#34A853" d="M3.545 7.548l3.273 2.402c.891-1.711 2.523-2.852 4.437-2.852 1.172 0 2.242.406 3.078 1.203l2.312-2.25c-1.406-1.312-3.219-2.101-5.39-2.101-3.672 0-6.75 2.477-7.859 5.797z"/><path fill="#FBBC05" d="M12 22c2.438 0 4.484-.797 5.984-2.156l-2.797-2.273c-.797.547-1.812.875-3.188.875-2.453 0-4.531-1.656-5.281-3.938l-3.25 2.5c1.406 2.828 4.406 4.992 8.532 4.992z"/><path fill="#EA4335" d="M21.805 10.023h-9.765v3.977h5.617c-.242 1.242-1.484 3.648-5.617 3.648-3.375 0-6.125-2.789-6.125-6.25s2.75-6.25 6.125-6.25c1.922 0 3.211.773 3.953 1.477l2.703-2.625c-1.711-1.578-3.922-2.547-6.656-2.547-5.523 0-10 4.477-10 10s4.477 10 10 10c5.75 0 9.563-4.031 9.563-9.719 0-.656-.07-1.156-.156-1.656z" opacity=".1"/></g></svg>
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
