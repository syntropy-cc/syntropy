import { createPagesBrowserClient } from '@supabase/auth-helpers-nextjs';
import type { Database } from './types';

const supabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL!;
const supabaseAnonKey = process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!;

// Função para verificar se o Supabase está configurado
export const isSupabaseConfigured = (): boolean => {
  return !!(supabaseUrl && supabaseAnonKey)
}

// Cliente principal do Supabase
export const createClient = () =>
  createPagesBrowserClient<Database>({
    supabaseUrl,
    supabaseKey: supabaseAnonKey,
  });

// Export para compatibilidade
export const supabase = createClient()

// Export default
export default createClient;