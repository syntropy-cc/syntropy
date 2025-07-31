import { createMiddlewareClient } from '@supabase/auth-helpers-nextjs'
import { NextResponse } from 'next/server'
import type { NextRequest } from 'next/server'

export async function middleware(req: NextRequest) {
  const res = NextResponse.next()
  const supabase = createMiddlewareClient({ req, res })

  try {
    // Verificar sessão
    const {
      data: { session },
      error
    } = await supabase.auth.getSession()

    console.log('🔍 Middleware - Path:', req.nextUrl.pathname)
    console.log('🔍 Middleware - Session:', !!session)
    console.log('🔍 Middleware - User:', session?.user?.email)

    if (error) {
      console.error('❌ Middleware - Erro na sessão:', error)
    }

    // Rotas que requerem autenticação
    const protectedPaths = ['/dashboard', '/profile', '/settings']
    const isProtectedPath = protectedPaths.some(path => 
      req.nextUrl.pathname.startsWith(path)
    )

    // Se não tem sessão e está tentando acessar área protegida
    if (!session && isProtectedPath) {
      console.log('🚫 Middleware - Redirecionando para login')
      return NextResponse.redirect(new URL('/auth/login', req.url))
    }

    // Se tem sessão e está tentando acessar login
    if (session && req.nextUrl.pathname.startsWith('/auth/login')) {
      console.log('✅ Middleware - Usuário já logado, redirecionando')
      return NextResponse.redirect(new URL('/', req.url))
    }

    return res

  } catch (err) {
    console.error('💥 Middleware - Erro inesperado:', err)
    return res
  }
}

export const config = {
  matcher: [
    /*
     * Match all request paths except for the ones starting with:
     * - _next/static (static files)
     * - _next/image (image optimization files)
     * - favicon.ico (favicon file)
     * - robots.txt (robots file)
     */
    '/((?!_next/static|_next/image|favicon.ico|robots.txt).*)',
  ],
}