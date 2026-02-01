/**
 * Feature Flags - Configurações de funcionalidades
 * 
 * Este arquivo controla quais funcionalidades estão habilitadas na aplicação.
 * Para habilitar/desabilitar uma funcionalidade, basta alterar o valor para true/false.
 */

export const FEATURE_FLAGS = {
  /**
   * Controla a visibilidade dos botões de login/cadastro e a conexão com o Supabase.
   * 
   * Quando desabilitado (false):
   * - Botões de login/cadastro ficam ocultos em toda a aplicação
   * - Conexão com o Supabase é desativada
   * - Rotas /auth/* redirecionam para a página inicial
   * 
   * Quando habilitado (true):
   * - Sistema de autenticação funciona normalmente
   * - Conexão com Supabase é estabelecida
   * 
   * TOGGLE: Altere para `true` quando quiser habilitar o sistema de autenticação.
   */
  AUTH_ENABLED: false,
} as const;

// Helper functions para usar as flags
export function isAuthEnabled(): boolean {
  return FEATURE_FLAGS.AUTH_ENABLED;
}

/**
 * Verifica se o Supabase deve ser inicializado.
 * Atualmente vinculado à flag AUTH_ENABLED.
 */
export function isSupabaseEnabled(): boolean {
  return FEATURE_FLAGS.AUTH_ENABLED;
}
