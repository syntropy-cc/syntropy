"use client"

import { motion } from "framer-motion"
import { Button } from "@/components/ui/button"
import { Badge } from "@/components/ui/badge"
import { Users, HeartHandshake, Lightbulb, FileText, MessageCircle, Check, GitBranch, Star, Sparkles } from "lucide-react"
import Link from "next/link"

export default function ContributePage() {
  return (
    <div className="bg-gradient-to-br from-slate-900 via-blue-900/20 to-slate-900 text-white overflow-hidden min-h-screen">
      {/* Hero Section */}
      <motion.section
        className="relative min-h-[60vh] flex flex-col items-center justify-center px-4 pt-24 pb-12 text-center"
        initial={{ opacity: 0, y: 40 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ duration: 0.8 }}
      >
        <motion.div
          initial={{ opacity: 0, scale: 0.92 }}
          animate={{ opacity: 1, scale: 1 }}
          transition={{ delay: 0.2, duration: 0.8 }}
        >
          <h1 className="text-4xl md:text-6xl font-bold mb-6">
            Construa o futuro do <span className="bg-gradient-to-r from-blue-400 to-pink-400 bg-clip-text text-transparent">Syntropy</span>
          </h1>
          <p className="text-xl md:text-2xl text-white/80 mb-8 max-w-2xl mx-auto">
            O Syntropy é feito por pessoas como você. Contribua com código, ideias, documentação ou simplesmente participando da comunidade. Toda contribuição conta!
          </p>
          <Button asChild size="lg" className="bg-blue-600 hover:bg-blue-700 text-white px-10 py-4 text-xl">
            <Link href="https://github.com/syntropy-dev/syntropy" target="_blank" rel="noopener noreferrer">
              Contribuir no GitHub
            </Link>
          </Button>
        </motion.div>
        <motion.div
          className="absolute right-8 top-8 hidden md:block"
          initial={{ opacity: 0, x: 40 }}
          animate={{ opacity: 0.15, x: 0 }}
          transition={{ delay: 0.5, duration: 1 }}
        >
          <Sparkles className="w-32 h-32 text-blue-400" />
        </motion.div>
      </motion.section>

      {/* Motivos para contribuir */}
      <section className="container mx-auto py-16 px-4">
        <div className="max-w-3xl mx-auto text-center mb-12">
          <h2 className="text-3xl md:text-4xl font-bold mb-4">Por que contribuir?</h2>
          <p className="text-lg text-white/80">
            Ao contribuir, você acelera sua carreira, aprende na prática, expande seu networking e deixa sua marca em um projeto open source de impacto real.
          </p>
        </div>
        <div className="grid md:grid-cols-3 gap-8 max-w-5xl mx-auto">
          <div className="bg-white/5 rounded-xl p-8 flex flex-col items-center text-center shadow-lg">
            <Users className="w-10 h-10 text-blue-400 mb-4" />
            <h3 className="font-semibold text-xl mb-2">Networking Global</h3>
            <p className="text-white/70">Conecte-se com devs, pesquisadores e inovadores do mundo todo.</p>
          </div>
          <div className="bg-white/5 rounded-xl p-8 flex flex-col items-center text-center shadow-lg">
            <Lightbulb className="w-10 h-10 text-yellow-400 mb-4" />
            <h3 className="font-semibold text-xl mb-2">Aprendizado Real</h3>
            <p className="text-white/70">Aprenda colaborando, resolvendo problemas reais e recebendo feedback.</p>
          </div>
          <div className="bg-white/5 rounded-xl p-8 flex flex-col items-center text-center shadow-lg">
            <Star className="w-10 h-10 text-pink-400 mb-4" />
            <h3 className="font-semibold text-xl mb-2">Reconhecimento</h3>
            <p className="text-white/70">Ganhe destaque, badges e registre suas conquistas no portfólio.</p>
          </div>
        </div>
      </section>

      {/* Como contribuir */}
      <section className="container mx-auto py-16 px-4">
        <div className="max-w-3xl mx-auto text-center mb-12">
          <h2 className="text-3xl md:text-4xl font-bold mb-4">Como você pode contribuir?</h2>
          <p className="text-lg text-white/80">
            Existem várias formas de fazer parte. Escolha a que mais combina com você:
          </p>
        </div>
        <div className="grid md:grid-cols-4 gap-8 max-w-6xl mx-auto">
          <div className="bg-blue-900/30 rounded-xl p-6 flex flex-col items-center text-center border border-blue-700">
            <GitBranch className="w-8 h-8 text-blue-400 mb-3" />
            <h4 className="font-semibold text-lg mb-1">Código</h4>
            <p className="text-white/70 text-sm mb-2">Implemente features, corrija bugs ou otimize o projeto.</p>
            <Badge className="bg-blue-600 text-white">Pull Requests</Badge>
          </div>
          <div className="bg-yellow-900/20 rounded-xl p-6 flex flex-col items-center text-center border border-yellow-700">
            <Lightbulb className="w-8 h-8 text-yellow-400 mb-3" />
            <h4 className="font-semibold text-lg mb-1">Ideias</h4>
            <p className="text-white/70 text-sm mb-2">Sugira melhorias, novas features ou abra discussões.</p>
            <Badge className="bg-yellow-500 text-white">Discussions</Badge>
          </div>
          <div className="bg-purple-900/20 rounded-xl p-6 flex flex-col items-center text-center border border-purple-700">
            <FileText className="w-8 h-8 text-purple-400 mb-3" />
            <h4 className="font-semibold text-lg mb-1">Documentação</h4>
            <p className="text-white/70 text-sm mb-2">Melhore tutoriais, exemplos e docs para ajudar mais pessoas.</p>
            <Badge className="bg-purple-500 text-white">Docs</Badge>
          </div>
          <div className="bg-green-900/20 rounded-xl p-6 flex flex-col items-center text-center border border-green-700">
            <MessageCircle className="w-8 h-8 text-green-400 mb-3" />
            <h4 className="font-semibold text-lg mb-1">Comunidade</h4>
            <p className="text-white/70 text-sm mb-2">Ajude respondendo dúvidas, revisando PRs ou divulgando o projeto.</p>
            <Badge className="bg-green-500 text-white">Apoio</Badge>
          </div>
        </div>
      </section>

      {/* Comunidade em destaque */}
      <section className="container mx-auto py-16 px-4">
        <div className="max-w-3xl mx-auto text-center mb-12">
          <h2 className="text-3xl md:text-4xl font-bold mb-4">Junte-se à comunidade</h2>
          <p className="text-lg text-white/80">
            O Syntropy é uma comunidade aberta, diversa e colaborativa. Aqui, toda voz é ouvida e cada contribuição faz diferença.
          </p>
        </div>
        <div className="flex flex-col md:flex-row items-center justify-center gap-8 max-w-4xl mx-auto">
          <motion.div
            className="flex-1 bg-white/5 rounded-xl p-8 flex flex-col items-center text-center shadow-lg"
            initial={{ opacity: 0, y: 30 }}
            whileInView={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.7 }}
          >
            <HeartHandshake className="w-12 h-12 text-pink-400 mb-4" />
            <h3 className="font-semibold text-2xl mb-2">Colabore e Cresça</h3>
            <p className="text-white/70">A colaboração é o coração do Syntropy. Compartilhe conhecimento, aprenda e evolua junto.</p>
          </motion.div>
          <motion.div
            className="flex-1 bg-white/5 rounded-xl p-8 flex flex-col items-center text-center shadow-lg"
            initial={{ opacity: 0, y: 30 }}
            whileInView={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.7, delay: 0.2 }}
          >
            <Check className="w-12 h-12 text-green-400 mb-4" />
            <h3 className="font-semibold text-2xl mb-2">Impacto Real</h3>
            <p className="text-white/70">Cada linha de código, sugestão ou ajuda gera impacto direto no ecossistema e na vida de outros.</p>
          </motion.div>
        </div>
      </section>

      {/* CTA Final */}
      <section className="container mx-auto py-20 px-4 text-center">
        <motion.div
          initial={{ opacity: 0, scale: 0.95 }}
          whileInView={{ opacity: 1, scale: 1 }}
          transition={{ duration: 0.7 }}
        >
          <h2 className="text-4xl md:text-5xl font-bold mb-6">
            Pronto para contribuir?
          </h2>
          <p className="text-xl text-white/80 mb-8 max-w-2xl mx-auto">
            Faça parte do Syntropy e ajude a construir um futuro mais aberto, colaborativo e inovador.
          </p>
          <Button asChild size="lg" className="bg-blue-600 hover:bg-blue-700 text-white px-12 py-4 text-lg">
            <Link href="https://github.com/syntropy-dev/syntropy" target="_blank" rel="noopener noreferrer">
              Contribuir agora
            </Link>
          </Button>
        </motion.div>
      </section>
    </div>
  )
}
