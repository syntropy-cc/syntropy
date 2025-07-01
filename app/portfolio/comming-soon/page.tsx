"use client"

import type React from "react"

import { useState } from "react"
import { motion } from "framer-motion"
import { Button } from "@/components/ui/button"
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card"
import { Badge } from "@/components/ui/badge"
import { useToast } from "@/hooks/use-toast"
import { CheckCircle, ArrowLeft, Award, User, Rocket, Star, Zap, Layers3, Trophy, Users } from "lucide-react"
import Link from "next/link"

export default function PortfolioComingSoonPage() {
  const [isSubmitted, setIsSubmitted] = useState(false)
  const { toast } = useToast()

  // Simulação de registro de interesse futuro
  const handleNotify = () => {
    setIsSubmitted(true)
    toast({
      title: "Interesse registrado com sucesso!",
      description: "Você receberá atualizações sobre o lançamento do Portfólio Dinâmico.",
    })
  }

  if (isSubmitted) {
    return (
      <div className="min-h-screen bg-gradient-to-br from-slate-900 via-fuchsia-900/20 to-slate-900 text-white flex items-center justify-center px-4">
        <motion.div
          initial={{ opacity: 0, scale: 0.8 }}
          animate={{ opacity: 1, scale: 1 }}
          transition={{ duration: 0.6 }}
          className="text-center max-w-2xl mx-auto"
        >
          <div className="w-20 h-20 bg-fuchsia-600 rounded-full flex items-center justify-center mx-auto mb-8">
            <CheckCircle className="h-10 w-10 text-white" />
          </div>
          <h1 className="text-4xl font-bold mb-6">Obrigado pelo seu interesse!</h1>
          <p className="text-xl text-white/80 mb-8">
            Você foi adicionado à nossa lista de espera. Enviaremos atualizações exclusivas sobre o lançamento do Portfólio Dinâmico.
          </p>
          <div className="flex flex-col sm:flex-row gap-4 justify-center">
            <Button asChild size="lg" className="bg-fuchsia-600 hover:bg-fuchsia-700 text-white">
              <Link href="/portfolio">
                <ArrowLeft className="mr-2 h-4 w-4" />
                Voltar para Portfólio
              </Link>
            </Button>
            <Button asChild variant="outline" size="lg" className="border-white/20 text-white hover:bg-white/10">
              <Link href="/">Explorar Syntropy</Link>
            </Button>
          </div>
        </motion.div>
      </div>
    )
  }

  return (
    <div className="min-h-screen bg-gradient-to-br from-slate-900 via-fuchsia-900/20 to-slate-900 text-white">
      {/* Header com botão de voltar */}
      <div className="absolute top-8 left-8 z-10">
        <Link
          href="/portfolio"
          className="inline-flex items-center gap-2 text-white/60 hover:text-white transition-colors bg-white/10 backdrop-blur-sm rounded-lg px-4 py-2 border border-white/20"
        >
          <ArrowLeft className="h-4 w-4" />
          Voltar para Portfólio
        </Link>
      </div>

      <div className="container py-16 px-4">
        <div className="max-w-6xl mx-auto">
          {/* Hero Section */}
          <motion.div
            initial={{ opacity: 0, y: 30 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.8 }}
            className="text-center mb-16 pt-16"
          >
            <div className="flex items-center justify-center gap-3 mb-6">
              <div className="w-16 h-16 bg-fuchsia-600 rounded-2xl flex items-center justify-center">
                <Award className="h-8 w-8 text-white" />
              </div>
              <Badge className="bg-fuchsia-600 text-white px-4 py-2 text-sm">Em breve</Badge>
            </div>

            <h1 className="text-5xl md:text-6xl font-bold mb-6">
              <span className="text-fuchsia-400">Portfólio Dinâmico</span>
              <br />
              está chegando
            </h1>

            <p className="text-xl md:text-2xl text-white/80 mb-8 max-w-3xl mx-auto leading-relaxed">
              Um registro unificado de todas as suas conquistas, contribuições e atividades no ecossistema Syntropy. Demonstre seu impacto profissional, acadêmico e empreendedor de forma dinâmica e gamificada.
            </p>
          </motion.div>

          <div className="grid lg:grid-cols-2 gap-12 items-start">
            {/* Preview de Funcionalidades */}
            <motion.div
              initial={{ opacity: 0, x: -30 }}
              animate={{ opacity: 1, x: 0 }}
              transition={{ delay: 0.3, duration: 0.8 }}
            >
              <h2 className="text-3xl font-bold mb-8">O que estará no seu portfólio</h2>
              <div className="space-y-6">
                {[
                  {
                    icon: User,
                    title: "Atividades de Aprendizado",
                    description:
                      "Cursos completados, certificações, projetos desenvolvidos, participação em discussões e mentoria.",
                  },
                  {
                    icon: Layers3,
                    title: "Contribuições para Projetos",
                    description:
                      "Projetos criados, colaborações, contribuições para terceiros, parcerias e métricas de impacto.",
                  },
                  {
                    icon: Trophy,
                    title: "Atividades Científicas",
                    description:
                      "Participação em laboratórios, artigos publicados, revisões, colaborações e reconhecimento acadêmico.",
                  },
                ].map((feature, index) => {
                  const Icon = feature.icon
                  return (
                    <motion.div
                      key={feature.title}
                      initial={{ opacity: 0, y: 20 }}
                      animate={{ opacity: 1, y: 0 }}
                      transition={{ delay: 0.5 + index * 0.1, duration: 0.6 }}
                      className="flex gap-4"
                    >
                      <div className="w-12 h-12 bg-fuchsia-600 rounded-lg flex items-center justify-center flex-shrink-0">
                        <Icon className="h-6 w-6 text-white" />
                      </div>
                      <div>
                        <h3 className="text-xl font-semibold text-white mb-2">{feature.title}</h3>
                        <p className="text-white/70">{feature.description}</p>
                      </div>
                    </motion.div>
                  )
                })}
              </div>
            </motion.div>

            {/* Gamificação e Benefícios */}
            <motion.div
              initial={{ opacity: 0, x: 30 }}
              animate={{ opacity: 1, x: 0 }}
              transition={{ delay: 0.5, duration: 0.8 }}
            >
              <Card className="bg-white/10 backdrop-blur-sm border-white/20">
                <CardHeader className="text-center">
                  <div className="w-12 h-12 bg-fuchsia-600 rounded-lg flex items-center justify-center mx-auto mb-4">
                    <Star className="h-6 w-6 text-white" />
                  </div>
                  <CardTitle className="text-white text-2xl">Sistema de Gamificação</CardTitle>
                  <CardDescription className="text-white/70">
                    Progresso, badges, níveis e reconhecimento em todo o ecossistema Syntropy.
                  </CardDescription>
                </CardHeader>
                <CardContent>
                  <div className="space-y-4">
                    {[
                      {
                        icon: Rocket,
                        title: "Progressão e Reconhecimento",
                        description:
                          "Níveis, selos, badges e certificados por conquistas específicas e diferentes tipos de contribuição.",
                      },
                      {
                        icon: Zap,
                        title: "Integração Transversal",
                        description:
                          "Gamificação presente em Labs, Projects e Portfolio, com conquistas e recompensas integradas.",
                      },
                      {
                        icon: Users,
                        title: "Reputação e Comunidade",
                        description:
                          "Sistema de reputação unificado, incentivo à colaboração e construção de senso de pertencimento.",
                      },
                    ].map((item, idx) => {
                      const Icon = item.icon
                      return (
                        <div key={item.title} className="flex items-start gap-3">
                          <Icon className="h-5 w-5 text-fuchsia-400 mt-1" />
                          <div>
                            <span className="font-semibold text-white">{item.title}</span>
                            <div className="text-white/70 text-sm">{item.description}</div>
                          </div>
                        </div>
                      )
                    })}
                  </div>
                  <Button
                    type="button"
                    onClick={handleNotify}
                    className="w-full bg-fuchsia-600 hover:bg-fuchsia-700 text-white py-3 text-lg mt-8"
                  >
                    Quero ser notificado
                  </Button>
                  <p className="text-xs text-white/60 text-center mt-4">
                    Ao registrar seu interesse, você concorda em receber atualizações sobre o Portfólio Dinâmico. Você pode cancelar a qualquer momento.
                  </p>
                </CardContent>
              </Card>
            </motion.div>
          </div>
        </div>
      </div>
    </div>
  )
}
