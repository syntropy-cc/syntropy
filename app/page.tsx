"use client"

import type React from "react"

import { useRef } from "react"
import { motion, useScroll, useTransform, useInView } from "framer-motion"
import { Button } from "@/components/ui/button"
import { BookOpen, Users, FlaskConical, Check } from "lucide-react"
import Link from "next/link"
import { Badge } from "@/components/ui/badge"

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

// 3D Laptop Component
function Laptop3D() {
  return (
    <motion.div className="relative w-80 h-80" whileHover={{ rotateY: 5, rotateX: -2 }} transition={{ duration: 0.3 }}>
      {/* Laptop Base */}
      <div className="absolute bottom-0 w-full h-4 bg-gradient-to-r from-slate-600 to-slate-700 rounded-lg" />

      {/* Laptop Screen */}
      <div className="absolute inset-0 bg-gradient-to-br from-blue-500 to-blue-600 rounded-2xl transform rotate-12 opacity-80" />
      <div className="absolute inset-4 bg-gradient-to-br from-blue-400 to-blue-500 rounded-xl transform -rotate-6" />
      <div className="absolute inset-8 bg-slate-900 rounded-lg flex items-center justify-center">
        <div className="text-blue-400 text-4xl font-mono">&lt;/&gt;</div>
      </div>

      {/* Floating Book */}
      <motion.div
        className="absolute -right-8 -top-8 w-24 h-32 bg-gradient-to-br from-blue-500 to-blue-600 rounded-lg transform rotate-12 flex items-center justify-center"
        animate={{ y: [-5, 5, -5] }}
        transition={{ duration: 3, repeat: Number.POSITIVE_INFINITY, ease: "easeInOut" }}
      >
        <BookOpen className="h-8 w-8 text-white" />
      </motion.div>
    </motion.div>
  )
}

// 3D Collaboration Elements
function CollaborationElements() {
  return (
    <div className="relative w-80 h-80">
      {/* Main Code Window */}
      <div className="absolute inset-0 bg-gradient-to-br from-blue-500 to-blue-600 rounded-2xl transform -rotate-6 opacity-80" />
      <div className="absolute inset-4 bg-slate-800 rounded-xl flex items-center justify-center">
        <div className="text-blue-400 text-4xl font-mono">&lt;/&gt;</div>
      </div>

      {/* Achievement Badge */}
      <motion.div
        className="absolute -right-4 -bottom-4 w-16 h-16 bg-gradient-to-br from-yellow-400 to-yellow-500 rounded-full flex items-center justify-center transform rotate-12"
        animate={{ rotate: [12, 25, 12] }}
        transition={{ duration: 4, repeat: Number.POSITIVE_INFINITY }}
      >
        <div className="w-8 h-8 bg-yellow-600 rounded-full flex items-center justify-center">
          <div className="w-4 h-4 bg-white rounded-full"></div>
        </div>
      </motion.div>

      {/* Puzzle Pieces */}
      <motion.div
        className="absolute -left-8 top-8 w-12 h-12 bg-blue-600 rounded-lg transform rotate-45"
        animate={{ rotate: [45, 60, 45] }}
        transition={{ duration: 3, repeat: Number.POSITIVE_INFINITY }}
      />
      <motion.div
        className="absolute -left-4 top-16 w-8 h-8 bg-blue-500 rounded-lg transform rotate-12"
        animate={{ rotate: [12, -12, 12] }}
        transition={{ duration: 2.5, repeat: Number.POSITIVE_INFINITY }}
      />
    </div>
  )
}

