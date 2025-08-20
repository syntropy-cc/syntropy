import { createServerClient } from '@supabase/ssr'
import { NextResponse } from 'next/server'
import type { NextRequest } from 'next/server'
import { debug } from '@/lib/debug'

export async function middleware(req: NextRequest) {
  let response = NextResponse.next({
    request: {
      headers: req.headers,
    },
  })

  const supabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL
  const supabaseAnonKey = process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY

  if (!supabaseUrl || !supabaseAnonKey) {
    debug('Middleware: Supabase não configurado')
    return response
  }

  const supabase = createServerClient(
    supabaseUrl,
    supabaseAnonKey,
    {
      cookies: {
        get(name: string) {
          return req.cookies.get(name)?.value
        },
        set(name: string, value: string, options: any) {
          req.cookies.set({
            name,
            value,
            ...options,
          })
          response = NextResponse.next({
            request: {
              headers: req.headers,
            },
          })
          response.cookies.set({
            name,
            value,
            ...options,
            domain: 'syntropy.cc',
            secure: true,
            sameSite: 'lax'
          })
        },
        remove(name: string, options: any) {
          req.cookies.set({
            name,
            value: '',
            ...options,
          })
          response = NextResponse.next({
            request: {
              headers: req.headers,
            },
          })
          response.cookies.set({
            name,
            value: '',
            ...options,
            domain: 'syntropy.cc',
            secure: true,
            sameSite: 'lax'
          })
        },
      },
    }
  )

  try {
    // Verificar e renovar sessão
    const {
      data: { session },
      error
    } = await supabase.auth.getSession()

    debug('Middleware - Path:', req.nextUrl.pathname)
    debug('Middleware - Session:', !!session)
    debug('Middleware - User:', session?.user?.email)

    if (error) {
      debug('Middleware - Erro na sessão:', error)
    }

    // Refresh user session if exists
    if (session) {
      await supabase.auth.getUser()
    }

    // Rotas que requerem autenticação
    // const protectedPaths = ['/dashboard', '/profile', '/settings', '/learn', '/projects', '/labs']
    // const isProtectedPath = protectedPaths.some(path =>
    //   req.nextUrl.pathname.startsWith(path)
    // )

    // Se não tem sessão e está tentando acessar área protegida
    // if (!session && isProtectedPath) {
    //   debug('Middleware - Redirecionando para login')
    //   const redirectUrl = new URL('/auth', req.url)
    //   redirectUrl.searchParams.set('redirectTo', req.nextUrl.pathname)
    //   return NextResponse.redirect(redirectUrl)
    // }

    // Se tem sessão e está tentando acessar página de login
    if (session && (req.nextUrl.pathname.startsWith('/auth/login') || req.nextUrl.pathname === '/auth')) {
      debug('Middleware - Usuário já logado, redirecionando')
      const redirectTo = req.nextUrl.searchParams.get('redirectTo') || '/'
      return NextResponse.redirect(new URL(redirectTo, req.url))
    }

    return response

  } catch (err) {
    debug('Middleware - Erro inesperado:', err)
    return response
  }
}

export const config = {
  matcher: [
    '/((?!_next/static|_next/image|favicon.ico|robots.txt|api|auth|auth/.*).*)',
  ],
};