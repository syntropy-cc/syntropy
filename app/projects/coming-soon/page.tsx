"use client"

import type React from "react"

import { useState, useEffect } from "react"
import { motion } from "framer-motion"
import { Button } from "@/components/ui/button"
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card"
import { Input } from "@/components/ui/input"
import { Label } from "@/components/ui/label"
import { Textarea } from "@/components/ui/textarea"
import { Badge } from "@/components/ui/badge"
import { useToast } from "@/hooks/use-toast"
import { Code, Users, Star, Rocket, Bell, CheckCircle, ArrowLeft, Mail, User, Building, Zap } from "lucide-react"
import Link from "next/link"
import { supabase } from "@/lib/supabase/client"

export default function ProjectsComingSoonPage() {
  const [isLoggedIn, setIsLoggedIn] = useState<boolean | null>(null)
  const [isSubmitted, setIsSubmitted] = useState(false)
  const [formData, setFormData] = useState({
    name: "",
    email: "",
    role: "",
    company: "",
    interests: "",
  })
  const [isSubmitting, setIsSubmitting] = useState(false)
  const { toast } = useToast()

  useEffect(() => {
    supabase.auth.getUser().then(({ data }) => {
      setIsLoggedIn(!!data.user)
    })
  }, [])

  if (isLoggedIn) {
    return (
      <div className="min-h-screen flex items-center justify-center bg-gradient-to-br from-slate-900 via-blue-900/20 to-slate-900 text-white">
        <motion.div
          initial={{ opacity: 0, scale: 0.8 }}
          animate={{ opacity: 1, scale: 1 }}
          transition={{ duration: 0.6 }}
          className="text-center max-w-2xl mx-auto"
        >
          <h1 className="text-4xl font-bold mb-6">Syntropy Projects está chegando!</h1>
          <p className="text-xl text-white/80 mb-8">
            Registre seu interesse para ser avisado sobre o lançamento.
          </p>
          <Button
            type="button"
            onClick={() => {
              setIsSubmitted(true)
              toast({
                title: "Interesse registrado com sucesso!",
                description: "Você receberá atualizações sobre o lançamento do Syntropy Projects.",
              })
            }}
            className="bg-blue-600 hover:bg-blue-700 text-white py-3 text-lg"
          >
            Quero ser notificado
          </Button>
          {isSubmitted && (
            <p className="mt-4 text-green-400">Interesse registrado! Você receberá novidades em breve.</p>
          )}
        </motion.div>
      </div>
    )
  }

  if (isLoggedIn === false) {
    const handleInputChange = (e: React.ChangeEvent<HTMLInputElement | HTMLTextAreaElement>) => {
      const { name, value } = e.target
      setFormData((prev) => ({ ...prev, [name]: value }))
    }

    const handleSubmit = async (e: React.FormEvent) => {
      e.preventDefault()
      setIsSubmitting(true)

      // Simulate API call
      await new Promise((resolve) => setTimeout(resolve, 2000))

      setIsSubmitted(true)
      setIsSubmitting(false)

      toast({
        title: "Interesse registrado com sucesso!",
        description: "Você receberá atualizações sobre o lançamento do Syntropy Projects.",
      })
    }

    return (
      <div className="min-h-screen bg-gradient-to-br from-slate-900 via-blue-900/20 to-slate-900 text-white">
        {/* Header */}
        <div className="border-b border-slate-800">
          <div className="container py-4">
            <Link
              href="/projects"
              className="inline-flex items-center gap-2 text-white/60 hover:text-white transition-colors"
            >
              <ArrowLeft className="h-4 w-4" />
              Voltar para Projects
            </Link>
          </div>
        </div>

        <div className="container py-16 px-4">
          <div className="max-w-6xl mx-auto">
            {/* Hero Section */}
            <motion.div
              initial={{ opacity: 0, y: 30 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ duration: 0.8 }}
              className="text-center mb-16"
            >
              <div className="flex items-center justify-center gap-3 mb-6">
                <div className="w-16 h-16 bg-blue-600 rounded-2xl flex items-center justify-center">
                  <Rocket className="h-8 w-8 text-white" />
                </div>
                <Badge className="bg-blue-600 text-white px-4 py-2 text-sm">Em breve</Badge>
              </div>

              <h1 className="text-5xl md:text-6xl font-bold mb-6">
                <span className="text-blue-400">Syntropy Projects</span>
                <br />
                está chegando
              </h1>

              <p className="text-xl md:text-2xl text-white/80 mb-8 max-w-3xl mx-auto leading-relaxed">
                O hub definitivo para descobrir, contribuir e evoluir projetos open-source está sendo construído. Seja um
                dos primeiros a experimentar o futuro da colaboração em código.
              </p>
            </motion.div>

            <div className="grid lg:grid-cols-2 gap-12 items-start">
              {/* Features Preview */}
              <motion.div
                initial={{ opacity: 0, x: -30 }}
                animate={{ opacity: 1, x: 0 }}
                transition={{ delay: 0.3, duration: 0.8 }}
              >
                <h2 className="text-3xl font-bold mb-8">O que está por vir</h2>

                <div className="space-y-6">
                  {[
                    {
                      icon: Code,
                      title: "Hub de Projetos Inteligente",
                      description:
                        "Algoritmos avançados para matching entre desenvolvedores e projetos baseado em skills, interesses e experiência.",
                    },
                    {
                      icon: Users,
                      title: "Colaboração Sem Fronteiras",
                      description:
                        "Ferramentas integradas para onboarding, mentoria e gestão de contribuições em projetos open-source.",
                    },
                    {
                      icon: Star,
                      title: "Sistema de Reconhecimento",
                      description:
                        "Badges verificáveis, reputação baseada em contribuições e oportunidades de crescimento na comunidade.",
                    },
                    {
                      icon: Zap,
                      title: "Funding Transparente",
                      description:
                        "Mecanismos inovadores de financiamento que conectam projetos promissores com investidores e empresas.",
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
                        <div className="w-12 h-12 bg-blue-600 rounded-lg flex items-center justify-center flex-shrink-0">
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

              {/* Registration Form */}
              <motion.div
                initial={{ opacity: 0, x: 30 }}
                animate={{ opacity: 1, x: 0 }}
                transition={{ delay: 0.5, duration: 0.8 }}
              >
                <Card className="bg-white/10 backdrop-blur-sm border-white/20">
                  <CardHeader className="text-center">
                    <div className="w-12 h-12 bg-blue-600 rounded-lg flex items-center justify-center mx-auto mb-4">
                      <Bell className="h-6 w-6 text-white" />
                    </div>
                    <CardTitle className="text-white text-2xl">Registre seu interesse</CardTitle>
                    <CardDescription className="text-white/70">
                      Seja notificado sobre atualizações, beta releases e o lançamento oficial
                    </CardDescription>
                  </CardHeader>
                  <CardContent>
                    <form onSubmit={handleSubmit} className="space-y-6">
                      <div className="grid md:grid-cols-2 gap-4">
                        <div className="space-y-2">
                          <Label htmlFor="name" className="text-white">
                            Nome completo *
                          </Label>
                          <div className="relative">
                            <User className="absolute left-3 top-1/2 transform -translate-y-1/2 h-4 w-4 text-white/40" />
                            <Input
                              id="name"
                              name="name"
                              type="text"
                              required
                              value={formData.name}
                              onChange={handleInputChange}
                              className="pl-10 bg-white/5 border-white/20 text-white placeholder:text-white/40"
                              placeholder="Seu nome"
                            />
                          </div>
                        </div>

                        <div className="space-y-2">
                          <Label htmlFor="email" className="text-white">
                            Email *
                          </Label>
                          <div className="relative">
                            <Mail className="absolute left-3 top-1/2 transform -translate-y-1/2 h-4 w-4 text-white/40" />
                            <Input
                              id="email"
                              name="email"
                              type="email"
                              required
                              value={formData.email}
                              onChange={handleInputChange}
                              className="pl-10 bg-white/5 border-white/20 text-white placeholder:text-white/40"
                              placeholder="seu@email.com"
                            />
                          </div>
                        </div>
                      </div>

                      <div className="grid md:grid-cols-2 gap-4">
                        <div className="space-y-2">
                          <Label htmlFor="role" className="text-white">
                            Função/Cargo
                          </Label>
                          <Input
                            id="role"
                            name="role"
                            type="text"
                            value={formData.role}
                            onChange={handleInputChange}
                            className="bg-white/5 border-white/20 text-white placeholder:text-white/40"
                            placeholder="Ex: Desenvolvedor Frontend"
                          />
                        </div>

                        <div className="space-y-2">
                          <Label htmlFor="company" className="text-white">
                            Empresa/Organização
                          </Label>
                          <div className="relative">
                            <Building className="absolute left-3 top-1/2 transform -translate-y-1/2 h-4 w-4 text-white/40" />
                            <Input
                              id="company"
                              name="company"
                              type="text"
                              value={formData.company}
                              onChange={handleInputChange}
                              className="pl-10 bg-white/5 border-white/20 text-white placeholder:text-white/40"
                              placeholder="Nome da empresa"
                            />
                          </div>
                        </div>
                      </div>

                      <div className="space-y-2">
                        <Label htmlFor="interests" className="text-white">
                          Áreas de interesse
                        </Label>
                        <Textarea
                          id="interests"
                          name="interests"
                          value={formData.interests}
                          onChange={handleInputChange}
                          className="bg-white/5 border-white/20 text-white placeholder:text-white/40 min-h-[100px]"
                          placeholder="Conte-nos sobre suas áreas de interesse, tecnologias que você trabalha ou tipos de projetos que gostaria de contribuir..."
                        />
                      </div>

                      <Button
                        type="submit"
                        disabled={isSubmitting}
                        className="w-full bg-blue-600 hover:bg-blue-700 text-white py-3 text-lg"
                      >
                        {isSubmitting ? (
                          <>
                            <motion.div
                              animate={{ rotate: 360 }}
                              transition={{ duration: 1, repeat: Number.POSITIVE_INFINITY, ease: "linear" }}
                              className="mr-2"
                            >
                              <Zap className="h-4 w-4" />
                            </motion.div>
                            Registrando interesse...
                          </>
                        ) : (
                          <>
                            <Bell className="mr-2 h-4 w-4" />
                            Quero ser notificado
                          </>
                        )}
                      </Button>

                      <p className="text-xs text-white/60 text-center">
                        Ao registrar seu interesse, você concorda em receber atualizações sobre o Syntropy Projects. Você
                        pode cancelar a qualquer momento.
                      </p>
                    </form>
                  </CardContent>
                </Card>

                {/* Benefits of Early Access */}
                <div className="mt-8 p-6 bg-white/5 rounded-lg border border-white/10">
                  <h3 className="text-lg font-semibold text-white mb-4">Benefícios do acesso antecipado</h3>
                  <div className="space-y-3">
                    {[
                      "Acesso exclusivo ao beta antes do lançamento público",
                      "Influência no desenvolvimento de features",
                      "Networking com outros early adopters",
                      "Badges especiais de early supporter",
                    ].map((benefit, index) => (
                      <div key={index} className="flex items-center gap-3">
                        <CheckCircle className="h-4 w-4 text-blue-400 flex-shrink-0" />
                        <span className="text-white/80 text-sm">{benefit}</span>
                      </div>
                    ))}
                  </div>
                </div>
              </motion.div>
            </div>
          </div>
        </div>
      </div>
    )
  }

  return null
}
