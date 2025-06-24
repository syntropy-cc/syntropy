"use client"

import { useState } from "react"
import { Button } from "@/components/ui/button"
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card"
import { Separator } from "@/components/ui/separator"
import { Github, Mail, Loader2, ArrowLeft } from "lucide-react"
import { signInWithOAuth } from "@/lib/auth"
import { isSupabaseConfigured } from "@/lib/supabase"
import { useToast } from "@/hooks/use-toast"
import Link from "next/link"
import { motion } from "framer-motion"

interface AuthFormProps {
  mode?: "signin" | "signup"
}

export function AuthForm({ mode = "signin" }: AuthFormProps) {
  const [loading, setLoading] = useState<string | null>(null)
  const { toast } = useToast()
  const configured = isSupabaseConfigured()

  const handleOAuthSignIn = async (provider: "google" | "github") => {
    if (!configured) {
      // Simulate loading for better UX
      setLoading(provider)
      setTimeout(() => {
        setLoading(null)
        toast({
          title: "Em desenvolvimento",
          description: "A autenticação será habilitada em breve!",
          variant: "default",
        })
      }, 2000)
      return
    }

    try {
      setLoading(provider)
      await signInWithOAuth(provider)
    } catch (error) {
      console.error("Authentication error:", error)
      toast({
        title: "Erro na autenticação",
        description: "Não foi possível fazer login. Tente novamente.",
        variant: "destructive",
      })
    } finally {
      setLoading(null)
    }
  }

  const isSignUp = mode === "signup"

  return (
    <div className="min-h-screen bg-gradient-to-br from-slate-900 via-blue-900/20 to-slate-900 flex items-center justify-center p-4">
      <motion.div
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ duration: 0.5 }}
        className="w-full max-w-md"
      >
        {/* Back to Home */}
        <motion.div
          initial={{ opacity: 0, x: -20 }}
          animate={{ opacity: 1, x: 0 }}
          transition={{ delay: 0.2 }}
          className="mb-8"
        >
          <Link href="/" className="inline-flex items-center gap-2 text-white/60 hover:text-white transition-colors">
            <ArrowLeft className="h-4 w-4" />
            Voltar ao início
          </Link>
        </motion.div>

        <Card className="bg-white/10 backdrop-blur-lg border-white/20">
          <CardHeader className="text-center">
            <motion.div
              initial={{ opacity: 0, scale: 0.8 }}
              animate={{ opacity: 1, scale: 1 }}
              transition={{ delay: 0.3 }}
              className="flex items-center justify-center gap-2 mb-4"
            >
              <div className="h-10 w-10 bg-blue-600 rounded-lg flex items-center justify-center">
                <span className="text-white font-bold">S</span>
              </div>
              <span className="font-bold text-2xl text-white">Syntropy</span>
            </motion.div>

            <CardTitle className="text-2xl text-white">{isSignUp ? "Criar conta" : "Entrar"}</CardTitle>
            <CardDescription className="text-white/60">
              {isSignUp
                ? "Junte-se à comunidade Syntropy e comece sua jornada de aprendizado"
                : "Acesse sua conta e continue aprendendo"}
            </CardDescription>
          </CardHeader>

          <CardContent className="space-y-4">
            {/* Google OAuth */}
            <motion.div initial={{ opacity: 0, y: 10 }} animate={{ opacity: 1, y: 0 }} transition={{ delay: 0.4 }}>
              <Button
                variant="outline"
                className="w-full bg-white/5 border-white/20 text-white hover:bg-white/10 hover:border-white/30"
                onClick={() => handleOAuthSignIn("google")}
                disabled={loading !== null}
              >
                {loading === "google" ? (
                  <Loader2 className="mr-2 h-4 w-4 animate-spin" />
                ) : (
                  <Mail className="mr-2 h-4 w-4" />
                )}
                {isSignUp ? "Criar conta com Google" : "Entrar com Google"}
              </Button>
            </motion.div>

            {/* GitHub OAuth */}
            <motion.div initial={{ opacity: 0, y: 10 }} animate={{ opacity: 1, y: 0 }} transition={{ delay: 0.5 }}>
              <Button
                variant="outline"
                className="w-full bg-white/5 border-white/20 text-white hover:bg-white/10 hover:border-white/30"
                onClick={() => handleOAuthSignIn("github")}
                disabled={loading !== null}
              >
                {loading === "github" ? (
                  <Loader2 className="mr-2 h-4 w-4 animate-spin" />
                ) : (
                  <Github className="mr-2 h-4 w-4" />
                )}
                {isSignUp ? "Criar conta com GitHub" : "Entrar com GitHub"}
              </Button>
            </motion.div>

            <motion.div initial={{ opacity: 0 }} animate={{ opacity: 1 }} transition={{ delay: 0.6 }}>
              <Separator className="bg-white/20" />
            </motion.div>

            {/* Toggle between signin/signup */}
            <motion.div
              initial={{ opacity: 0, y: 10 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ delay: 0.7 }}
              className="text-center"
            >
              <p className="text-white/60 text-sm">{isSignUp ? "Já tem uma conta?" : "Não tem uma conta?"}</p>
              <Link
                href={isSignUp ? "/auth?mode=signin" : "/auth?mode=signup"}
                className="text-blue-400 hover:text-blue-300 text-sm font-medium transition-colors"
              >
                {isSignUp ? "Fazer login" : "Criar conta gratuita"}
              </Link>
            </motion.div>

            {/* Terms and Privacy */}
            {isSignUp && (
              <motion.div
                initial={{ opacity: 0, y: 10 }}
                animate={{ opacity: 1, y: 0 }}
                transition={{ delay: 0.8 }}
                className="text-center"
              >
                <p className="text-xs text-white/40">
                  Ao criar uma conta, você concorda com nossos{" "}
                  <Link href="/terms" className="text-blue-400 hover:text-blue-300">
                    Termos de Uso
                  </Link>{" "}
                  e{" "}
                  <Link href="/privacy" className="text-blue-400 hover:text-blue-300">
                    Política de Privacidade
                  </Link>
                </p>
              </motion.div>
            )}
          </CardContent>
        </Card>

        {/* Features Preview */}
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ delay: 0.9 }}
          className="mt-8 grid grid-cols-3 gap-4 text-center"
        >
          {[
            { icon: "📚", text: "Cursos interativos" },
            { icon: "🚀", text: "Projetos reais" },
            { icon: "🔬", text: "Labs experimentais" },
          ].map((feature, index) => (
            <div key={index} className="text-white/60">
              <div className="text-2xl mb-1">{feature.icon}</div>
              <p className="text-xs">{feature.text}</p>
            </div>
          ))}
        </motion.div>
      </motion.div>
    </div>
  )
}
