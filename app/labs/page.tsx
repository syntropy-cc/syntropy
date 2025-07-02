"use client"

import type React from "react"
import { useRef } from "react"
import { motion, useInView } from "framer-motion"
import { Button } from "@/components/ui/button"
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card"
import { Badge } from "@/components/ui/badge"
import { Accordion, AccordionContent, AccordionItem, AccordionTrigger } from "@/components/ui/accordion"
import {
  FlaskConical,
  Users,
  Calendar,
  Kanban,
  FileText,
  Award,
  CheckCircle,
  Zap,
  BookOpen,
  Code,
  User,
  Share,
  ArrowRight,
  Microscope,
  Building,
} from "lucide-react"
import Link from "next/link"

// Laboratory Environment Component
function LaboratoryEnvironment() {
  return (
    <div className="bg-white/10 backdrop-blur-sm rounded-2xl p-8 border border-white/20 h-full">
      <div className="flex items-center gap-3 mb-6">
        <FlaskConical className="h-8 w-8 text-blue-400" />
        <h3 className="text-2xl font-semibold text-white">Laboratórios Temáticos</h3>
      </div>

      <div className="space-y-6 text-white/80">
        <div className="space-y-4">
          <h4 className="text-lg font-medium text-white">🔬 Ambiente Colaborativo</h4>
          <p className="leading-relaxed">
            Crie laboratórios especializados com ferramentas integradas para pesquisa científica e tecnológica.
          </p>
        </div>

        <div className="space-y-4">
          <h4 className="text-lg font-medium text-white">📊 Gestão de Projetos</h4>
          <p className="leading-relaxed">
            Organize pesquisas com calendário, Kanban e ferramentas de acompanhamento de progresso.
          </p>
        </div>

        <div className="space-y-4">
          <h4 className="text-lg font-medium text-white">📝 Publicação Científica</h4>
          <p className="leading-relaxed">
            Transforme pesquisas em artigos científicos com sistema de peer-review integrado.
          </p>
        </div>
      </div>
    </div>
  )
}

