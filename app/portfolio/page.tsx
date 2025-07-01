"use client"

import type React from "react"
import { useRef } from "react"
import { motion, useInView } from "framer-motion"
import { Button } from "@/components/ui/button"
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card"
import { Badge } from "@/components/ui/badge"
import { CheckCircle, Award, User, Briefcase, GraduationCap, TrendingUp, Star, Users, Zap, Trophy, Layers, Share2 } from "lucide-react"
import Link from "next/link"
import { useRouter } from "next/navigation"
import { useAuth } from "@/hooks/use-auth"

// Animated Section Component
function AnimatedSection({
  children,
  className = "",
}: {
  children: React.ReactNode
  className?: string
}) {
  const ref = useRef(null)
  const isInView = useInView(ref, { once: true, margin: "-100px" })

  return (
    <motion.section
      ref={ref}
      className={`py-20 px-4 ${className}`}
      initial={{ opacity: 0, y: 100 }}
      animate={isInView ? { opacity: 1, y: 0 } : { opacity: 0, y: 100 }}
      transition={{ duration: 0.8, ease: "easeOut" }}
    >
      {children}
    </motion.section>
  )
}

// Portfolio Stats Preview
function PortfolioStats() {
  return (
    <div className="relative w-80 h-96 bg-gradient-to-br from-slate-800 to-slate-900 rounded-xl border border-slate-700 overflow-hidden">
      {/* Header */}
      <div className="p-4 border-b border-slate-700">
        <div className="flex items-center gap-3">
          <div className="w-10 h-10 bg-blue-600 rounded-full flex items-center justify-center text-white font-bold">
            PF
          </div>
          <div>
            <h3 className="text-white font-semibold">Seu Portfólio</h3>
            <p className="text-slate-400 text-sm">Registro dinâmico</p>
          </div>
        </div>
      </div>
      {/* Atividades */}
      <div className="p-4 space-y-3">
        <div className="bg-slate-700/50 rounded-lg p-3">
          <div className="flex items-center gap-3">
            <Award className="h-5 w-5 text-yellow-400" />
            <div>
              <h4 className="text-white font-medium">Cursos & Certificações</h4>
              <p className="text-slate-400 text-sm">8 cursos, 3 certificados</p>
            </div>
          </div>
        </div>
        <div className="bg-slate-700/50 rounded-lg p-3">
          <div className="flex items-center gap-3">
            <Briefcase className="h-5 w-5 text-blue-400" />
            <div>
              <h4 className="text-white font-medium">Projetos Concluídos</h4>
              <p className="text-slate-400 text-sm">5 projetos, 12 colaborações</p>
            </div>
          </div>
        </div>
        <div className="bg-slate-700/50 rounded-lg p-3">
          <div className="flex items-center gap-3">
            <GraduationCap className="h-5 w-5 text-purple-400" />
            <div>
              <h4 className="text-white font-medium">Atividades Científicas</h4>
              <p className="text-slate-400 text-sm">2 artigos, 1 laboratório</p>
            </div>
          </div>
        </div>
      </div>
      {/* Stats */}
      <div className="absolute bottom-4 left-4 right-4">
        <div className="grid grid-cols-3 gap-4 text-center">
          <div>
            <div className="text-blue-400 font-bold text-lg">15</div>
            <div className="text-slate-400 text-xs">Conquistas</div>
          </div>
          <div>
            <div className="text-green-400 font-bold text-lg">120</div>
            <div className="text-slate-400 text-xs">Contribuições</div>
          </div>
          <div>
            <div className="text-yellow-400 font-bold text-lg">7</div>
            <div className="text-slate-400 text-xs">Certificados</div>
          </div>
        </div>
      </div>
    </div>
  )
}