// 3D Lab Equipment
function LabEquipment() {
  return (
    <div className="relative w-80 h-80">
      {/* Main Flask */}
      <div className="absolute left-8 top-8 w-32 h-40 bg-gradient-to-br from-blue-500 to-blue-600 rounded-t-full rounded-b-lg transform -rotate-12" />

      {/* Liquid Animation */}
      <motion.div
        className="absolute left-12 top-16 w-24 h-24 bg-blue-400 rounded-full opacity-60"
        animate={{ scale: [1, 1.2, 1], opacity: [0.6, 0.8, 0.6] }}
        transition={{ duration: 3, repeat: Number.POSITIVE_INFINITY }}
      />

      {/* Checklist */}
      <div className="absolute right-8 top-12 w-24 h-32 bg-gradient-to-br from-slate-700 to-slate-800 rounded-lg transform rotate-12">
        <div className="p-3 space-y-2">
          {[0, 1, 2].map((i) => (
            <motion.div
              key={i}
              className="flex items-center gap-2"
              initial={{ opacity: 0, x: -10 }}
              animate={{ opacity: 1, x: 0 }}
              transition={{ delay: i * 0.2 }}
            >
              <div className="w-3 h-3 bg-blue-400 rounded-sm" />
              <div className="w-12 h-1 bg-blue-400 rounded"></div>
            </motion.div>
          ))}
        </div>
      </div>

      {/* Floating Molecules */}
      {[...Array(3)].map((_, i) => (
        <motion.div
          key={i}
          className="absolute w-4 h-4 bg-blue-500 rounded-full"
          style={{
            left: `${20 + i * 15}%`,
            top: `${60 + i * 10}%`,
          }}
          animate={{
            y: [-10, 10, -10],
            x: [-5, 5, -5],
          }}
          transition={{
            duration: 2 + i * 0.5,
            repeat: Number.POSITIVE_INFINITY,
            ease: "easeInOut",
          }}
        />
      ))}
    </div>
  )
}

// Section Component with Scroll Animations
function AnimatedSection({
  id,
  children,
  className = "",
}: {
  id: string
  children: React.ReactNode
  className?: string
}) {
  const ref = useRef(null)
  const isInView = useInView(ref, { once: true, margin: "-100px" })

  return (
    <motion.section
      id={id}
      ref={ref}
      className={`min-h-screen flex items-center py-20 px-4 ${className}`}
      initial={{ opacity: 0, y: 100 }}
      animate={isInView ? { opacity: 1, y: 0 } : { opacity: 0, y: 100 }}
      transition={{ duration: 0.8, ease: "easeOut" }}
    >
      {children}
    </motion.section>
  )
}

