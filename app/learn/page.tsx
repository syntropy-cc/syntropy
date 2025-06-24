"use client"

import type React from "react"
import { useRef } from "react"
import { motion, useInView } from "framer-motion"
import { Button } from "@/components/ui/button"
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card"
import { Badge } from "@/components/ui/badge"
import { Accordion, AccordionContent, AccordionItem, AccordionTrigger } from "@/components/ui/accordion"
import { Code, Upload, CheckCircle, Zap, Users, Award, Clock, ArrowRight, Laptop, Share, Target } from "lucide-react"
import Link from "next/link"

// JupyterBook-style Content Component
function JupyterBookContent() {
  return (
    <div className="bg-white/10 backdrop-blur-sm rounded-2xl p-8 border border-white/20 h-full">
      <div className="flex items-center gap-3 mb-6">
        <Laptop className="h-8 w-8 text-blue-400" />
        <h3 className="text-2xl font-semibold text-white">Aprenda conceitos</h3>
      </div>

      <div className="space-y-6 text-white/80">
        <div className="space-y-4">
          <h4 className="text-lg font-medium text-white">📚 Conteúdo Interativo</h4>
          <p className="leading-relaxed">
            Explore conceitos fundamentais através de explicações claras, exemplos práticos e exercícios guiados.
          </p>
        </div>

        <div className="space-y-4">
          <h4 className="text-lg font-medium text-white">🎯 Aprendizado Estruturado</h4>
          <p className="leading-relaxed">
            Siga uma trilha de aprendizado cuidadosamente planejada, do básico ao avançado.
          </p>
        </div>

        <div className="space-y-4">
          <h4 className="text-lg font-medium text-white">💡 Teoria na Prática</h4>
          <p className="leading-relaxed">
            Cada conceito é acompanhado de exemplos práticos que você pode testar imediatamente.
          </p>
        </div>
      </div>
    </div>
  )
}

// Enhanced IDE Section Component
function IDESection() {
  return (
    <div className="bg-white/10 backdrop-blur-sm rounded-2xl p-8 border border-white/20 h-full">
      <div className="flex items-center gap-3 mb-6">
        <Code className="h-8 w-8 text-blue-400" />
        <h3 className="text-2xl font-semibold text-white">Codifique na IDE</h3>
      </div>

      <div className="space-y-4 mb-6">
        <p className="text-white/80 leading-relaxed">
          Pratique imediatamente o que aprendeu em nossa IDE integrada. Sem instalações, sem configurações.
        </p>

        <div className="flex flex-wrap gap-2">
          <Badge className="bg-green-600 text-white">✓ Syntax Highlighting</Badge>
          <Badge className="bg-blue-600 text-white">✓ Auto-complete</Badge>
          <Badge className="bg-purple-600 text-white">✓ Live Preview</Badge>
        </div>
      </div>

      {/* Embedded IDE */}
      <div className="bg-slate-900 rounded-xl border border-slate-700 overflow-hidden">
        {/* IDE Header */}
        <div className="h-10 bg-slate-800 flex items-center px-4 gap-2 border-b border-slate-700">
          <div className="w-3 h-3 bg-red-500 rounded-full"></div>
          <div className="w-3 h-3 bg-yellow-500 rounded-full"></div>
          <div className="w-3 h-3 bg-green-500 rounded-full"></div>
          <span className="text-xs text-slate-400 ml-2">main.js</span>
        </div>

        {/* Code Content */}
        <div className="p-6 font-mono text-sm min-h-[200px]">
          <div className="text-blue-400">
            <span className="text-purple-400">function</span> <span className="text-yellow-400">App</span>() {"{"}
          </div>
          <div className="text-slate-300 ml-4 mt-2">
            <span className="text-purple-400">return</span> (
          </div>
          <div className="text-slate-300 ml-8 mt-1">
            <span className="text-green-400">&lt;h1&gt;</span>
            <span className="text-slate-300">Hello World</span>
            <span className="text-green-400">&lt;/h1&gt;</span>
          </div>
          <div className="text-slate-300 ml-4 mt-1">);</div>
          <div className="text-blue-400 mt-2">{"}"}</div>

          <div className="mt-4 text-slate-500">
            <span className="text-gray-500">// Experimente modificar o código acima</span>
          </div>
        </div>

        {/* IDE Footer */}
        <div className="h-8 bg-slate-800 flex items-center px-4 border-t border-slate-700">
          <div className="flex items-center gap-4 text-xs text-slate-400">
            <span>✓ Pronto para executar</span>
            <span>JavaScript</span>
            <span>UTF-8</span>
          </div>
        </div>
      </div>
    </div>
  )
}