export default function PortfolioLandingPage() {
  const router = useRouter()
  const { user, loading } = useAuth()

  function handleCtaClick() {
    if (user) {
      router.push("/portfolio/comming-soon")
    } else {
      router.push("/auth?mode=signup")
    }
  }

  return (
    <div className="bg-gradient-to-br from-slate-900 via-blue-900/20 to-slate-900 text-white overflow-hidden">
      {/* Hero Section */}
      <section className="relative min-h-screen flex items-center justify-center px-4 pt-24 pb-32">
        <div className="container mx-auto text-center max-w-6xl">
          <motion.div
            initial={{ opacity: 0, scale: 0.8 }}
            animate={{ opacity: 1, scale: 1 }}
            transition={{ duration: 1, ease: "easeOut" }}
          >
            <h1 className="text-5xl md:text-6xl font-bold mb-8 mt-8">
              <span className="bg-gradient-to-r from-blue-400 to-pink-400 bg-clip-text text-transparent">
                Seu Portfólio Dinâmico
              </span>
            </h1>
          </motion.div>
          <motion.p
            className="text-xl md:text-2xl text-white/80 mb-20 max-w-4xl mx-auto leading-relaxed"
            initial={{ opacity: 0, y: 30 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ delay: 0.5, duration: 0.8 }}
          >
            Registro unificado de todas as suas conquistas, projetos, pesquisas e colaborações no ecossistema Syntropy. Demonstre seu impacto, evolua sua carreira e conquiste reconhecimento real.
          </motion.p>
          <motion.div
            className="flex flex-col sm:flex-row gap-4 justify-center mb-16"
            initial={{ opacity: 0, y: 50 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ delay: 1, duration: 0.8 }}
          >
            <Button
              size="lg"
              className="bg-blue-600 hover:bg-blue-700 text-white px-8 py-4 text-lg"
              onClick={handleCtaClick}
              disabled={loading}
            >
              Crie seu portfólio
            </Button>
          </motion.div>
          {/* Two-Column Layout */}
          <motion.div
            className="grid lg:grid-cols-2 gap-8 max-w-7xl mx-auto"
            initial={{ opacity: 0, y: 50 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ delay: 1.2, duration: 0.8 }}
          >
            {/* Left - Benefícios */}
            <motion.div
              initial={{ opacity: 0, x: -50 }}
              animate={{ opacity: 1, x: 0 }}
              transition={{ delay: 1.4, duration: 0.8 }}
            >
              <Card className="bg-white/10 backdrop-blur-sm border-white/20 h-full">
                <CardHeader>
                  <CardTitle className="text-white text-2xl mb-2">Aplicações do Portfólio</CardTitle>
                  <CardDescription className="text-white/70 text-lg">
                    Seu portfólio é mais que um currículo: é prova real de impacto, colaboração e evolução.
                  </CardDescription>
                </CardHeader>
                <CardContent>
                  <div className="space-y-4">
                    <div className="flex items-center gap-3">
                      <Briefcase className="h-5 w-5 text-blue-400" />
                      <span className="text-white/80">Profissional: currículo dinâmico, histórico verificável, networking</span>
                    </div>
                    <div className="flex items-center gap-3">
                      <TrendingUp className="h-5 w-5 text-green-400" />
                      <span className="text-white/80">Empreendedorismo: prova social, rede de contatos, execução comprovada</span>
                    </div>
                    <div className="flex items-center gap-3">
                      <GraduationCap className="h-5 w-5 text-purple-400" />
                      <span className="text-white/80">Acadêmico: publicações, colaborações científicas, métricas de impacto</span>
                    </div>
                  </div>
                </CardContent>
              </Card>
            </motion.div>
            {/* Right - Preview */}
            <motion.div
              initial={{ opacity: 0, x: 50 }}
              animate={{ opacity: 1, x: 0 }}
              transition={{ delay: 1.6, duration: 0.8 }}
            >
              <PortfolioStats />
            </motion.div>
          </motion.div>
        </div>
      </section>

      {/* Como funciona */}
      <AnimatedSection className="bg-white/5 pt-32">
        <div className="container mx-auto">
          <div className="text-center mb-16">
            <h2 className="text-4xl md:text-5xl font-bold mb-6">Como funciona o Portfólio Dinâmico</h2>
          </div>
          <div className="grid md:grid-cols-3 gap-12 max-w-6xl mx-auto">
            {[
              {
                number: "1",
                icon: User,
                title: "Atividades de Aprendizado",
                description: "Cursos, projetos, mentorias e discussões registrados automaticamente.",
              },
              {
                number: "2",
                icon: Layers,
                title: "Contribuições para Projetos",
                description: "Projetos criados, colaborações, métricas de impacto e parcerias.",
              },
              {
                number: "3",
                icon: Award,
                title: "Atividades Científicas",
                description: "Laboratórios, artigos, revisões, citações e reconhecimento acadêmico.",
              },
            ].map((step, index) => {
              const Icon = step.icon
              return (
                <motion.div
                  key={step.number}
                  className="text-center"
                  initial={{ opacity: 0, y: 50 }}
                  whileInView={{ opacity: 1, y: 0 }}
                  transition={{ delay: index * 0.2, duration: 0.6 }}
                >
                  <div className="relative mb-6">
                    <div className="w-20 h-20 bg-blue-600 rounded-full flex items-center justify-center mx-auto relative">
                      <Icon className="h-8 w-8 text-white" />
                      <div className="absolute -top-2 -right-2 w-8 h-8 bg-white rounded-full flex items-center justify-center">
                        <span className="text-blue-600 font-bold text-sm">{step.number}</span>
                      </div>
                    </div>
                  </div>
                  <h3 className="text-xl font-semibold mb-4">{step.title}</h3>
                  <p className="text-white/70">{step.description}</p>
                </motion.div>
              )
            })}
          </div>
        </div>
      </AnimatedSection>

      {/* Gamificação */}
      <AnimatedSection>
        <div className="container mx-auto">
          <div className="text-center mb-16">
            <h2 className="text-4xl md:text-5xl font-bold mb-6">Sistema de Gamificação</h2>
            <p className="text-xl text-white/70 max-w-3xl mx-auto">
              Progrida, conquiste e seja reconhecido! Níveis, badges, selos e reputação integrados em todo o ecossistema.
            </p>
          </div>
          <div className="grid md:grid-cols-2 lg:grid-cols-4 gap-6 max-w-7xl mx-auto">
            {[
              {
                icon: Star,
                title: "Níveis & Progressão",
                description: "Evolua de acordo com suas contribuições e conquistas.",
              },
              {
                icon: Trophy,
                title: "Selos & Certificados",
                description: "Receba reconhecimento por marcos e conquistas específicas.",
              },
              {
                icon: Zap,
                title: "Badges Personalizáveis",
                description: "Destaque diferentes tipos de contribuição no seu perfil.",
              },
              {
                icon: Users,
                title: "Reputação Unificada",
                description: "Ganhe reputação colaborando em Learn, Projects e Labs.",
              },
            ].map((feature, index) => {
              const Icon = feature.icon
              return (
                <motion.div
                  key={feature.title}
                  initial={{ opacity: 0, y: 50 }}
                  whileInView={{ opacity: 1, y: 0 }}
                  transition={{ delay: index * 0.1, duration: 0.6 }}
                >
                  <Card className="bg-white/10 backdrop-blur-sm border-white/20 h-full hover:bg-white/15 transition-colors">
                    <CardHeader className="text-center">
                      <div className="w-12 h-12 bg-blue-600 rounded-lg flex items-center justify-center mx-auto mb-4">
                        <Icon className="h-6 w-6 text-white" />
                      </div>
                      <CardTitle className="text-white">{feature.title}</CardTitle>
                    </CardHeader>
                    <CardContent>
                      <p className="text-white/70 text-center">{feature.description}</p>
                    </CardContent>
                  </Card>
                </motion.div>
              )
            })}
          </div>
        </div>
      </AnimatedSection>

      {/* Exemplos de Conquistas */}
      <AnimatedSection className="bg-white/5">
        <div className="container mx-auto">
          <div className="text-center mb-16">
            <h2 className="text-4xl md:text-5xl font-bold mb-6">Exemplos de Conquistas</h2>
          </div>
          <div className="grid md:grid-cols-2 lg:grid-cols-3 gap-8 max-w-6xl mx-auto mb-12">
            {[
              {
                icon: <CheckCircle className="h-6 w-6 text-green-400" />,
                title: "Primeiro Projeto Publicado",
                description: "Você publicou seu primeiro projeto open-source no Syntropy.",
                badge: "Inovador",
              },
              {
                icon: <Award className="h-6 w-6 text-yellow-400" />,
                title: "Certificação Full Stack",
                description: "Concluiu todos os cursos da trilha Full Stack.",
                badge: "Full Stack",
              },
              {
                icon: <Share2 className="h-6 w-6 text-blue-400" />,
                title: "Mentoria Colaborativa",
                description: "Ajudou 10+ membros da comunidade como mentor.",
                badge: "Mentor",
              },
              {
                icon: <Trophy className="h-6 w-6 text-purple-400" />,
                title: "Artigo Publicado",
                description: "Publicou artigo científico revisado por pares.",
                badge: "Pesquisador",
              },
              {
                icon: <Users className="h-6 w-6 text-pink-400" />,
                title: "Colaboração em Equipe",
                description: "Participou de 5 projetos colaborativos.",
                badge: "Colaborador",
              },
              {
                icon: <Star className="h-6 w-6 text-yellow-300" />,
                title: "Badge de Destaque",
                description: "Recebeu badge por contribuição de alto impacto.",
                badge: "Destaque",
              },
            ].map((ach, index) => (
              <motion.div
                key={ach.title}
                initial={{ opacity: 0, y: 50 }}
                whileInView={{ opacity: 1, y: 0 }}
                transition={{ delay: index * 0.1, duration: 0.6 }}
              >
                <Card className="bg-white/10 backdrop-blur-sm border-white/20 h-full hover:bg-white/15 transition-colors">
                  <CardHeader className="flex flex-row items-center gap-4">
                    <div className="w-12 h-12 bg-blue-600 rounded-lg flex items-center justify-center">
                      {ach.icon}
                    </div>
                    <div>
                      <CardTitle className="text-white text-lg">{ach.title}</CardTitle>
                      <Badge className="bg-green-600 text-white mt-2">{ach.badge}</Badge>
                    </div>
                  </CardHeader>
                  <CardContent>
                    <p className="text-white/70 text-sm leading-relaxed">{ach.description}</p>
                  </CardContent>
                </Card>
              </motion.div>
            ))}
          </div>
        </div>
      </AnimatedSection>

      {/* CTA Final */}
      <AnimatedSection>
        <div className="container mx-auto">
          <div className="text-center max-w-4xl mx-auto">
            <h2 className="text-4xl md:text-5xl font-bold mb-6">
              Pronto para construir seu
              <span className="bg-gradient-to-r from-blue-400 to-purple-400 bg-clip-text text-transparent"> portfólio?</span>
            </h2>
            <p className="text-xl text-white/80 mb-8 max-w-2xl mx-auto">
              Junte-se à comunidade Syntropy e registre cada passo da sua evolução profissional, acadêmica e empreendedora.
            </p>
            <div className="flex flex-col sm:flex-row gap-4 justify-center">
              <Button
                size="lg"
                className="bg-blue-600 hover:bg-blue-700 text-white px-12 py-4 text-lg"
                onClick={handleCtaClick}
                disabled={loading}
              >
                Crie seu portfólio
              </Button>
            </div>
          </div>
        </div>
      </AnimatedSection>
    </div>
  )
}
