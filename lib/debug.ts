// lib/debug.ts
// Utilitário de debug para logs de autenticação

export function debug(...args: any[]) {
  if (typeof window !== 'undefined') {
    // Client-side: usa variável de ambiente exposta
    if (process.env.NEXT_PUBLIC_DEBUG_AUTH === '1') {
      // eslint-disable-next-line no-console
      console.log('[AUTH]', ...args)
    }
  } else {
    // Server-side: process.env
    if (process.env.NEXT_PUBLIC_DEBUG_AUTH === '1') {
      // eslint-disable-next-line no-console
      console.log('[AUTH]', ...args)
    }
  }
}
