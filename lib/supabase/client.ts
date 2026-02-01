import { createBrowserClient } from '@supabase/ssr';
import type { Database } from './types';
import { isSupabaseEnabled } from '@/lib/feature-flags';

const supabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL!;
const supabaseAnonKey = process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!;

// Função para verificar se o Supabase está configurado e habilitado
export const isSupabaseConfigured = (): boolean => {
  return isSupabaseEnabled() && !!(supabaseUrl && supabaseAnonKey)
}

/**
 * Mock do cliente Supabase para quando está desabilitado.
 */
const createMockClient = () => ({
  auth: {
    getSession: async () => ({ data: { session: null }, error: null }),
    getUser: async () => ({ data: { user: null }, error: null }),
    signOut: async () => ({ error: null }),
    signInWithOAuth: async () => ({ data: null, error: null }),
    onAuthStateChange: () => ({
      data: {
        subscription: {
          unsubscribe: () => {},
        },
      },
    }),
  },
});

// Cliente principal do Supabase
export const createClient = () => {
  // Retorna mock se Supabase está desabilitado
  if (!isSupabaseEnabled()) {
    return createMockClient() as any;
  }
  return createBrowserClient<Database>(supabaseUrl, supabaseAnonKey);
}

// Export para compatibilidade - só cria cliente real se habilitado
export const supabase = createClient()

// Export default
export default createClient;