// app/auth/callback/page.tsx
'use client'

import { useEffect, useState } from 'react'
import { useRouter, useSearchParams } from 'next/navigation'
import { useSupabaseClient } from '@supabase/auth-helpers-react'
import { debug } from '@/lib/debug'

export default function AuthCallback() {
  const router = useRouter()
  const searchParams = useSearchParams()
  const supabase = useSupabaseClient()
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState<string | null>(null)

  useEffect(() => {
    debug('Callback: useEffect iniciado')
    const handleCallback = async () => {
      debug('Callback: handleCallback chamado')
      // se o cliente não estiver disponível, aborta
      if (!supabase) {
        debug('Callback: supabase não configurado')
        setError('Supabase não configurado')
        setLoading(false)
        return
      }
      // se a URL contém erro do provedor OAuth, mostra mensagem e redireciona para a tela de login
      const errorParam = searchParams.get('error')
      const errorDescription = searchParams.get('error_description')
      if (errorParam) {
        debug('Callback: erro OAuth detectado', errorParam, errorDescription)
        setError(`Erro na autenticação: ${errorDescription || errorParam}`)
        setTimeout(() => router.push('/auth?error=oauth_error'), 2000)
        return
      }
      const code = searchParams.get('code')
      debug('Callback: code extraído da URL', code)
      if (code) {
        debug('Callback: trocando code por sessão via exchangeCodeForSession')
        const { error: authError } = await supabase.auth.exchangeCodeForSession(code)
        debug('Callback: exchangeCodeForSession retornou', authError)
        if (authError) {
          debug('Callback: erro ao processar login', authError)
          setError(`Erro ao processar login: ${authError.message}`)
          setTimeout(() => router.push('/auth?error=exchange_error'), 2000)
          return
        }
        debug('Callback: router.refresh e push /')
        router.refresh()
        router.push('/')
      } else {
        debug('Callback: sem code, checando sessão existente')
        const {
          data: { session },
          error: sessionError,
        } = await supabase.auth.getSession()
        debug('Callback: getSession retornou', session, sessionError)
        if (sessionError) {
          debug('Callback: erro ao checar sessão', sessionError)
          setError(`Erro de sessão: ${sessionError.message}`)
          setTimeout(() => router.push('/auth?error=session_check_error'), 2000)
          return
        }
        if (session) {
          debug('Callback: sessão já existe, push /')
          router.push('/')
        } else {
          debug('Callback: sem sessão, push /auth')
          router.push('/auth')
        }
      }
    }
    handleCallback().finally(() => {
      debug('Callback: handleCallback finalizado, setLoading(false)')
      setLoading(false)
    })
  }, [supabase, router, searchParams])

  if (error) {
    return (
      <div className="flex flex-col items-center justify-center py-20">
        <div className="text-3xl">⚠️</div>
        <h2 className="text-xl font-semibold my-2">Erro na Autenticação</h2>
        <p className="text-red-500 mb-4">{error}</p>
        <p>Redirecionando automaticamente...</p>
      </div>
    )
  }

  if (loading) {
    return (
      <div className="flex flex-col items-center justify-center py-20">
        <div className="animate-spin h-10 w-10 mb-4 border-4 border-blue-500 border-t-transparent rounded-full"></div>
        <h2 className="text-xl font-semibold mb-2">Processando Login</h2>
        <p className="text-gray-500">Configurando sua sessão...</p>
      </div>
    )
  }

  // não renderiza nada quando a operação termina, pois ocorre redirecionamento
  return null
}