export default function HomePage() {
  const { scrollYProgress } = useScroll()
  const heroY = useTransform(scrollYProgress, [0, 0.3], [0, -100])
  const heroOpacity = useTransform(scrollYProgress, [0, 0.3], [1, 0])

  return (
    <div className="bg-gradient-to-br from-slate-900 via-blue-900/20 to-slate-900 text-white overflow-hidden">
      {/* Hero Section */}
      <motion.section
        className="relative min-h-screen flex items-center justify-center px-4"
        style={{ y: heroY, opacity: heroOpacity }}
      >
        <div className="container mx-auto text-center">
          <motion.div
            initial={{ opacity: 0, scale: 0.8 }}
            animate={{ opacity: 1, scale: 1 }}
            transition={{ duration: 1, ease: "easeOut" }}
          >
            <h1 className="text-5xl md:text-7xl font-bold mb-6">
              Bem-vindo ao{" "}
              <span className="bg-gradient-to-r from-blue-400 to-pink-400 bg-clip-text text-transparent">Syntropy</span>
            </h1>
          </motion.div>

          <motion.p
            className="text-xl md:text-2xl text-white/80 mb-16 max-w-4xl mx-auto"
            initial={{ opacity: 0, y: 30 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ delay: 0.5, duration: 0.8 }}
          >
            O ecossistema open-source que conecta aprendizado, colaboração e inovação em um só lugar.
          </motion.p>

          {/* Three Pillars */}
          <motion.div
            className="grid md:grid-cols-3 gap-12 max-w-4xl mx-auto"
            initial={{ opacity: 0, y: 50 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ delay: 1.2, duration: 0.8 }}
          >
            {[
              { icon: BookOpen, title: "Aprenda", sectionId: "aprenda" },
              { icon: Users, title: "Contribua", sectionId: "contribua" },
              { icon: FlaskConical, title: "Pesquise", sectionId: "pesquise" },
            ].map(({ icon: Icon, title, sectionId }) => (
              <motion.button
                key={title}
                onClick={() => {
                  const element = document.getElementById(sectionId)
                  if (element) {
                    element.scrollIntoView({ behavior: "smooth" })
                  }
                }}
                className="flex flex-col items-center group cursor-pointer bg-transparent border-none p-4 rounded-lg hover:bg-white/5 transition-colors"
                whileHover={{ scale: 1.05 }}
                whileTap={{ scale: 0.95 }}
              >
                <div className="w-32 h-32 bg-white/10 backdrop-blur-sm rounded-full flex items-center justify-center mb-6 border border-white/20 group-hover:border-blue-400/50 group-hover:bg-white/15 transition-all">
                  <Icon
                    className="h-12 w-12 text-blue-400 group-hover:text-blue-300 transition-colors"
                    strokeWidth={1.5}
                  />
                </div>
                <h3 className="text-xl font-semibold text-white group-hover:text-blue-300 transition-colors">
                  {title}
                </h3>
              </motion.button>
            ))}
          </motion.div>
        </div>
      </motion.section>

      {/* Learn Section */}
      <AnimatedSection id="aprenda">
        <div className="container mx-auto">
          <div className="grid lg:grid-cols-2 gap-16 items-center max-w-6xl mx-auto">
            <div className="flex justify-center">
              <Laptop3D />
            </div>
            <div>
              <h2 className="text-4xl md:text-5xl font-bold mb-6 text-white">Aprenda na prática</h2>
              <p className="text-xl text-white/80 mb-8 leading-relaxed">
                Domine programação com trilhas interativas e projetos reais dentro de um IDE 100% on-line. Escreva,
                teste e publique código direto do navegador — sem instalar nada. Cada conquista alimenta um currículo
                vivo que impulsiona sua carreira em comunidade.
              </p>
              <div className="space-y-4 mb-8">
                {["Projetos reais", "Comunidade ativa", "Currículo vivo"].map((item, index) => (
                  <motion.div
                    key={item}
                    className="flex items-center gap-3"
                    initial={{ opacity: 0, x: -20 }}
                    whileInView={{ opacity: 1, x: 0 }}
                    transition={{ delay: 0.4 + index * 0.1 }}
                  >
                    <Check className="h-5 w-5 text-blue-400" />
                    <span className="text-white/80">{item}</span>
                  </motion.div>
                ))}
              </div>
              <Button asChild size="lg" className="bg-blue-600 hover:bg-blue-700 text-white px-8 py-3 text-lg">
                <Link href="/learn">Explorar cursos</Link>
              </Button>
            </div>
          </div>
        </div>
      </AnimatedSection>

      {/* Build Section */}
      <AnimatedSection id="contribua" className="bg-white/5">
        <div className="container mx-auto">
          <div className="grid lg:grid-cols-2 gap-16 items-center max-w-6xl mx-auto">
            <div>
              <h2 className="text-4xl md:text-5xl font-bold mb-6 text-white">Construa junto</h2>
              <p className="text-xl text-white/80 mb-8 leading-relaxed">
                Participe de projetos open-source em equipe: edite código no navegador, siga um fluxo de contribuição
                passo a passo e ganhe reconhecimento por cada entrega. Transforme ideias em soluções reais com a
                comunidade.
              </p>
              <div className="space-y-4 mb-8">
                {["Edição colaborativa on-line", "Contribuição guiada", "Recompensas & reconhecimento"].map(
                  (item, index) => (
                    <motion.div
                      key={item}
                      className="flex items-center gap-3"
                      initial={{ opacity: 0, x: -20 }}
                      whileInView={{ opacity: 1, x: 0 }}
                      transition={{ delay: 0.2 + index * 0.1 }}
                    >
                      <Check className="h-5 w-5 text-blue-400" />
                      <span className="text-white/80">{item}</span>
                    </motion.div>
                  ),
                )}
              </div>
              <Button asChild size="lg" className="bg-blue-600 hover:bg-blue-700 text-white px-8 py-3 text-lg">
                <Link href="/projects">Explorar projetos</Link>
              </Button>
            </div>
            <div className="flex justify-center">
              <CollaborationElements />
            </div>
          </div>
        </div>
      </AnimatedSection>

      {/* Research Section */}
      <AnimatedSection id="pesquise">
        <div className="container mx-auto">
          <div className="grid lg:grid-cols-2 gap-16 items-center max-w-6xl mx-auto">
            <div className="flex justify-center">
              <LabEquipment />
            </div>
            <div>
              <h2 className="text-4xl md:text-5xl font-bold mb-6 text-white">Pesquise em comunidade</h2>
              <p className="text-xl text-white/80 mb-8 leading-relaxed">
                Crie ou participe de laboratórios temáticos para explorar tecnologias emergentes, registrar métodos e
                dados de forma reprodutível e colaborar com pesquisadores do mundo todo. Submeta descobertas à revisão
                aberta da comunidade e publique artigos completos com um clique.
              </p>
              <div className="space-y-4 mb-8">
                {["Laboratórios temáticos", "Revisão aberta por pares", "Publicação integrada"].map((item, index) => (
                  <motion.div
                    key={item}
                    className="flex items-center gap-3"
                    initial={{ opacity: 0, x: -20 }}
                    whileInView={{ opacity: 1, x: 0 }}
                    transition={{ delay: 0.4 + index * 0.1 }}
                  >
                    <Check className="h-5 w-5 text-blue-400" />
                    <span className="text-white/80">{item}</span>
                  </motion.div>
                ))}
              </div>
              <Button asChild size="lg" className="bg-blue-600 hover:bg-blue-700 text-white px-8 py-3 text-lg">
                <Link href="/labs">Conhecer Labs</Link>
              </Button>
            </div>
          </div>
        </div>
      </AnimatedSection>

      {/* Portfolio Section */}
      <AnimatedSection id="portfolio">
        <div className="container mx-auto">
          <div className="grid lg:grid-cols-2 gap-16 items-center max-w-6xl mx-auto">
            <div>
              <h2 className="text-4xl md:text-5xl font-bold mb-6">Seu currículo vivo no ecossistema Syntropy</h2>
              <p className="text-xl text-white/80 mb-8 leading-relaxed">
                Cada curso concluído, projeto desenvolvido e experimento em labs se integra automaticamente ao seu
                portfólio dinâmico. Aprenda, construa, pesquise e veja seu currículo evoluir em tempo real dentro do
                ecossistema Syntropy.
              </p>
              <div className="space-y-4 mb-8">
                {[
                  "Cursos e certificações verificáveis",
                  "Projetos com deploy automático",
                  "Contribuições em labs experimentais",
                  "Histórico completo de atividades",
                ].map((item, index) => (
                  <motion.div
                    key={item}
                    className="flex items-center gap-3"
                    initial={{ opacity: 0, x: -20 }}
                    whileInView={{ opacity: 1, x: 0 }}
                    transition={{ delay: 0.2 + index * 0.1 }}
                  >
                    <Check className="h-5 w-5 text-blue-400" />
                    <span className="text-white/80">{item}</span>
                  </motion.div>
                ))}
              </div>
              <Button asChild size="lg" className="bg-blue-600 hover:bg-blue-700 text-white px-8 py-3 text-lg">
                <Link href="/auth?mode=signup">Criar meu portfólio</Link>
              </Button>
            </div>
            <div className="flex justify-center">
              <PortfolioPreview />
            </div>
          </div>
        </div>
      </AnimatedSection>

      {/* CTA Section */}
      <AnimatedSection id="cta" className="bg-white/5">
        <div className="container mx-auto">
          <div className="text-center max-w-4xl mx-auto">
            <h2 className="text-4xl md:text-5xl font-bold mb-6">
              Pronto para fazer parte da{" "}
              <span className="bg-gradient-to-r from-blue-400 to-pink-400 bg-clip-text text-transparent">
                revolução open-source?
              </span>
            </h2>
            <p className="text-xl text-white/80 mb-8 max-w-2xl mx-auto">
              Junte-se a uma comunidade que acredita no poder da colaboração e do conhecimento aberto.
            </p>
            <Button size="lg" className="bg-blue-600 hover:bg-blue-700 text-white px-12 py-4 text-lg">
              Criar minha conta
            </Button>
          </div>
        </div>
      </AnimatedSection>
    </div>
  )
}
