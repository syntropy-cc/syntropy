"use client"

import type React from "react"
import { useRef } from "react"
import { motion, useInView } from "framer-motion"
import { Button } from "@/components/ui/button"
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card"
import { Badge } from "@/components/ui/badge"
import { Accordion, AccordionContent, AccordionItem, AccordionTrigger } from "@/components/ui/accordion"
import {
  Code,
  Users,
  Search,
  GitBranch,
  Star,
  Award,
  Building,
  CheckCircle,
  Zap,
  BookOpen,
  FlaskConical,
  User,
  Target,
  Layers,
  Globe,
} from "lucide-react"
import Link from "next/link"

// Project Hub Visualization Component
function ProjectHubVisualization() {
  return (
    <div className="bg-white/10 backdrop-blur-sm rounded-2xl p-8 border border-white/20 h-full">
      <div className="flex items-center gap-3 mb-6">
        <Code className="h-8 w-8 text-blue-400" />
        <h3 className="text-2xl font-semibold text-white">Hub de Projetos</h3>
      </div>

      <div className="space-y-6 text-white/80">
        <div className="space-y-4">
          <h4 className="text-lg font-medium text-white">🔍 Descoberta Inteligente</h4>
          <p className="leading-relaxed">
            Encontre projetos alinhados com suas habilidades e interesses através de algoritmos de matching avançados.
          </p>
        </div>

        <div className="space-y-4">
          <h4 className="text-lg font-medium text-white">🤝 Contribuição Guiada</h4>
          <p className="leading-relaxed">
            Sistema de onboarding que facilita suas primeiras contribuições com mentoria integrada.
          </p>
        </div>

        <div className="space-y-4">
          <h4 className="text-lg font-medium text-white">💰 Funding Transparente</h4>
          <p className="leading-relaxed">
            Mecanismos de financiamento que conectam projetos promissores com investidores e empresas.
          </p>
        </div>
      </div>
    </div>
  )
}

// Collaboration Network Component
function CollaborationNetwork() {
  return (
    <div className="bg-white/10 backdrop-blur-sm rounded-2xl p-8 border border-white/20 h-full">
      <div className="flex items-center gap-3 mb-6">
        <Users className="h-8 w-8 text-blue-400" />
        <h3 className="text-2xl font-semibold text-white">Rede Colaborativa</h3>
      </div>

      <div className="space-y-4 mb-6">
        <p className="text-white/80 leading-relaxed">
          Conecte-se com desenvolvedores, mantenedores e empresas em um ecossistema colaborativo único.
        </p>

        <div className="flex flex-wrap gap-2">
          <Badge className="bg-green-600 text-white">✓ Matching por Skills</Badge>
          <Badge className="bg-blue-600 text-white">✓ Mentoria Integrada</Badge>
          <Badge className="bg-purple-600 text-white">✓ Reconhecimento</Badge>
        </div>
      </div>

      {/* Network Visualization */}
      <div className="bg-slate-900 rounded-xl border border-slate-700 overflow-hidden p-6">
        <div className="relative h-40">
          {/* Central Hub */}
          <div className="absolute top-1/2 left-1/2 transform -translate-x-1/2 -translate-y-1/2 w-12 h-12 bg-blue-600 rounded-full flex items-center justify-center">
            <Code className="h-6 w-6 text-white" />
          </div>

          {/* Connected Nodes */}
          {[
            { top: "20%", left: "20%", color: "bg-green-500", icon: User },
            { top: "20%", right: "20%", color: "bg-purple-500", icon: Building },
            { bottom: "20%", left: "20%", color: "bg-yellow-500", icon: Star },
            { bottom: "20%", right: "20%", color: "bg-red-500", icon: Award },
          ].map((node, index) => {
            const Icon = node.icon
            return (
              <motion.div
                key={index}
                className={`absolute w-8 h-8 ${node.color} rounded-full flex items-center justify-center`}
                style={{
                  top: node.top,
                  left: node.left,
                  right: node.right,
                  bottom: node.bottom,
                }}
                animate={{ scale: [1, 1.2, 1] }}
                transition={{
                  duration: 2,
                  repeat: Number.POSITIVE_INFINITY,
                  delay: index * 0.5,
                }}
              >
                <Icon className="h-4 w-4 text-white" />
              </motion.div>
            )
          })}

          {/* Connection Lines */}
          <svg className="absolute inset-0 w-full h-full">
            <line x1="50%" y1="50%" x2="20%" y2="20%" stroke="#3b82f6" strokeWidth="2" opacity="0.5" />
            <line x1="50%" y1="50%" x2="80%" y2="20%" stroke="#3b82f6" strokeWidth="2" opacity="0.5" />
            <line x1="50%" y1="50%" x2="20%" y2="80%" stroke="#3b82f6" strokeWidth="2" opacity="0.5" />
            <line x1="50%" y1="50%" x2="80%" y2="80%" stroke="#3b82f6" strokeWidth="2" opacity="0.5" />
          </svg>
        </div>
      </div>
    </div>
  )
}

