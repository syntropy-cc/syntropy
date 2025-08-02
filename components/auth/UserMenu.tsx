"use client"

import { useState } from "react"
import { useAuth } from "@/components/providers/AuthProvider"
import { Button } from "@/components/ui/button"
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuLabel,
  DropdownMenuSeparator,
  DropdownMenuTrigger,
} from "@/components/ui/dropdown-menu"
import { Avatar, AvatarFallback, AvatarImage } from "@/components/ui/avatar"
import { User, Settings, LogOut, BookOpen, Code, FlaskConical } from "lucide-react"
import Link from "next/link"
import { useRouter } from "next/navigation"
import { createClient } from "@/lib/supabase/client"

interface UserMenuProps {
  mobile?: boolean
  onClose?: () => void
}

export function UserMenu({ mobile = false, onClose }: UserMenuProps) {
  const { user, signOut, loading, initialized } = useAuth()
  const router = useRouter()
  const [isSigningOut, setIsSigningOut] = useState(false)

  // Mostrar loading enquanto verifica autenticação
  if (loading || !initialized) {
    return (
      <div className="flex items-center gap-2">
        <div className="h-8 w-8 animate-spin rounded-full border-2 border-blue-400 border-t-transparent"></div>
      </div>
    )
  }

  // Always show auth buttons that redirect to /auth
  if (!user) {
    return (
      <div className="flex items-center gap-2">
        <Button asChild variant="ghost" size="sm" className="text-gray-300 hover:text-white hover:bg-slate-800">
          <Link href="/auth?mode=signin">
            <User className="h-4 w-4 mr-2" />
            Entrar
          </Link>
        </Button>
        <Button asChild size="sm" className="bg-blue-600 hover:bg-blue-700 text-white">
          <Link href="/auth?mode=signup">Criar conta</Link>
        </Button>
        
        {/* BOTÃO DEBUG - APENAS EM DESENVOLVIMENTO */}
        {process.env.NODE_ENV === 'development' && (
          <Button
            onClick={async () => {
              console.log('🐛 DEBUG: Verificação manual de sessão');
              const { createClient } = await import('@/lib/supabase/client');
              const supabase = createClient();
              if (!supabase) {
                console.log('❌ DEBUG: Não foi possível criar client');
                return;
              }
              
              const { data: { session }, error } = await supabase.auth.getSession();
              console.log('🔍 DEBUG: Resultado da sessão:', { session, error });
              
              if (session) {
                console.log('👤 DEBUG: Dados do usuário:', {
                  id: session.user.id,
                  email: session.user.email,
                  metadata: session.user.user_metadata
                });
              }
            }}
            variant="outline"
            size="sm"
            className="bg-red-500 hover:bg-red-600 text-white text-xs"
          >
            Debug
          </Button>
        )}
      </div>
    )
  }

  const handleSignOut = async () => {
    setIsSigningOut(true)
    try {
      await signOut()
      router.push("/")
      onClose?.()
    } catch (error) {
      console.error("Sign out error:", error)
    } finally {
      setIsSigningOut(false)
    }
  }

  const userInitials =
    user.user_metadata?.full_name
      ?.split(" ")
      .map((n: string) => n[0])
      .join("")
      .toUpperCase() ||
    user.email?.[0]?.toUpperCase() ||
    "U"

  if (mobile) {
    return (
      <div className="space-y-2">
        <div className="flex items-center gap-3 p-3 rounded-lg bg-slate-800">
          <Avatar className="h-8 w-8">
            <AvatarImage
              src={user.user_metadata?.avatar_url || "/placeholder.svg"}
              alt={user.user_metadata?.full_name || "User"}
            />
            <AvatarFallback className="bg-blue-600 text-white text-xs">{userInitials}</AvatarFallback>
          </Avatar>
          <div>
            <p className="text-sm font-medium text-white">{user.user_metadata?.full_name || "Usuário"}</p>
            <p className="text-xs text-gray-400">{user.email}</p>
          </div>
        </div>

        <Button
          variant="ghost"
          className="w-full justify-start text-gray-300 hover:text-white hover:bg-slate-800"
          onClick={handleSignOut}
          disabled={isSigningOut}
        >
          <LogOut className="mr-2 h-4 w-4" />
          {isSigningOut ? "Saindo..." : "Sair"}
        </Button>
      </div>
    )
  }

  return (
    <DropdownMenu>
      <DropdownMenuTrigger asChild>
        <Button variant="ghost" className="relative h-8 w-8 rounded-full">
          <Avatar className="h-8 w-8">
            <AvatarImage
              src={user.user_metadata?.avatar_url || "/placeholder.svg"}
              alt={user.user_metadata?.full_name || "User"}
            />
            <AvatarFallback className="bg-blue-600 text-white text-xs">{userInitials}</AvatarFallback>
          </Avatar>
        </Button>
      </DropdownMenuTrigger>
      <DropdownMenuContent className="w-56 bg-slate-800 border-slate-700" align="end" forceMount>
        <DropdownMenuLabel className="font-normal">
          <div className="flex flex-col space-y-1">
            <p className="text-sm font-medium leading-none text-white">{user.user_metadata?.full_name || "Usuário"}</p>
            <p className="text-xs leading-none text-gray-400">{user.email}</p>
          </div>
        </DropdownMenuLabel>
        <DropdownMenuSeparator className="bg-slate-700" />

        <DropdownMenuItem asChild className="text-gray-300 hover:text-white hover:bg-slate-700">
          <Link href="/learn" className="flex items-center">
            <BookOpen className="mr-2 h-4 w-4" />
            Meus Cursos
          </Link>
        </DropdownMenuItem>

        <DropdownMenuItem asChild className="text-gray-300 hover:text-white hover:bg-slate-700">
          <Link href="/projects" className="flex items-center">
            <Code className="mr-2 h-4 w-4" />
            Meus Projetos
          </Link>
        </DropdownMenuItem>

        <DropdownMenuItem asChild className="text-gray-300 hover:text-white hover:bg-slate-700">
          <Link href="/labs" className="flex items-center">
            <FlaskConical className="mr-2 h-4 w-4" />
            Meus Labs
          </Link>
        </DropdownMenuItem>

        <DropdownMenuSeparator className="bg-slate-700" />

        <DropdownMenuItem asChild className="text-gray-300 hover:text-white hover:bg-slate-700">
          <Link href="/settings" className="flex items-center">
            <Settings className="mr-2 h-4 w-4" />
            Configurações
          </Link>
        </DropdownMenuItem>

        <DropdownMenuSeparator className="bg-slate-700" />

        <DropdownMenuItem
          className="text-gray-300 hover:text-white hover:bg-slate-700 cursor-pointer"
          onClick={handleSignOut}
          disabled={isSigningOut}
        >
          <LogOut className="mr-2 h-4 w-4" />
          {isSigningOut ? "Saindo..." : "Sair"}
        </DropdownMenuItem>

        <DropdownMenuSeparator className="bg-slate-700" />

        <DropdownMenuItem
          className="text-gray-300 hover:text-white hover:bg-slate-700 cursor-pointer"
          onClick={handleSignOut}
          disabled={isSigningOut}
        >
          <LogOut className="mr-2 h-4 w-4" />
          {isSigningOut ? "Saindo..." : "Sair"}
        </DropdownMenuItem>

        {/* ADICIONAR ESTE ITEM DE DEBUG */}
        {process.env.NODE_ENV === 'development' && (
          <>
            <DropdownMenuSeparator className="bg-slate-700" />
            <DropdownMenuItem
              className="text-yellow-400 hover:text-yellow-300 hover:bg-slate-700 cursor-pointer"
              onClick={async () => {
                console.log('🐛 DEBUG: Status da autenticação');
                console.log('👤 User object:', user);
                
                const supabase = createClient();
                if (supabase) {
                  const { data: { session } } = await supabase.auth.getSession();
                  console.log('🔍 Current session:', session);
                  
                  // Testar query no backend
                  const { data, error } = await supabase
                    .from('profiles')
                    .select('*')
                    .eq('id', user.id)
                    .single();
                  
                  console.log('🗄️ Profile from DB:', { data, error });
                }
              }}
            >
              🐛 Debug Auth
            </DropdownMenuItem>
          </>
        )}
      </DropdownMenuContent>
    </DropdownMenu>
  )
}