// Portfolio Preview Component
function PortfolioPreview() {
  return (
    <div className="relative w-80 h-96 bg-gradient-to-br from-slate-800 to-slate-900 rounded-xl border border-slate-700 overflow-hidden">
      {/* Header */}
      <div className="p-4 border-b border-slate-700">
        <div className="flex items-center gap-3">
          <div className="w-10 h-10 bg-blue-600 rounded-full flex items-center justify-center text-white font-bold">
            JS
          </div>
          <div>
            <h3 className="text-white font-semibold">João Silva</h3>
            <p className="text-slate-400 text-sm">Desenvolvedor Full Stack</p>
          </div>
        </div>

        {/* Tech Stack */}
        <div className="flex gap-2 mt-3">
          <Badge className="bg-blue-600 text-white">React</Badge>
          <Badge className="bg-green-600 text-white">Node.js</Badge>
          <Badge className="bg-purple-600 text-white">Python</Badge>
        </div>
      </div>

      {/* Projects */}
      <div className="p-4 space-y-3">
        <div className="bg-slate-700/50 rounded-lg p-3">
          <div className="flex justify-between items-center">
            <div>
              <h4 className="text-white font-medium">Sistema de E-commerce</h4>
              <p className="text-slate-400 text-sm">React + Node.js</p>
            </div>
            <div className="w-2 h-2 bg-green-500 rounded-full"></div>
          </div>
        </div>

        <div className="bg-slate-700/50 rounded-lg p-3">
          <div className="flex justify-between items-center">
            <div>
              <h4 className="text-white font-medium">API de Gestão</h4>
              <p className="text-slate-400 text-sm">Python + FastAPI</p>
            </div>
            <div className="w-2 h-2 bg-yellow-500 rounded-full"></div>
          </div>
        </div>
      </div>

      {/* Stats */}
      <div className="absolute bottom-4 left-4 right-4">
        <div className="grid grid-cols-3 gap-4 text-center">
          <div>
            <div className="text-blue-400 font-bold text-lg">12</div>
            <div className="text-slate-400 text-xs">Projetos</div>
          </div>
          <div>
            <div className="text-green-400 font-bold text-lg">156</div>
            <div className="text-slate-400 text-xs">Commits</div>
          </div>
          <div>
            <div className="text-purple-400 font-bold text-lg">8</div>
            <div className="text-slate-400 text-xs">Cursos</div>
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

export default function LearnLandingPage() {
  const faqItems = [
    {
      question: "Quanto custa para usar a plataforma?",
      answer:
        "A plataforma Syntropy é completamente gratuita! Acreditamos que o conhecimento deve ser acessível a todos. Você pode acessar todos os cursos, usar a IDE integrada e publicar seus projetos sem nenhum custo.",
    },
    {
      question: "Preciso instalar algum software?",
      answer:
        "Não! Essa é uma das principais vantagens do Syntropy. Tudo funciona diretamente no seu navegador - IDE, compiladores, ferramentas de desenvolvimento. Você só precisa de uma conexão com a internet.",
    },
    {
      question: "O código que escrevo é meu?",
      answer:
        "Sim, absolutamente! Todo o código que você escreve na plataforma pertence a você. Você pode baixar, compartilhar e usar seus projetos como quiser. Mantemos apenas uma cópia para funcionalidades da plataforma.",
    },
    {
      question: "Como funciona a publicação de projetos?",
      answer:
        "Com apenas um clique, seus projetos são automaticamente publicados no seu portfólio público. Eles ficam disponíveis com URL própria e podem receber feedback da comunidade. Você também pode conectar com GitHub.",
    },
    {
      question: "Posso me tornar mentor na plataforma?",
      answer:
        "Sim! Após completar alguns cursos e demonstrar conhecimento, você pode se candidatar para ser mentor. Mentores ajudam outros estudantes, criam conteúdo e ganham reconhecimento na comunidade.",
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
              <span className="text-blue-400">Aprenda.</span> <span className="text-white">Codifique.</span>{" "}
              <span className="text-blue-400">Publique.</span>
            </h1>
          </motion.div>

          <motion.p
            className="text-xl md:text-2xl text-white/80 mb-20 max-w-4xl mx-auto leading-relaxed"
            initial={{ opacity: 0, y: 30 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ delay: 0.5, duration: 0.8 }}
          >
            IDE pronta, trilhas práticas e comunidade open source em um só lugar para acelerar seu aprendizado.
          </motion.p>

          <motion.div
            className="flex flex-col sm:flex-row gap-4 justify-center mb-16"
            initial={{ opacity: 0, y: 50 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ delay: 1, duration: 0.8 }}
          >
            <Button asChild size="lg" className="bg-blue-600 hover:bg-blue-700 text-white px-8 py-4 text-lg">
              <Link href="/auth?mode=signup">Criar conta grátis em 2 min</Link>
            </Button>
            <Button
              asChild
              variant="outline"
              size="lg"
              className="border-white/20 text-white hover:bg-white/10 px-8 py-4 text-lg"
            >
              <Link href="/learn/courses">Explorar cursos</Link>
            </Button>
          </motion.div>

          {/* Enhanced Two-Column Layout */}
          <motion.div
            className="grid lg:grid-cols-2 gap-8 max-w-7xl mx-auto"
            initial={{ opacity: 0, y: 50 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ delay: 1.2, duration: 0.8 }}
          >
            {/* Left Column - Learn Concepts */}
            <motion.div
              initial={{ opacity: 0, x: -50 }}
              animate={{ opacity: 1, x: 0 }}
              transition={{ delay: 1.4, duration: 0.8 }}
            >
              <JupyterBookContent />
            </motion.div>

            {/* Right Column - Code in IDE */}
            <motion.div
              initial={{ opacity: 0, x: 50 }}
              animate={{ opacity: 1, x: 0 }}
              transition={{ delay: 1.6, duration: 0.8 }}
            >
              <IDESection />
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
                icon: Target,
                title: "Escolha uma trilha",
                description: "Selecione o curso alinhado aos seus objetivos.",
              },
              {
                number: "2",
                icon: Code,
                title: "Estude e codifique na IDE embutida",
                description: "Consuma o conteúdo interativo e programe sem instalar nada.",
              },
              {
                number: "3",
                icon: Share,
                title: "Publique no portfólio & receba feedback",
                description: "Deploy 1-clique + comentários da comunidade no seu portfólio.",
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

      {/* Why Choose Syntropy Section */}
      <AnimatedSection>
        <div className="container mx-auto">
          <div className="text-center mb-16">
            <h2 className="text-4xl md:text-5xl font-bold mb-6">Por que escolher o Syntropy?</h2>
          </div>

          <div className="grid md:grid-cols-2 lg:grid-cols-4 gap-6 max-w-7xl mx-auto">
            {[
              {
                icon: Zap,
                title: "Plug-and-play",
                description: "Comece em segundos sem instalar nada",
              },
              {
                icon: Upload,
                title: "Projeto → Portfólio",
                description: "Deploy em 1 clique para seu portfólio",
              },
              {
                icon: Users,
                title: "Conexão Syntropy Projects",
                description: "Colabore open source com a comunidade",
              },
              {
                icon: Award,
                title: "Gamificação & currículo",
                description: "Badges e status que importam",
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

      {/* Featured Tracks Section */}
      <AnimatedSection className="bg-white/5">
        <div className="container mx-auto">
          <div className="text-center mb-16">
            <h2 className="text-4xl md:text-5xl font-bold mb-6">Trilhas em destaque</h2>
          </div>

          <div className="grid md:grid-cols-3 gap-8 max-w-6xl mx-auto mb-12">
            {[
              {
                title: "Construindo Sistemas de Agentes",
                level: "Iniciante",
                duration: "4 semanas",
                stack: "IA",
                icon: "🤖",
                status: "Em breve",
              },
              {
                title: "Prompt Engineering Fundamentals",
                level: "Intermediário",
                duration: "6 semanas",
                stack: "IA",
                icon: "🧠",
                status: "Em breve",
              },
              {
                title: "Arquitetura de Sistemas de IA em Produção",
                level: "Avançado",
                duration: "8 semanas",
                stack: "IA",
                icon: "🏗️",
                status: "Em breve",
              },
            ].map((track, index) => (
              <motion.div
                key={track.title}
                initial={{ opacity: 0, y: 50 }}
                whileInView={{ opacity: 1, y: 0 }}
                transition={{ delay: index * 0.1, duration: 0.6 }}
              >
                <Card className="bg-white/10 backdrop-blur-sm border-white/20 h-full hover:bg-white/15 transition-colors">
                  <CardHeader>
                    <div className="flex items-center gap-3 mb-4">
                      <span className="text-2xl">{track.icon}</span>
                      <div>
                        <div className="flex gap-2 mb-2">
                          <Badge variant="secondary">{track.level}</Badge>
                          <Badge variant="outline" className="border-white/20 text-white">
                            {track.status}
                          </Badge>
                        </div>
                      </div>
                    </div>
                    <CardTitle className="text-white text-lg">{track.title}</CardTitle>
                  </CardHeader>
                  <CardContent>
                    <div className="flex items-center gap-4 text-sm text-white/70 mb-4">
                      <div className="flex items-center gap-1">
                        <Clock className="h-4 w-4" />
                        {track.duration}
                      </div>
                      <Badge className="bg-blue-600 text-white">IDE integrada</Badge>
                    </div>
                    <p className="text-white/70 text-sm mb-4">Stack: {track.stack}</p>
                  </CardContent>
                </Card>
              </motion.div>
            ))}
          </div>

          <div className="text-center">
            <Button asChild variant="outline" className="border-white/20 text-white hover:bg-white/10">
              <Link href="/learn/courses">
                Explore toda nossa biblioteca de cursos <ArrowRight className="ml-2 h-4 w-4" />
              </Link>
            </Button>
          </div>
        </div>
      </AnimatedSection>

      {/* Portfolio Section */}
      <AnimatedSection>
        <div className="container mx-auto">
          <div className="grid lg:grid-cols-2 gap-16 items-center max-w-6xl mx-auto">
            <div>
              <h2 className="text-4xl md:text-5xl font-bold mb-6">Seu portfólio, atualizado em tempo real</h2>
              <p className="text-xl text-white/80 mb-8 leading-relaxed">
                Cada commit, curso concluído e contribuição de pesquisa aparece no seu currículo on-chain dentro do
                Syntropy. Compartilhe um link único com recrutadores ou parceiros.
              </p>
              <div className="space-y-4 mb-8">
                {[
                  "Portfólio atualizado automaticamente",
                  "Projetos com deploy em 1 clique",
                  "Histórico completo de contribuições",
                  "Badges e certificações verificáveis",
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
              <PortfolioPreview />
            </div>
          </div>
        </div>
      </AnimatedSection>

      {/* Learning vs Teaching Section */}
      <AnimatedSection className="bg-white/5">
        <div className="container mx-auto">
          <div className="grid md:grid-cols-2 gap-8 max-w-4xl mx-auto">
            <Card className="bg-white/10 backdrop-blur-sm border-white/20 hover:bg-white/15 transition-colors">
              <CardHeader className="text-center">
                <CardTitle className="text-white text-2xl mb-4">Para aprender</CardTitle>
                <CardDescription className="text-white/70 text-lg">
                  Comece sua jornada de desenvolvedor com projetos reais
                </CardDescription>
              </CardHeader>
              <CardContent className="text-center">
                <Button asChild className="w-full bg-blue-600 hover:bg-blue-700 text-white">
                  <Link href="/learn/courses">Começar agora</Link>
                </Button>
              </CardContent>
            </Card>

            <Card className="bg-white/10 backdrop-blur-sm border-white/20 hover:bg-white/15 transition-colors">
              <CardHeader className="text-center">
                <CardTitle className="text-white text-2xl mb-4">Para ensinar</CardTitle>
                <CardDescription className="text-white/70 text-lg">
                  Compartilhe conhecimento e ajude outros desenvolvedores
                </CardDescription>
              </CardHeader>
              <CardContent className="text-center">
                <Button asChild variant="outline" className="w-full border-white/20 text-white hover:bg-white/10">
                  <Link href="/mentor">Torne-se mentor</Link>
                </Button>
              </CardContent>
            </Card>
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
              Pronto para acelerar seu{" "}
              <span className="bg-gradient-to-r from-blue-400 to-purple-400 bg-clip-text text-transparent">
                aprendizado?
              </span>
            </h2>
            <p className="text-xl text-white/80 mb-8 max-w-2xl mx-auto">
              Junte-se a milhares de desenvolvedores que já estão construindo o futuro com o Syntropy.
            </p>
            <div className="flex flex-col sm:flex-row gap-4 justify-center">
              <Button asChild size="lg" className="bg-blue-600 hover:bg-blue-700 text-white px-12 py-4 text-lg">
                <Link href="/auth?mode=signup">Começar gratuitamente</Link>
              </Button>
              <Button
                asChild
                variant="outline"
                size="lg"
                className="border-white/20 text-white hover:bg-white/10 px-12 py-4 text-lg"
              >
                <Link href="/learn/courses">Explorar cursos</Link>
              </Button>
            </div>
          </div>
        </div>
      </AnimatedSection>
    </div>
  )
}