// Research Tools Component
function ResearchTools() {
  return (
    <div className="bg-white/10 backdrop-blur-sm rounded-2xl p-8 border border-white/20 h-full">
      <div className="flex items-center gap-3 mb-6">
        <Microscope className="h-8 w-8 text-blue-400" />
        <h3 className="text-2xl font-semibold text-white">Ferramentas de Pesquisa</h3>
      </div>

      <div className="space-y-4 mb-6">
        <p className="text-white/80 leading-relaxed">
          Suite completa de ferramentas para conduzir pesquisas científicas e tecnológicas de forma colaborativa.
        </p>

        <div className="flex flex-wrap gap-2">
          <Badge className="bg-green-600 text-white">✓ Calendar Integration</Badge>
          <Badge className="bg-blue-600 text-white">✓ Kanban Boards</Badge>
          <Badge className="bg-purple-600 text-white">✓ Peer Review</Badge>
        </div>
      </div>

      {/* Research Dashboard */}
      <div className="bg-slate-900 rounded-xl border border-slate-700 overflow-hidden">
        {/* Dashboard Header */}
        <div className="h-10 bg-slate-800 flex items-center px-4 gap-2 border-b border-slate-700">
          <div className="w-3 h-3 bg-red-500 rounded-full"></div>
          <div className="w-3 h-3 bg-yellow-500 rounded-full"></div>
          <div className="w-3 h-3 bg-green-500 rounded-full"></div>
          <span className="text-xs text-slate-400 ml-2">AI Research Lab</span>
        </div>

        {/* Dashboard Content */}
        <div className="p-6 min-h-[200px]">
          <div className="grid grid-cols-3 gap-4 mb-4">
            <div className="bg-slate-700/50 rounded-lg p-3 text-center">
              <Calendar className="h-5 w-5 text-blue-400 mx-auto mb-1" />
              <div className="text-white text-sm font-medium">Calendar</div>
            </div>
            <div className="bg-slate-700/50 rounded-lg p-3 text-center">
              <Kanban className="h-5 w-5 text-green-400 mx-auto mb-1" />
              <div className="text-white text-sm font-medium">Kanban</div>
            </div>
            <div className="bg-slate-700/50 rounded-lg p-3 text-center">
              <FileText className="h-5 w-5 text-purple-400 mx-auto mb-1" />
              <div className="text-white text-sm font-medium">Articles</div>
            </div>
          </div>

          <div className="space-y-2">
            <div className="bg-slate-700/30 rounded p-2">
              <div className="text-white text-sm">📊 Neural Network Optimization</div>
              <div className="text-slate-400 text-xs">In Progress • 3 researchers</div>
            </div>
            <div className="bg-slate-700/30 rounded p-2">
              <div className="text-white text-sm">🔍 Computer Vision Analysis</div>
              <div className="text-slate-400 text-xs">Review Phase • 5 researchers</div>
            </div>
          </div>
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
          <div className="w-10 h-10 bg-purple-600 rounded-full flex items-center justify-center text-white font-bold">
            SL
          </div>
          <div>
            <h3 className="text-white font-semibold">Syntropy Labs</h3>
            <p className="text-slate-400 text-sm">Ecossistema Científico</p>
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
              <p className="text-slate-400 text-sm">Formação científica contínua</p>
            </div>
          </div>
        </div>

        <div className="bg-slate-700/50 rounded-lg p-3">
          <div className="flex items-center gap-3">
            <Code className="h-5 w-5 text-green-400" />
            <div>
              <h4 className="text-white font-medium">Projects Integration</h4>
              <p className="text-slate-400 text-sm">Pesquisa → Desenvolvimento</p>
            </div>
          </div>
        </div>

        <div className="bg-slate-700/50 rounded-lg p-3">
          <div className="flex items-center gap-3">
            <User className="h-5 w-5 text-purple-400" />
            <div>
              <h4 className="text-white font-medium">Portfolio Integration</h4>
              <p className="text-slate-400 text-sm">Currículo científico</p>
            </div>
          </div>
        </div>
      </div>

      {/* Stats */}
      <div className="absolute bottom-4 left-4 right-4">
        <div className="grid grid-cols-3 gap-4 text-center">
          <div>
            <div className="text-blue-400 font-bold text-lg">25+</div>
            <div className="text-slate-400 text-xs">Labs</div>
          </div>
          <div>
            <div className="text-green-400 font-bold text-lg">150</div>
            <div className="text-slate-400 text-xs">Researchers</div>
          </div>
          <div>
            <div className="text-purple-400 font-bold text-lg">80</div>
            <div className="text-slate-400 text-xs">Articles</div>
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

export default function LabsLandingPage() {
  const faqItems = [
    {
      question: "Como funciona o sistema de peer-review?",
      answer:
        "Nosso sistema de peer-review é baseado em prestígio da comunidade. Pesquisadores com maior reputação e contribuições verificadas têm maior peso nas avaliações. O processo é transparente e todos os comentários são registrados.",
    },
    {
      question: "Posso criar meu próprio laboratório?",
      answer:
        "Sim! Qualquer usuário pode propor e criar laboratórios temáticos. Oferecemos templates, ferramentas de gestão e suporte para estruturar seu laboratório e atrair colaboradores da comunidade científica.",
    },
    {
      question: "Como os Labs se integram com Learn e Projects?",
      answer:
        "Labs se conecta perfeitamente: pesquisas podem originar cursos técnicos (Learn), evoluir para projetos de desenvolvimento (Projects), e todas as contribuições são documentadas no Portfolio científico.",
    },
    {
      question: "Que ferramentas estão disponíveis para pesquisa?",
      answer:
        "Cada laboratório inclui calendário integrado, quadros Kanban para gestão de projetos, ferramentas de colaboração, sistema de versionamento para artigos, e ambiente para análise de dados.",
    },
    {
      question: "Como funciona a publicação de artigos científicos?",
      answer:
        "Artigos passam por um processo estruturado: redação colaborativa, revisão interna do laboratório, submissão ao peer-review da comunidade, e publicação final com DOI. Todo o processo é transparente e rastreável.",
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
              <span className="bg-gradient-to-r from-blue-400 to-pink-400 bg-clip-text text-transparent">
            Pesquise. Inove. Publique.
              </span>
            </h1>
          </motion.div>

          <motion.p
            className="text-xl md:text-2xl text-white/80 mb-20 max-w-4xl mx-auto leading-relaxed"
            initial={{ opacity: 0, y: 30 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ delay: 0.5, duration: 0.8 }}
          >
            Laboratórios colaborativos para pesquisa científica e tecnológica com ferramentas integradas e peer-review
            da comunidade.
          </motion.p>

          <motion.div
            className="flex flex-col sm:flex-row gap-4 justify-center mb-16"
            initial={{ opacity: 0, y: 50 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ delay: 1, duration: 0.8 }}
          >
            <Button asChild size="lg" className="bg-blue-600 hover:bg-blue-700 text-white px-8 py-4 text-lg">
              <Link href="/labs/coming-soon">Criar laboratório</Link>
            </Button>
            <Button
              asChild
              variant="outline"
              size="lg"
              className="border-white/20 text-white hover:bg-white/10 px-8 py-4 text-lg"
            >
              <Link href="/labs/coming-soon">Explorar pesquisas</Link>
            </Button>
          </motion.div>

          {/* Enhanced Two-Column Layout */}
          <motion.div
            className="grid lg:grid-cols-2 gap-8 max-w-7xl mx-auto"
            initial={{ opacity: 0, y: 50 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ delay: 1.2, duration: 0.8 }}
          >
            {/* Left Column - Laboratory Environment */}
            <motion.div
              initial={{ opacity: 0, x: -50 }}
              animate={{ opacity: 1, x: 0 }}
              transition={{ delay: 1.4, duration: 0.8 }}
            >
              <LaboratoryEnvironment />
            </motion.div>

            {/* Right Column - Research Tools */}
            <motion.div
              initial={{ opacity: 0, x: 50 }}
              animate={{ opacity: 1, x: 0 }}
              transition={{ delay: 1.6, duration: 0.8 }}
            >
              <ResearchTools />
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
                icon: Building,
                title: "Crie ou junte-se a um laboratório",
                description: "Estabeleça laboratórios temáticos ou colabore com pesquisadores existentes.",
              },
              {
                number: "2",
                icon: Microscope,
                title: "Conduza pesquisas estruturadas",
                description: "Use ferramentas integradas para organizar e executar projetos de pesquisa.",
              },
              {
                number: "3",
                icon: FileText,
                title: "Publique com peer-review",
                description: "Transforme pesquisas em artigos científicos revisados pela comunidade.",
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

      {/* Why Choose Syntropy Labs Section */}
      <AnimatedSection>
        <div className="container mx-auto">
          <div className="text-center mb-16">
            <h2 className="text-4xl md:text-5xl font-bold mb-6">Por que escolher o Syntropy Labs?</h2>
          </div>

          <div className="grid md:grid-cols-2 lg:grid-cols-4 gap-6 max-w-7xl mx-auto">
            {[
              {
                icon: Users,
                title: "Colaboração Global",
                description: "Conecte-se com pesquisadores do mundo todo",
              },
              {
                icon: Zap,
                title: "Ferramentas Integradas",
                description: "Suite completa para gestão de pesquisa",
              },
              {
                icon: Award,
                title: "Peer-Review Qualificado",
                description: "Sistema baseado em prestígio da comunidade",
              },
              {
                icon: Share,
                title: "Integração Ecossistema",
                description: "Conectado com Learn, Projects e Portfolio",
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

      {/* Featured Research Areas Section */}
      <AnimatedSection className="bg-white/5">
        <div className="container mx-auto">
          <div className="text-center mb-16">
            <h2 className="text-4xl md:text-5xl font-bold mb-6">Áreas de pesquisa em destaque</h2>
          </div>

          <div className="grid md:grid-cols-2 lg:grid-cols-3 gap-8 max-w-6xl mx-auto mb-12">
            {[
              {
                title: "Inteligência Artificial",
                description:
                  "Desenvolvimento de algoritmos de aprendizado de máquina, redes neurais e sistemas inteligentes para resolver problemas complexos.",
                icon: "🤖",
              },
              {
                title: "Biotecnologia",
                description:
                  "Pesquisa em engenharia genética, bioinformática e desenvolvimento de soluções biotecnológicas inovadoras.",
                icon: "🧬",
              },
              {
                title: "Computação Quântica",
                description:
                  "Exploração de algoritmos quânticos, criptografia quântica e desenvolvimento de sistemas de computação quântica.",
                icon: "⚛️",
              },
              {
                title: "Ciência de Dados",
                description:
                  "Análise de big data, desenvolvimento de modelos preditivos e extração de insights de grandes volumes de dados.",
                icon: "📊",
              },
              {
                title: "Robótica",
                description:
                  "Desenvolvimento de sistemas robóticos autônomos, interação humano-robô e aplicações industriais.",
                icon: "🤖",
              },
              {
                title: "Sustentabilidade",
                description: "Pesquisa em energias renováveis, tecnologias verdes e soluções para mudanças climáticas.",
                icon: "🌱",
              },
            ].map((area, index) => (
              <motion.div
                key={area.title}
                initial={{ opacity: 0, y: 50 }}
                whileInView={{ opacity: 1, y: 0 }}
                transition={{ delay: index * 0.1, duration: 0.6 }}
              >
                <Card className="bg-white/10 backdrop-blur-sm border-white/20 h-full hover:bg-white/15 transition-colors">
                  <CardHeader>
                    <div className="flex items-center gap-3 mb-4">
                      <span className="text-3xl">{area.icon}</span>
                      <CardTitle className="text-white text-lg">{area.title}</CardTitle>
                    </div>
                  </CardHeader>
                  <CardContent>
                    <p className="text-white/70 text-sm leading-relaxed">{area.description}</p>
                  </CardContent>
                </Card>
              </motion.div>
            ))}
          </div>

          <div className="text-center">
            <Button asChild variant="outline" className="border-white/20 text-white hover:bg-white/10">
              <Link href="/labs/coming-soon">
                Explore todos os laboratórios <ArrowRight className="ml-2 h-4 w-4" />
              </Link>
            </Button>
          </div>
        </div>
      </AnimatedSection>

      {/* Integration with Syntropy Ecosystem */}
      <AnimatedSection>
        <div className="container mx-auto">
          <div className="grid lg:grid-cols-2 gap-16 items-center max-w-6xl mx-auto">
            <div>
              <h2 className="text-4xl md:text-5xl font-bold mb-6">Integração total com o ecossistema Syntropy</h2>
              <p className="text-xl text-white/80 mb-8 leading-relaxed">
                Labs se conecta perfeitamente com Learn, Projects e Portfolio, criando um ciclo completo de pesquisa,
                desenvolvimento e reconhecimento científico.
              </p>
              <div className="space-y-4 mb-8">
                {[
                  "Pesquisas geram cursos técnicos especializados",
                  "Descobertas evoluem para projetos de desenvolvimento",
                  "Publicações científicas no portfólio profissional",
                  "Colaboração interdisciplinar facilitada",
                ].map((item, index) => (
                  <motion.div
                    key={item}
                    className="flex items-center gap-3"
                    initial={{ opacity: 0, x: -20 }}
                    whileInView={{ opacity: 1, x: 0 }}
                    transition={{ delay: 0.2 + index * 0.1 }}
                  >
                    <CheckCircle className="h-5 w-5 text-blue-400" />
                    <span className="text-white/80">{item}</span>
                  </motion.div>
                ))}
              </div>
            </div>
            <div className="flex justify-center">
              <IntegrationShowcase />
            </div>
          </div>
        </div>
      </AnimatedSection>

      {/* Research vs Teaching Section
      <AnimatedSection className="bg-white/5">
        <div className="container mx-auto">
          <div className="grid md:grid-cols-2 gap-8 max-w-4xl mx-auto">
            <Card className="bg-white/10 backdrop-blur-sm border-white/20 hover:bg-white/15 transition-colors">
              <CardHeader className="text-center">
                <CardTitle className="text-white text-2xl mb-4">Para pesquisar</CardTitle>
                <CardDescription className="text-white/70 text-lg">
                  Conduza pesquisas científicas com ferramentas profissionais
                </CardDescription>
              </CardHeader>
              <CardContent className="text-center">
                <Button asChild className="w-full bg-blue-600 hover:bg-blue-700 text-white">
                  <Link href="/labs/coming-soon">Explorar laboratórios</Link>
                </Button>
              </CardContent>
            </Card>

            <Card className="bg-white/10 backdrop-blur-sm border-white/20 hover:bg-white/15 transition-colors">
              <CardHeader className="text-center">
                <CardTitle className="text-white text-2xl mb-4">Para liderar</CardTitle>
                <CardDescription className="text-white/70 text-lg">
                  Crie laboratórios e lidere equipes de pesquisa
                </CardDescription>
              </CardHeader>
              <CardContent className="text-center">
                <Button asChild variant="outline" className="w-full border-white/20 text-white hover:bg-white/10">
                  <Link href="/labs/coming-soon">Criar laboratório</Link>
                </Button>
              </CardContent>
            </Card>
          </div>
        </div>
      </AnimatedSection> */}

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
              Pronto para acelerar sua{" "}
              <span className="bg-gradient-to-r from-blue-400 to-purple-400 bg-clip-text text-transparent">
                pesquisa científica?
              </span>
            </h2>
            <p className="text-xl text-white/80 mb-8 max-w-2xl mx-auto">
              Junte-se a pesquisadores que já estão construindo o futuro da ciência e tecnologia com o Syntropy Labs.
            </p>
            <div className="flex flex-col sm:flex-row gap-4 justify-center">
              <Button asChild size="lg" className="bg-blue-600 hover:bg-blue-700 text-white px-12 py-4 text-lg">
                <Link href="/labs/coming-soon">Começar pesquisa</Link>
              </Button>
              <Button
                asChild
                variant="outline"
                size="lg"
                className="border-white/20 text-white hover:bg-white/10 px-12 py-4 text-lg"
              >
                <Link href="/labs/coming-soon">Explorar laboratórios</Link>
              </Button>
            </div>
          </div>
        </div>
      </AnimatedSection>
    </div>
  )
}