// Integration Showcase Component
function IntegrationShowcase() {
  return (
    <div className="relative w-80 h-96 bg-gradient-to-br from-slate-800 to-slate-900 rounded-xl border border-slate-700 overflow-hidden">
      {/* Header */}
      <div className="p-4 border-b border-slate-700">
        <div className="flex items-center gap-3">
          <div className="w-10 h-10 bg-blue-600 rounded-full flex items-center justify-center text-white font-bold">
            SP
          </div>
          <div>
            <h3 className="text-white font-semibold">Syntropy Projects</h3>
            <p className="text-slate-400 text-sm">Ecossistema Integrado</p>
          </div>
        </div>
      </div>

      {/* Integration Cards */}
      <div className="p-4 space-y-3">
        <div className="bg-slate-700/50 rounded-lg p-3">
          <div className="flex items-center gap-3">
            <BookOpen className="h-5 w-5 text-blue-400" />
            <div>
              <h4 className="text-white font-medium">Learn Integration</h4>
              <p className="text-slate-400 text-sm">Tarefas práticas dos cursos</p>
            </div>
          </div>
        </div>

        <div className="bg-slate-700/50 rounded-lg p-3">
          <div className="flex items-center gap-3">
            <FlaskConical className="h-5 w-5 text-purple-400" />
            <div>
              <h4 className="text-white font-medium">Labs Integration</h4>
              <p className="text-slate-400 text-sm">Proof-of-concepts → Projetos</p>
            </div>
          </div>
        </div>

        <div className="bg-slate-700/50 rounded-lg p-3">
          <div className="flex items-center gap-3">
            <User className="h-5 w-5 text-green-400" />
            <div>
              <h4 className="text-white font-medium">Portfolio Integration</h4>
              <p className="text-slate-400 text-sm">Contribuições automáticas</p>
            </div>
          </div>
        </div>
      </div>

      {/* Stats */}
      <div className="absolute bottom-4 left-4 right-4">
        <div className="grid grid-cols-3 gap-4 text-center">
          <div>
            <div className="text-blue-400 font-bold text-lg">150+</div>
            <div className="text-slate-400 text-xs">Projetos</div>
          </div>
          <div>
            <div className="text-green-400 font-bold text-lg">2.5k</div>
            <div className="text-slate-400 text-xs">Contributors</div>
          </div>
          <div>
            <div className="text-purple-400 font-bold text-lg">$50k</div>
            <div className="text-slate-400 text-xs">Funding</div>
          </div>
        </div>
      </div>
    </div>
  )
}

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

export default function ProjectsLandingPage() {
  const faqItems = [
    {
      question: "Como funciona o sistema de matching de projetos?",
      answer:
        "Nosso algoritmo analisa suas habilidades, interesses e histórico de contribuições para sugerir projetos alinhados com seu perfil. Quanto mais você usa a plataforma, mais precisas ficam as recomendações.",
    },
    {
      question: "Posso criar meu próprio projeto na plataforma?",
      answer:
        "Sim! Qualquer usuário pode propor e criar projetos. Oferecemos templates, ferramentas de gestão e suporte para ajudar você a estruturar e promover seu projeto na comunidade.",
    },
    {
      question: "Como funciona o sistema de funding?",
      answer:
        "Projetos podem receber financiamento através de doações da comunidade, patrocínios corporativos ou investimentos. Todo o processo é transparente e os fundos são distribuídos automaticamente conforme as contribuições.",
    },
    {
      question: "Que tipo de reconhecimento recebo por contribuir?",
      answer:
        "Suas contribuições geram badges verificáveis, pontos de reputação, certificados de participação e são automaticamente adicionadas ao seu portfólio. Contribuições significativas podem resultar em convites para mentoria.",
    },
    {
      question: "Como os projetos se integram com Learn e Labs?",
      answer:
        "Projetos podem originar tarefas práticas para cursos (Learn) ou evoluir de experimentos (Labs). Essa integração cria um ciclo completo de aprendizado, experimentação e aplicação prática.",
    },
  ]

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
            <h1 className="text-5xl md:text-7xl font-bold mb-8 mt-8">
              <span className="text-blue-400">Construa.</span> <span className="text-white">Colabore.</span>{" "}
              <span className="text-blue-400">Evolua.</span>
            </h1>
          </motion.div>

          <motion.p
            className="text-xl md:text-2xl text-white/80 mb-20 max-w-4xl mx-auto leading-relaxed"
            initial={{ opacity: 0, y: 30 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ delay: 0.5, duration: 0.8 }}
          >
            O hub central para descobrir, contribuir e evoluir projetos open-source no ecossistema Syntropy.
          </motion.p>

          <motion.div
            className="flex flex-col sm:flex-row gap-4 justify-center mb-16"
            initial={{ opacity: 0, y: 50 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ delay: 1, duration: 0.8 }}
          >
            <Button asChild size="lg" className="bg-blue-600 hover:bg-blue-700 text-white px-8 py-4 text-lg">
              <Link href="/auth?mode=signup">Começar a contribuir</Link>
            </Button>
            <Button
              asChild
              variant="outline"
              size="lg"
              className="border-white/20 text-white hover:bg-white/10 px-8 py-4 text-lg"
            >
              <Link href="/projects/coming-soon">Explorar projetos</Link>
            </Button>
          </motion.div>

          {/* Enhanced Two-Column Layout */}
          <motion.div
            className="grid lg:grid-cols-2 gap-8 max-w-7xl mx-auto"
            initial={{ opacity: 0, y: 50 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ delay: 1.2, duration: 0.8 }}
          >
            {/* Left Column - Project Hub */}
            <motion.div
              initial={{ opacity: 0, x: -50 }}
              animate={{ opacity: 1, x: 0 }}
              transition={{ delay: 1.4, duration: 0.8 }}
            >
              <ProjectHubVisualization />
            </motion.div>

            {/* Right Column - Collaboration Network */}
            <motion.div
              initial={{ opacity: 0, x: 50 }}
              animate={{ opacity: 1, x: 0 }}
              transition={{ delay: 1.6, duration: 0.8 }}
            >
              <CollaborationNetwork />
            </motion.div>
          </motion.div>
        </div>
      </section>

      {/* How it Works Section */}
      <AnimatedSection className="bg-white/5 pt-32">
        <div className="container mx-auto">
          <div className="text-center mb-16">
            <h2 className="text-4xl md:text-5xl font-bold mb-6">Como funciona</h2>
          </div>

          <div className="grid md:grid-cols-3 gap-12 max-w-6xl mx-auto">
            {[
              {
                number: "1",
                icon: Search,
                title: "Descubra projetos",
                description: "Encontre projetos alinhados com suas habilidades e interesses.",
              },
              {
                number: "2",
                icon: GitBranch,
                title: "Contribua e colabore",
                description: "Participe ativamente com mentoria e ferramentas integradas.",
              },
              {
                number: "3",
                icon: Star,
                title: "Ganhe reconhecimento",
                description: "Receba badges, reputação e oportunidades de crescimento.",
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

      {/* Benefits for Different Users Section */}
      <AnimatedSection>
        <div className="container mx-auto">
          <div className="text-center mb-16">
            <h2 className="text-4xl md:text-5xl font-bold mb-6">Benefícios para todos</h2>
          </div>

          <div className="grid md:grid-cols-3 gap-8 max-w-6xl mx-auto">
            {[
              {
                icon: User,
                title: "Para Contributors",
                benefits: [
                  "Matching inteligente de projetos",
                  "Sistema de reconhecimento e badges",
                  "Mentoria e desenvolvimento de skills",
                  "Networking com a comunidade",
                ],
                cta: "Começar a contribuir",
              },
              {
                icon: Code,
                title: "Para Maintainers",
                benefits: [
                  "Ferramentas centralizadas de gestão",
                  "Onboarding automatizado de contributors",
                  "Sistema de funding integrado",
                  "Analytics e métricas detalhadas",
                ],
                cta: "Criar projeto",
              },
              {
                icon: Building,
                title: "Para Empresas",
                benefits: [
                  "Acesso a soluções maduras",
                  "Identificação de talentos",
                  "Oportunidades de patrocínio",
                  "Integração com equipes internas",
                ],
                cta: "Explorar parcerias",
              },
            ].map((userType, index) => {
              const Icon = userType.icon
              return (
                <motion.div
                  key={userType.title}
                  initial={{ opacity: 0, y: 50 }}
                  whileInView={{ opacity: 1, y: 0 }}
                  transition={{ delay: index * 0.1, duration: 0.6 }}
                  className="h-full"
                >
                  <Card className="bg-white/10 backdrop-blur-sm border-white/20 h-full hover:bg-white/15 transition-colors flex flex-col">
                    <CardHeader className="text-center">
                      <div className="w-12 h-12 bg-blue-600 rounded-lg flex items-center justify-center mx-auto mb-4">
                        <Icon className="h-6 w-6 text-white" />
                      </div>
                      <CardTitle className="text-white">{userType.title}</CardTitle>
                    </CardHeader>
                    <CardContent className="flex flex-col flex-1">
                      <div className="space-y-3 flex-1">
                        {userType.benefits.map((benefit, idx) => (
                          <div key={idx} className="flex items-center gap-3">
                            <CheckCircle className="h-4 w-4 text-blue-400 flex-shrink-0" />
                            <span className="text-white/80 text-sm">{benefit}</span>
                          </div>
                        ))}
                      </div>
                      <div className="mt-6">
                        <Button className="w-full bg-blue-600 hover:bg-blue-700 text-white">{userType.cta}</Button>
                      </div>
                    </CardContent>
                  </Card>
                </motion.div>
              )
            })}
          </div>
        </div>
      </AnimatedSection>

      {/* Integration with Syntropy Ecosystem */}
      <AnimatedSection className="bg-white/5">
        <div className="container mx-auto">
          <div className="text-center mb-16">
            <h2 className="text-4xl md:text-5xl font-bold mb-6">Integração total com o ecossistema Syntropy</h2>
            <p className="text-xl text-white/70 max-w-3xl mx-auto">
              Projects se conecta perfeitamente com Learn, Labs e Portfolio, criando um ciclo completo de
              desenvolvimento.
            </p>
          </div>

          <div className="grid lg:grid-cols-2 gap-16 items-center max-w-6xl mx-auto">
            <div>
              <div className="space-y-8">
                {[
                  {
                    icon: BookOpen,
                    title: "Learn → Projects",
                    description:
                      "Tarefas práticas dos cursos se transformam em contribuições reais para projetos open-source.",
                  },
                  {
                    icon: FlaskConical,
                    title: "Labs → Projects",
                    description: "Experimentos e proof-of-concepts evoluem para projetos completos com a comunidade.",
                  },
                  {
                    icon: User,
                    title: "Projects → Portfolio",
                    description:
                      "Todas as contribuições são automaticamente documentadas no seu portfólio profissional.",
                  },
                ].map((integration, index) => {
                  const Icon = integration.icon
                  return (
                    <motion.div
                      key={integration.title}
                      className="flex items-start gap-4"
                      initial={{ opacity: 0, x: -20 }}
                      whileInView={{ opacity: 1, x: 0 }}
                      transition={{ delay: index * 0.2, duration: 0.6 }}
                    >
                      <div className="w-12 h-12 bg-blue-600 rounded-lg flex items-center justify-center flex-shrink-0">
                        <Icon className="h-6 w-6 text-white" />
                      </div>
                      <div>
                        <h3 className="text-xl font-semibold text-white mb-2">{integration.title}</h3>
                        <p className="text-white/70">{integration.description}</p>
                      </div>
                    </motion.div>
                  )
                })}
              </div>
            </div>
            <div className="flex justify-center">
              <IntegrationShowcase />
            </div>
          </div>
        </div>
      </AnimatedSection>

      {/* Project Categories Section */}
      <AnimatedSection>
        <div className="container mx-auto">
          <div className="text-center mb-16">
            <h2 className="text-4xl md:text-5xl font-bold mb-6">Categorias de projetos</h2>
          </div>

          <div className="grid md:grid-cols-2 lg:grid-cols-4 gap-6 max-w-7xl mx-auto">
            {[
              {
                icon: Globe,
                title: "Web & Mobile",
                description: "Apps, sites e soluções digitais",
              },
              {
                icon: Zap,
                title: "DevTools",
                description: "Ferramentas para desenvolvedores",
              },
              {
                icon: Layers,
                title: "Infrastructure",
                description: "Soluções de infraestrutura",
              },
              {
                icon: Target,
                title: "AI & ML",
                description: "Inteligência artificial e ML",
              },
            ].map((category, index) => {
              const Icon = category.icon
              return (
                <motion.div
                  key={category.title}
                  initial={{ opacity: 0, y: 50 }}
                  whileInView={{ opacity: 1, y: 0 }}
                  transition={{ delay: index * 0.1, duration: 0.6 }}
                >
                  <Card className="bg-white/10 backdrop-blur-sm border-white/20 h-full hover:bg-white/15 transition-colors cursor-pointer">
                    <CardHeader className="text-center">
                      <div className="w-12 h-12 bg-blue-600 rounded-lg flex items-center justify-center mx-auto mb-4">
                        <Icon className="h-6 w-6 text-white" />
                      </div>
                      <CardTitle className="text-white">{category.title}</CardTitle>
                      <CardDescription className="text-white/70">{category.description}</CardDescription>
                    </CardHeader>
                    <CardContent>{/* Conteúdo removido */}</CardContent>
                  </Card>
                </motion.div>
              )
            })}
          </div>
        </div>
      </AnimatedSection>

      {/* FAQ Section */}
      <AnimatedSection>
        <div className="container mx-auto">
          <div className="text-center mb-16">
            <h2 className="text-4xl md:text-5xl font-bold mb-6">Perguntas frequentes</h2>
          </div>

          <div className="max-w-4xl mx-auto">
            <Accordion type="single" collapsible className="space-y-4">
              {faqItems.map((item, index) => (
                <AccordionItem
                  key={index}
                  value={`item-${index}`}
                  className="bg-white/10 backdrop-blur-sm border-white/20 rounded-lg px-6"
                >
                  <AccordionTrigger className="text-white hover:text-blue-400 text-left">
                    {item.question}
                  </AccordionTrigger>
                  <AccordionContent className="text-white/80">{item.answer}</AccordionContent>
                </AccordionItem>
              ))}
            </Accordion>
          </div>
        </div>
      </AnimatedSection>

      {/* CTA Section */}
      <AnimatedSection className="bg-white/5">
        <div className="container mx-auto">
          <div className="text-center max-w-4xl mx-auto">
            <h2 className="text-4xl md:text-5xl font-bold mb-6">
              Pronto para fazer parte da{" "}
              <span className="bg-gradient-to-r from-blue-400 to-purple-400 bg-clip-text text-transparent">
                revolução open-source?
              </span>
            </h2>
            <p className="text-xl text-white/80 mb-8 max-w-2xl mx-auto">
              Junte-se a milhares de desenvolvedores que já estão construindo o futuro através de projetos
              colaborativos.
            </p>
            <div className="flex flex-col sm:flex-row gap-4 justify-center">
              <Button asChild size="lg" className="bg-blue-600 hover:bg-blue-700 text-white px-12 py-4 text-lg">
                <Link href="/auth?mode=signup">Começar a contribuir</Link>
              </Button>
              <Button
                asChild
                variant="outline"
                size="lg"
                className="border-white/20 text-white hover:bg-white/10 px-12 py-4 text-lg"
              >
                <Link href="/projects/coming-soon">Explorar projetos</Link>
              </Button>
            </div>
          </div>
        </div>
      </AnimatedSection>
    </div>
  )
}
