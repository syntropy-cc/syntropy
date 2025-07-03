"use client"

import type React from "react"

import { useRef, useEffect, useState } from "react"
import { motion, useScroll, useTransform, useInView, useAnimation, AnimatePresence } from "framer-motion"
import { Button } from "@/components/ui/button"
import { BookOpen, Users, FlaskConical, Check, Award, Briefcase, GraduationCap, Rocket, GitBranch, Handshake, DollarSign, Lightbulb, FileText, MessageCircle } from "lucide-react"
import Link from "next/link"
import { Badge } from "@/components/ui/badge"
import { useAuth } from "@/hooks/use-auth"

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
// Card principal – Portfolio  •  Paleta "Portfolio" (#FF6B00)
function PortfolioCard() {
  return (
    <Link
      href="/portfolio"
      tabIndex={-1}
      aria-label="Ir para Portfólio"
      className="block focus:outline-none"
    >
      <motion.div
        className="relative overflow-visible"
        initial={{ y: 30, opacity: 0 }}
        animate={{ y: 0, opacity: 1 }}
        whileHover={{
          y: -8,
          boxShadow: "0 8px 48px 0 #FF6B0033, 0 1.5px 0 #ffffff22",
        }}
        transition={{ type: "spring", stiffness: 120, damping: 18 }}
        style={{
          /* ——— container glass ——— */
          background: "rgba(255,255,255,0.08)",
          backdropFilter: "blur(40px) saturate(150%)",
          border: "1.5px solid rgba(255,107,0,0.10)",
          borderRadius: 16,
          boxShadow:
            "0 8px 32px rgba(255,107,0,0.10), inset 0 1px 0 rgba(255,255,255,0.10)",
          maxWidth: 400,
          width: "100%",
          padding: 40,
          zIndex: 1,
        }}
        tabIndex={0}
        role="link"
        aria-label="Ir para Portfólio"
      >
        {/* ——— Background mesh & partículas ——— */}
        <div
          className="absolute inset-0 rounded-[16px] pointer-events-none h-full w-full min-h-full min-w-full"
          style={{
            background:
              "radial-gradient(ellipse at 60% 20%, #FFB36B22 0%, transparent 70%), radial-gradient(ellipse at 20% 80%, #BF410022 0%, transparent 70%)",
            zIndex: 0,
          }}
        />
        <CodeParticles />

        {/* ——— Header ——— */}
        <div className="flex items-center gap-4 mb-6 relative z-10">
          {/* —— Somente a cor foi alterada —— */}
          <PillarIconAnimated
            color="radial-gradient(circle at 30% 30%, #FFB36B 0%, #FF6B00 55%, #BF4100 100%)"
            shadow="#FF6B0099"
          >
            <Briefcase className="h-12 w-12 text-white" strokeWidth={1.5} />
          </PillarIconAnimated>

          <div>
            <h3 className="text-white font-bold text-2xl leading-tight">
              Seu Portfólio
            </h3>
            <span className="text-white/80 text-sm">Registro dinâmico</span>
          </div>
        </div>

        {/* ——— Descrição breve ——— */}
        <div className="mb-6 text-white/80 text-sm leading-relaxed relative z-10">
          Seu portfólio dinâmico: conquistas, projetos e pesquisas integrados
          automaticamente para comprovar suas habilidades com evidências reais
          no ecossistema Syntropy.
        </div>

        {/* ——— Atividades ——— */}
        <div className="space-y-4 mb-6 relative z-10">
          <div className="bg-slate-700/50 rounded-lg p-4 flex items-center gap-4">
            <Award className="h-6 w-6 text-yellow-400" />
            <div>
              <h4 className="text-white font-medium">Cursos & Certificações</h4>
              <p className="text-slate-400 text-sm">8 cursos, 3 certificados</p>
            </div>
          </div>
          <div className="bg-slate-700/50 rounded-lg p-4 flex items-center gap-4">
            <Briefcase className="h-6 w-6 text-blue-400" />
            <div>
              <h4 className="text-white font-medium">Projetos Concluídos</h4>
              <p className="text-slate-400 text-sm">
                5 projetos, 12 colaborações
              </p>
            </div>
          </div>
          <div className="bg-slate-700/50 rounded-lg p-4 flex items-center gap-4">
            <GraduationCap className="h-6 w-6 text-purple-400" />
            <div>
              <h4 className="text-white font-medium">Atividades Científicas</h4>
              <p className="text-slate-400 text-sm">2 artigos, 1 laboratório</p>
            </div>
          </div>
        </div>

        {/* ——— Barra divisória ——— */}
        <div
          className="w-full h-[2px] my-4 rounded"
          style={{
            background:
              "linear-gradient(90deg, #FFB36B 0%, #FF6B00 55%, #BF4100 100%)",
            opacity: 0.25,
            boxShadow: "0 1px 8px #FF6B0033",
          }}
        />

        {/* ——— Stats ——— */}
        <div className="grid grid-cols-3 gap-3 text-center mt-4 relative z-10">
          <div>
            <div className="text-blue-400 font-bold text-base">15</div>
            <div className="text-slate-400 text-xs">Conquistas</div>
          </div>
          <div>
            <div className="text-green-400 font-bold text-base">120</div>
            <div className="text-slate-400 text-xs">Contribuições</div>
          </div>
          <div>
            <div className="text-yellow-400 font-bold text-base">7</div>
            <div className="text-slate-400 text-xs">Certificados</div>
          </div>
        </div>

        {/* ——— Inner shadow p/ profundidade ——— */}
        <div
          className="pointer-events-none absolute inset-0 rounded-[16px] h-full w-full min-h-full min-w-full"
          style={{
            boxShadow:
              "inset 0 2px 24px 0 #0008, inset 0 -2px 24px 0 #BF410022",
            zIndex: 2,
          }}
        />
      </motion.div>
    </Link>
  );
}


// Gradiente para ícones e textos
const gradient = "linear-gradient(90deg, #00AFFF 0%, #33DDFF 80%, #B266FF 100%)"

// SVGs customizados
function TrailIcon() {
  return (
    <svg width="32" height="32" viewBox="0 0 32 32" fill="none">
      <path
        d="M6 26C6 19 12 13 19 13H26"
        stroke="url(#trail)"
        strokeWidth="2.5"
        strokeLinecap="round"
      />
      <circle cx="6" cy="26" r="3" fill="url(#trail)" />
      <circle cx="26" cy="13" r="3" fill="url(#trail)" />
      <defs>
        <linearGradient id="trail" x1="6" y1="26" x2="26" y2="13" gradientUnits="userSpaceOnUse">
          <stop stopColor="#00AFFF" />
          <stop offset="0.8" stopColor="#33DDFF" />
          <stop offset="1" stopColor="#B266FF" />
        </linearGradient>
      </defs>
    </svg>
  )
}
function MentorshipIcon() {
  return (
    <svg width="32" height="32" viewBox="0 0 32 32" fill="none">
      <circle cx="10" cy="14" r="4" stroke="url(#mentorship)" strokeWidth="2.5" />
      <circle cx="22" cy="14" r="4" stroke="url(#mentorship)" strokeWidth="2.5" />
      <path d="M6 24c2-4 8-4 10 0" stroke="url(#mentorship)" strokeWidth="2.5" strokeLinecap="round" />
      <path d="M16 24c2-4 8-4 10 0" stroke="url(#mentorship)" strokeWidth="2.5" strokeLinecap="round" />
      <defs>
        <linearGradient id="mentorship" x1="6" y1="24" x2="26" y2="10" gradientUnits="userSpaceOnUse">
          <stop stopColor="#00AFFF" />
          <stop offset="0.8" stopColor="#33DDFF" />
          <stop offset="1" stopColor="#B266FF" />
        </linearGradient>
      </defs>
    </svg>
  )
}
function ModularIcon() {
  return (
    <svg width="32" height="32" viewBox="0 0 32 32" fill="none">
      <rect x="4" y="4" width="10" height="10" rx="3" stroke="url(#modular)" strokeWidth="2.5" />
      <rect x="18" y="4" width="10" height="10" rx="3" stroke="url(#modular)" strokeWidth="2.5" />
      <rect x="11" y="18" width="10" height="10" rx="3" stroke="url(#modular)" strokeWidth="2.5" />
      <defs>
        <linearGradient id="modular" x1="4" y1="4" x2="28" y2="28" gradientUnits="userSpaceOnUse">
          <stop stopColor="#00AFFF" />
          <stop offset="0.8" stopColor="#33DDFF" />
          <stop offset="1" stopColor="#B266FF" />
        </linearGradient>
      </defs>
    </svg>
  )
}

// Partículas de código flutuantes
function CodeParticles() {
  const particles = [
    { x: "10%", y: "15%", text: "</>", size: "text-xs" },
    { x: "80%", y: "25%", text: "{}", size: "text-base" },
    { x: "20%", y: "80%", text: "[]", size: "text-sm" },
    { x: "70%", y: "70%", text: "</>", size: "text-lg" },
    { x: "50%", y: "50%", text: "{}", size: "text-xs" },
  ]
  return (
    <AnimatePresence>
      {particles.map((p, i) => (
        <motion.span
          key={i}
          className={`absolute pointer-events-none select-none font-mono ${p.size} text-white/30`}
          style={{ left: p.x, top: p.y, zIndex: 0 }}
          initial={{ opacity: 0, y: -10 }}
          animate={{ opacity: 1, y: [0, -5, 0] }}
          exit={{ opacity: 0 }}
          transition={{ duration: 3 + i, repeat: Infinity, repeatType: "reverse", delay: i * 0.5 }}
        >
          {p.text}
        </motion.span>
      ))}
    </AnimatePresence>
  )
}

// Badge LE com glow animado
function BadgeLE() {
  return (
    <motion.div
      className="relative w-14 h-14 flex items-center justify-center rounded-full"
      style={{
        background: "linear-gradient(135deg, #00AFFF 0%, #33DDFF 80%, #B266FF 100%)",
        boxShadow: "0 0 24px 6px #00AFFF55, 0 0 0 2px #fff2",
        border: "3px solid #fff3",
        perspective: 100,
      }}
      initial={{ boxShadow: "0 0 24px 6px #00AFFF55" }}
      animate={{
        boxShadow: [
          "0 0 24px 6px #00AFFF55, 0 0 0 2px #fff2",
          "0 0 36px 12px #B266FF55, 0 0 0 2px #fff2"
        ],
        scale: [1, 1.08]
      }}
      transition={{ duration: 2, repeat: Infinity }}
      whileHover={{ scale: 1.12 }}
    >
      <span
        className="font-extrabold text-2xl text-white drop-shadow"
        style={{
          textShadow: "0 2px 8px #00AFFF88, 0 0 2px #fff",
          fontFamily: "inherit",
        }}
      >
        LE
      </span>
    </motion.div>
  )
}

// Métricas animadas
interface MetricProps {
  value: number;
  label: string;
  delay?: number;
}
function Metric({ value, label, delay = 0 }: MetricProps) {
  const [display, setDisplay] = useState(0)
  useEffect(() => {
    let start = 0
    const end = value
    const duration = 1.2
    let startTime: number | undefined
    function animateCount(ts: number) {
      if (!startTime) startTime = ts
      const progress = Math.min((ts - startTime) / (duration * 1000), 1)
      setDisplay(Math.floor(progress * (end - start) + start))
      if (progress < 1) requestAnimationFrame(animateCount)
      else setDisplay(end)
    }
    requestAnimationFrame(animateCount)
  }, [value])
  return (
    <motion.div
      className="flex flex-col items-center"
      initial={{ scale: 0.9, opacity: 0 }}
      animate={{ scale: 1, opacity: 1 }}
      transition={{ delay, duration: 0.7, type: "spring" }}
    >
      <span
        className="font-mono font-extrabold text-4xl md:text-5xl"
        style={{
          background: gradient,
          WebkitBackgroundClip: "text",
          WebkitTextFillColor: "transparent",
          backgroundClip: "text",
          filter: "drop-shadow(0 2px 8px #00AFFF44)",
        }}
      >
        {display}
      </span>
      <span className="text-xs text-white/60 mt-1">{label}</span>
      {/* Sparkline fake */}
      <svg width="40" height="12" className="mt-1" style={{ opacity: 0.5 }}>
        <polyline
          points="0,10 8,6 16,8 24,4 32,7 40,2"
          fill="none"
          stroke="url(#spark)"
          strokeWidth="2"
        />
        <defs>
          <linearGradient id="spark" x1="0" y1="0" x2="40" y2="0" gradientUnits="userSpaceOnUse">
            <stop stopColor="#00AFFF" />
            <stop offset="0.8" stopColor="#33DDFF" />
            <stop offset="1" stopColor="#B266FF" />
          </linearGradient>
        </defs>
      </svg>
    </motion.div>
  )
}

// Linha divisória com gradiente
function GradientDivider() {
  return (
    <div
      className="w-full h-[2px] my-4 rounded"
      style={{
        background: "linear-gradient(90deg, #00AFFF 0%, #33DDFF 80%, #B266FF 100%)",
        opacity: 0.25,
        boxShadow: "0 1px 8px #00AFFF33",
      }}
    />
  )
}

// Gradiente predominante roxo com azul de apoio

// SVG customizados para features
function CloudDevIcon() {
  return (
    <svg width="32" height="32" viewBox="0 0 32 32" fill="none">
      <ellipse cx="16" cy="20" rx="10" ry="6" fill="url(#clouddev)" />
      <ellipse cx="16" cy="16" rx="6" ry="4" fill="url(#clouddev)" opacity="0.7" />
      <defs>
        <linearGradient id="clouddev" x1="6" y1="20" x2="26" y2="12" gradientUnits="userSpaceOnUse">
          <stop stopColor="#7F3FFF" />
          <stop offset="0.7" stopColor="#33DDFF" />
          <stop offset="1" stopColor="#B266FF" />
        </linearGradient>
      </defs>
    </svg>
  )
}

// Novo ícone para Financiamento Transparente
function FundingFlowIcon() {
  return (
    <svg width="32" height="32" viewBox="0 0 32 32" fill="none">
      <path d="M8 18c0 4 4 6 8 6 4 0 8-2 8-6" stroke="url(#fundingflow)" strokeWidth="2.5" strokeLinecap="round" fill="none" />
      <path d="M24 14c0-4-4-6-8-6-2.5 0-5 .7-6.5 2.2" stroke="url(#fundingflow)" strokeWidth="2.5" strokeLinecap="round" fill="none" />
      <path d="M7 10l2.5 1.5M7 10l1.5 2.5" stroke="url(#fundingflow)" strokeWidth="2" strokeLinecap="round" />
      <path d="M25 22l-2.5-1.5M25 22l-1.5-2.5" stroke="url(#fundingflow)" strokeWidth="2" strokeLinecap="round" />
      <defs>
        <linearGradient id="fundingflow" x1="6" y1="8" x2="26" y2="24" gradientUnits="userSpaceOnUse">
          <stop stopColor="#7F3FFF" />
          <stop offset="0.7" stopColor="#33DDFF" />
          <stop offset="1" stopColor="#B266FF" />
        </linearGradient>
      </defs>
    </svg>
  )
}

function MatchIcon() {
  return (
    <svg width="32" height="32" viewBox="0 0 32 32" fill="none">
      <circle cx="10" cy="16" r="5" stroke="url(#match)" strokeWidth="2.5" />
      <circle cx="22" cy="16" r="5" stroke="url(#match)" strokeWidth="2.5" />
      <path d="M15 16h2" stroke="url(#match)" strokeWidth="2.5" strokeLinecap="round" />
      <defs>
        <linearGradient id="match" x1="10" y1="16" x2="22" y2="16" gradientUnits="userSpaceOnUse">
          <stop stopColor="#7F3FFF" />
          <stop offset="0.7" stopColor="#33DDFF" />
          <stop offset="1" stopColor="#B266FF" />
        </linearGradient>
      </defs>
    </svg>
  )
}

// Badge Projects
function BadgePJ() {
  return (
    <motion.div
      className="relative w-14 h-14 flex items-center justify-center rounded-full"
      style={{
        background: "linear-gradient(135deg, #7F3FFF 0%, #33DDFF 80%, #B266FF 100%)",
        boxShadow: "0 0 24px 6px #7F3FFF55, 0 0 0 2px #fff2",
        border: "3px solid #fff3",
        perspective: 100,
      }}
      initial={{ boxShadow: "0 0 24px 6px #7F3FFF55" }}
      animate={{
        boxShadow: [
          "0 0 24px 6px #7F3FFF55, 0 0 0 2px #fff2",
          "0 0 36px 12px #B266FF55, 0 0 0 2px #fff2"
        ],
        scale: [1, 1.08]
      }}
      transition={{ duration: 2, repeat: Infinity }}
      whileHover={{ scale: 1.12 }}
    >
      <span
        className="font-extrabold text-2xl text-white drop-shadow"
        style={{
          textShadow: "0 2px 8px #7F3FFF88, 0 0 2px #fff",
          fontFamily: "inherit",
        }}
      >
        PJ
      </span>
    </motion.div>
  )
}

// Barra divisória roxa-azul
function ProjectsDivider() {
  return (
    <div
      className="w-full h-[2px] my-4 rounded"
      style={{
        background: "linear-gradient(90deg, #7F3FFF 0%, #33DDFF 80%, #B266FF 100%)",
        opacity: 0.25,
        boxShadow: "0 1px 8px #7F3FFF33",
      }}
    />
  )
}

// Card principal – Syntropy Projects  •  Paleta "Desenvolva" atualizada
function SyntropyProjectsCard() {
  return (
    <Link
      href="/projects"
      tabIndex={-1}
      aria-label="Ir para Syntropy Projects"
      className="block focus:outline-none"
    >
      <motion.div
        className="relative overflow-visible"
        initial={{ y: 30, opacity: 0 }}
        animate={{ y: 0, opacity: 1 }}
        whileHover={{
          y: -8,
          boxShadow: "0 8px 48px 0 #6B00FF33, 0 1.5px 0 #ffffff22",
        }}
        transition={{ type: "spring", stiffness: 120, damping: 18 }}
        style={{
          /* ——— container glass ——— */
          background: "rgba(255,255,255,0.10)",
          backdropFilter: "blur(40px) saturate(150%)",
          border: "1.5px solid rgba(107,0,255,0.20)",
          borderRadius: 16,
          boxShadow:
            "0 8px 32px rgba(107,0,255,0.18), inset 0 1px 0 rgba(255,255,255,0.10)",
          maxWidth: 400,
          width: "100%",
          padding: 40,
          zIndex: 1,
        }}
        tabIndex={0}
        role="link"
        aria-label="Ir para Syntropy Projects"
      >
        {/* ——— Background mesh & partículas ——— */}
        <div
          className="absolute inset-0 rounded-[16px] pointer-events-none h-full w-full min-h-full min-w-full"
          style={{
            background:
              "radial-gradient(ellipse at 60% 20%, #C28DFF22 0%, transparent 70%), radial-gradient(ellipse at 20% 80%, #3E009E22 0%, transparent 70%)",
            zIndex: 0,
          }}
        />
        <CodeParticles />

        {/* ——— Header ——— */}
        <div className="flex items-center gap-4 mb-6 relative z-10">
          <PillarIconAnimated color="radial-gradient(circle at 30% 30%, #C28DFF 0%, #6B00FF 55%, #3E009E 100%)" shadow="#6B00FF99">
            <Users className="h-12 w-12 text-purple-100" strokeWidth={1.5} />
          </PillarIconAnimated>

          <div>
            <h3
              className="text-white font-bold text-2xl leading-tight"
              style={{ fontFamily: "inherit" }}
            >
              Syntropy Projects
            </h3>
            <span className="text-white/80 text-sm" style={{ fontWeight: 400 }}>
              Plataforma de Desenvolvimento
            </span>
          </div>
        </div>

        {/* ——— Descrição breve ——— */}
        <div className="mb-6 text-white/80 text-sm leading-relaxed relative z-10">
          Desenvolva, colabore e financie projetos open source com suporte
          completo e matchmaking inteligente.
        </div>

        {/* ——— Barra divisória ——— */}
        <div
          className="w-full h-[2px] my-4 rounded"
          style={{
            background:
              "linear-gradient(90deg, #C28DFF 0%, #6B00FF 55%, #3E009E 100%)",
            opacity: 0.25,
            boxShadow: "0 1px 8px #6B00FF33",
          }}
        />

        {/* ——— Features ——— */}
        <div className="space-y-7 mt-8 relative z-10">
          {/* item */}
          <div className="flex items-center gap-3 group cursor-pointer transition-all hover:scale-105">
            <span className="w-10 h-10 flex items-center justify-center">
              <CloudDevIcon />
            </span>
            <div>
              <span className="text-white font-semibold text-lg block">
                Ambiente Completo
              </span>
              <span className="text-white/70 text-sm">
                Dev em nuvem, versionamento e deploy
              </span>
            </div>
          </div>
          {/* item */}
          <div className="flex items-center gap-3 group cursor-pointer transition-all hover:scale-105">
            <span className="w-10 h-10 flex items-center justify-center">
              <MatchIcon />
            </span>
            <div>
              <span className="text-white font-semibold text-lg block">
                Matchmaking de Projetos
              </span>
              <span className="text-white/70 text-sm">
                Descubra projetos, faça a diferença
              </span>
            </div>
          </div>
          {/* item */}
          <div className="flex items-center gap-3 group cursor-pointer transition-all hover:scale-105">
            <span className="w-10 h-10 flex items-center justify-center">
              <FundingFlowIcon />
            </span>
            <div>
              <span className="text-white font-semibold text-lg block">
                Financiamento Transparente
              </span>
              <span className="text-white/70 text-sm">
                Capte recursos e acompanhe o impacto
              </span>
            </div>
          </div>
        </div>

        {/* ——— Inner shadow p/ profundidade ——— */}
        <div
          className="pointer-events-none absolute inset-0 rounded-[16px] h-full w-full min-h-full min-w-full"
          style={{
            boxShadow:
              "inset 0 2px 24px 0 #0008, inset 0 -2px 24px 0 #3E009E22",
            zIndex: 2,
          }}
        />
      </motion.div>
    </Link>
  );
}

// Card principal – Syntropy Learn  •  Paleta "Aprenda" atualizada
function SyntropyLearnCard() {
  return (
    <Link
      href="/learn"
      tabIndex={-1}
      aria-label="Ir para Syntropy Learn"
      className="block focus:outline-none"
    >
      <motion.div
        className="relative overflow-visible"
        initial={{ y: 30, opacity: 0 }}
        animate={{ y: 0, opacity: 1 }}
        whileHover={{
          y: -8,
          boxShadow: "0 8px 48px 0 #0075FF33, 0 1.5px 0 #ffffff22",
        }}
        transition={{ type: "spring", stiffness: 120, damping: 18 }}
        style={{
          /* ——— container glass ——— */
          background: "rgba(255,255,255,0.08)",
          backdropFilter: "blur(40px) saturate(150%)",
          border: "1.5px solid rgba(0,117,255,0.10)",
          borderRadius: 16,
          boxShadow:
            "0 8px 32px rgba(0,117,255,0.10), inset 0 1px 0 rgba(255,255,255,0.10)",
          maxWidth: 400,
          width: "100%",
          padding: 40,
          zIndex: 1,
        }}
        tabIndex={0}
        role="link"
        aria-label="Ir para Syntropy Learn"
      >
        {/* ——— Background mesh & partículas ——— */}
        <div
          className="absolute inset-0 rounded-[16px] pointer-events-none h-full w-full min-h-full min-w-full"
          style={{
            background:
              "radial-gradient(ellipse at 60% 20%, #4DA8FF22 0%, transparent 70%), radial-gradient(ellipse at 20% 80%, #003DD622 0%, transparent 70%)",
            zIndex: 0,
          }}
        />
        <CodeParticles />

        {/* ——— Header ——— */}
        <div className="flex items-center gap-4 mb-6 relative z-10">
          <PillarIconAnimated color="radial-gradient(circle at 30% 30%, #4DA8FF 0%, #0060FF 60%, #003DD6 100%)" shadow="#0075FFAA">
            <BookOpen className="h-12 w-12 text-blue-100" strokeWidth={1.5} />
          </PillarIconAnimated>

          <div>
            <h3
              className="text-white font-bold text-2xl leading-tight"
              style={{ fontFamily: "inherit" }}
            >
              Syntropy Learn
            </h3>
            <span className="text-white/80 text-sm" style={{ fontWeight: 400 }}>
              Plataforma de Aprendizado
            </span>
          </div>
        </div>

        {/* ——— Descrição breve ——— */}
        <div className="mb-6 text-white/80 text-sm leading-relaxed relative z-10">
          Plataforma de aprendizado prático, trilhas modulares e mentoria
          colaborativa para você evoluir construindo projetos reais.
        </div>

        {/* ——— Barra divisória ——— */}
        <div
          className="w-full h-[2px] my-4 rounded"
          style={{
            background:
              "linear-gradient(90deg, #4DA8FF 0%, #0060FF 60%, #003DD6 100%)",
            opacity: 0.25,
            boxShadow: "0 1px 8px #0075FF33",
          }}
        />

        {/* ——— Features ——— */}
        <div className="space-y-7 mt-8 relative z-10">
          {/* item */}
          <div className="flex items-center gap-3 group cursor-pointer transition-all hover:scale-105">
            <span className="w-10 h-10 flex items-center justify-center">
              <TrailIcon />
            </span>
            <div>
              <span className="text-white font-semibold text-lg block">
                Trilhas Interconectadas
              </span>
              <span className="text-white/70 text-sm">
                Progresso contínuo e modular
              </span>
            </div>
          </div>
          {/* item */}
          <div className="flex items-center gap-3 group cursor-pointer transition-all hover:scale-105">
            <span className="w-10 h-10 flex items-center justify-center">
              <MentorshipIcon />
            </span>
            <div>
              <span className="text-white font-semibold text-lg block">
                Mentoria & Comunidade
              </span>
              <span className="text-white/70 text-sm">
                Aprenda colaborando e ensinando
              </span>
            </div>
          </div>
          {/* item */}
          <div className="flex items-center gap-3 group cursor-pointer transition-all hover:scale-105">
            <span className="w-10 h-10 flex items-center justify-center">
              <ModularIcon />
            </span>
            <div>
              <span className="text-white font-semibold text-lg block">
                Formato Modular
              </span>
              <span className="text-white/70 text-sm">
                Cursos compactos, foco prático
              </span>
            </div>
          </div>
        </div>

        {/* ——— Inner shadow p/ profundidade ——— */}
        <div
          className="pointer-events-none absolute inset-0 rounded-[16px] h-full w-full min-h-full min-w-full"
          style={{
            boxShadow:
              "inset 0 2px 24px 0 #0008, inset 0 -2px 24px 0 #003DD622",
            zIndex: 2,
          }}
        />
      </motion.div>
    </Link>
  );
}


// Card principal – Syntropy Labs  •  Paleta "Pesquise" atualizada
function SyntropyLabsCard() {
  return (
    <Link
      href="/labs"
      tabIndex={-1}
      aria-label="Ir para Syntropy Labs"
      className="block focus:outline-none"
    >
      <motion.div
        className="relative overflow-visible"
        initial={{ y: 30, opacity: 0 }}
        animate={{ y: 0, opacity: 1 }}
        whileHover={{
          y: -8,
          boxShadow: "0 8px 48px 0 #9D00FF33, 0 1.5px 0 #ffffff22",
        }}
        transition={{ type: "spring", stiffness: 120, damping: 18 }}
        style={{
          /* ——— container glass ——— */
          background: "rgba(255,255,255,0.12)",
          backdropFilter: "blur(40px) saturate(150%)",
          border: "1.5px solid rgba(157,0,255,0.25)",
          borderRadius: 16,
          boxShadow:
            "0 8px 32px rgba(157,0,255,0.22), inset 0 1px 0 rgba(255,255,255,0.10)",
          maxWidth: 400,
          width: "100%",
          padding: 40,
          zIndex: 1,
        }}
        tabIndex={0}
        role="link"
        aria-label="Ir para Syntropy Labs"
      >
        {/* ——— Background mesh & partículas ——— */}
        <div
          className="absolute inset-0 rounded-[16px] pointer-events-none h-full w-full min-h-full min-w-full"
          style={{
            background:
              "radial-gradient(ellipse at 60% 20%, #F065FF22 0%, transparent 70%), radial-gradient(ellipse at 20% 80%, #5A00A822 0%, transparent 70%)",
            zIndex: 0,
          }}
        />
        <CodeParticles />

        {/* ——— Header ——— */}
        <div className="flex items-center gap-4 mb-6 relative z-10">
          <PillarIconAnimated color="radial-gradient(circle at 30% 30%, #F065FF 0%, #9D00FF 60%, #5A00A8 100%)" shadow="#9D00FF99">
            <FlaskConical className="h-12 w-12 text-pink-100" strokeWidth={1.5} />
          </PillarIconAnimated>

          <div>
            <h3
              className="text-white font-bold text-2xl leading-tight"
              style={{ fontFamily: "inherit" }}
            >
              Syntropy Labs
            </h3>
            <span className="text-white/80 text-sm" style={{ fontWeight: 400 }}>
              Ciência Descentralizada
            </span>
          </div>
        </div>

        {/* ——— Descrição breve ——— */}
        <div className="mb-6 text-white/80 text-sm leading-relaxed relative z-10">
          Laboratórios temáticos, colaboração global e gestão aberta para
          acelerar a ciência.
        </div>

        {/* ——— Barra divisória ——— */}
        <div
          className="w-full h-[2px] my-4 rounded"
          style={{
            background:
              "linear-gradient(90deg, #F065FF 0%, #9D00FF 60%, #5A00A8 100%)",
            opacity: 0.25,
            boxShadow: "0 1px 8px #9D00FF33",
          }}
        />

        {/* ——— Features ——— */}
        <div className="space-y-7 mt-8 relative z-10">
          {/* item */}
          <div className="flex items-center gap-3 group cursor-pointer transition-all hover:scale-105">
            <span className="w-10 h-10 flex items-center justify-center">
              <FlaskConical className="h-7 w-7 text-blue-300" />
            </span>
            <div>
              <span className="text-white font-semibold text-lg block">
                Labs Temáticos
              </span>
              <span className="text-white/70 text-sm">
                Projetos e equipes interdisciplinares
              </span>
            </div>
          </div>
          {/* item */}
          <div className="flex items-center gap-3 group cursor-pointer transition-all hover:scale-105">
            <span className="w-10 h-10 flex items-center justify-center">
              <GitBranch className="h-7 w-7 text-purple-300" />
            </span>
            <div>
              <span className="text-white font-semibold text-lg block">
                Gestão Científica
              </span>
              <span className="text-white/70 text-sm">
                Kanban, diários e versionamento
              </span>
            </div>
          </div>
          {/* item */}
          <div className="flex items-center gap-3 group cursor-pointer transition-all hover:scale-105">
            <span className="w-10 h-10 flex items-center justify-center">
              <Award className="h-7 w-7 text-yellow-300" />
            </span>
            <div>
              <span className="text-white font-semibold text-lg block">
                Publicação Aberta
              </span>
              <span className="text-white/70 text-sm">
                Peer review transparente
              </span>
            </div>
          </div>
        </div>

        {/* ——— Inner shadow p/ profundidade ——— */}
        <div
          className="pointer-events-none absolute inset-0 rounded-[16px] h-full w-full min-h-full min-w-full"
          style={{
            boxShadow:
              "inset 0 2px 24px 0 #0008, inset 0 -2px 24px 0 #5A00A822",
            zIndex: 2,
          }}
        />
      </motion.div>
    </Link>
  );
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

// Ícone Aprenda (badge animado, azul)
function PillarLearnIcon() {
  return (
    <motion.div
      className="relative w-20 h-20 flex items-center justify-center rounded-full"
      style={{
        background: "linear-gradient(135deg, #00AFFF 0%, #33DDFF 80%, #B266FF 100%)",
        boxShadow: "0 0 24px 6px #00AFFF55, 0 0 0 2px #fff2",
        border: "3px solid #fff3",
        perspective: 100,
      }}
      initial={{ boxShadow: "0 0 24px 6px #00AFFF55" }}
      animate={{
        boxShadow: [
          "0 0 24px 6px #00AFFF55, 0 0 0 2px #fff2",
          "0 0 36px 12px #B266FF55, 0 0 0 2px #fff2"
        ],
        scale: [1, 1.08]
      }}
      transition={{ duration: 2, repeat: Infinity }}
      whileHover={{ scale: 1.12 }}
    >
      <svg width="40" height="40" viewBox="0 0 40 40" fill="none">
        <rect x="6" y="8" width="28" height="20" rx="4" fill="url(#learn-bg)" />
        <path d="M12 16h16M12 20h16M12 24h10" stroke="#fff" strokeWidth="2" strokeLinecap="round"/>
        <defs>
          <linearGradient id="learn-bg" x1="6" y1="8" x2="34" y2="28" gradientUnits="userSpaceOnUse">
            <stop stopColor="#00AFFF" />
            <stop offset="0.8" stopColor="#33DDFF" />
            <stop offset="1" stopColor="#B266FF" />
          </linearGradient>
        </defs>
      </svg>
    </motion.div>
  )
}

// Ícone Desenvolva (badge animado, roxo)
function PillarDevelopIcon() {
  return (
    <motion.div
      className="relative w-20 h-20 flex items-center justify-center rounded-full"
      style={{
        background: "linear-gradient(135deg, #7F3FFF 0%, #33DDFF 80%, #B266FF 100%)",
        boxShadow: "0 0 24px 6px #7F3FFF55, 0 0 0 2px #fff2",
        border: "3px solid #fff3",
        perspective: 100,
      }}
      initial={{ boxShadow: "0 0 24px 6px #7F3FFF55" }}
      animate={{
        boxShadow: [
          "0 0 24px 6px #7F3FFF55, 0 0 0 2px #fff2",
          "0 0 36px 12px #B266FF55, 0 0 0 2px #fff2"
        ],
        scale: [1, 1.08]
      }}
      transition={{ duration: 2, repeat: Infinity }}
      whileHover={{ scale: 1.12 }}
    >
      <svg width="40" height="40" viewBox="0 0 40 40" fill="none">
        <circle cx="20" cy="20" r="14" fill="url(#dev-bg)" />
        <path d="M14 22l6-6 6 6" stroke="#fff" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"/>
        <defs>
          <linearGradient id="dev-bg" x1="6" y1="6" x2="34" y2="34" gradientUnits="userSpaceOnUse">
            <stop stopColor="#7F3FFF" />
            <stop offset="0.8" stopColor="#33DDFF" />
            <stop offset="1" stopColor="#B266FF" />
          </linearGradient>
        </defs>
      </svg>
    </motion.div>
  )
}

// Ícone Pesquise (badge animado, magenta)
function PillarResearchIcon() {
  return (
    <motion.div
      className="relative w-20 h-20 flex items-center justify-center rounded-full"
      style={{
        background: "linear-gradient(135deg, #A21CAF 0%, #6D28D9 80%, #B266FF 100%)",
        boxShadow: "0 0 24px 6px #A21CAF55, 0 0 0 2px #fff2",
        border: "3px solid #fff3",
        perspective: 100,
      }}
      initial={{ boxShadow: "0 0 24px 6px #A21CAF55" }}
      animate={{
        boxShadow: [
          "0 0 24px 6px #A21CAF55, 0 0 0 2px #fff2",
          "0 0 36px 12px #B266FF55, 0 0 0 2px #fff2"
        ],
        scale: [1, 1.08]
      }}
      transition={{ duration: 2, repeat: Infinity }}
      whileHover={{ scale: 1.12 }}
    >
      <svg width="40" height="40" viewBox="0 0 40 40" fill="none">
        <ellipse cx="20" cy="18" rx="10" ry="8" fill="url(#research-bg)" />
        <circle cx="20" cy="18" r="5" fill="#fff" fillOpacity="0.2"/>
        <path d="M28 28l-4-4" stroke="#fff" strokeWidth="2" strokeLinecap="round"/>
        <defs>
          <linearGradient id="research-bg" x1="10" y1="10" x2="30" y2="26" gradientUnits="userSpaceOnUse">
            <stop stopColor="#A21CAF" />
            <stop offset="0.8" stopColor="#6D28D9" />
            <stop offset="1" stopColor="#B266FF" />
          </linearGradient>
        </defs>
      </svg>
    </motion.div>
  )
}

function PillarIconAnimated({ children, color, shadow }: { children: React.ReactNode, color: string, shadow: string }) {
  return (
    <motion.div
      className="relative w-20 h-20 flex items-center justify-center rounded-full"
      style={{
        background: color,
        border: "2.5px solid #fff2",
        perspective: 100,
      }}
      initial={{ boxShadow: `0 0 12px 2px ${shadow}55` }}
      animate={{
        boxShadow: [
          `0 0 12px 2px ${shadow}55, 0 0 0 1.5px #fff2`,
          `0 0 20px 6px ${shadow}33, 0 0 0 1.5px #fff2`
        ],
        scale: [1, 1.04]
      }}
      transition={{ duration: 2.5, repeat: Infinity }}
      whileHover={{ scale: 1.09 }}
    >
      {children}
    </motion.div>
  )
}

// Card principal – Contribua  •  Paleta "Verde-Contribuição"
function ContributeCard() {
  return (
    <Link
      href="/contribute"
      tabIndex={-1}
      aria-label="Ir para página de contribuição"
      className="block focus:outline-none"
    >
      <motion.div
        className="relative overflow-visible"
        initial={{ y: 30, opacity: 0 }}
        animate={{ y: 0, opacity: 1 }}
        whileHover={{
          y: -8,
          boxShadow: "0 8px 48px 0 #00C85333, 0 1.5px 0 #ffffff22",
        }}
        transition={{ type: "spring", stiffness: 120, damping: 18 }}
        style={{
          /* ——— container glass ——— */
          background: "rgba(255,255,255,0.10)",
          backdropFilter: "blur(40px) saturate(150%)",
          border: "1.5px solid rgba(0,200,83,0.18)",
          borderRadius: 16,
          boxShadow:
            "0 8px 32px rgba(0,200,83,0.10), inset 0 1px 0 rgba(255,255,255,0.10)",
          maxWidth: 400,
          width: "100%",
          padding: 40,
          zIndex: 1,
        }}
        tabIndex={0}
        role="link"
        aria-label="Ir para página de contribuição"
      >
        {/* ——— Background mesh & partículas ——— */}
        <div
          className="absolute inset-0 rounded-[16px] pointer-events-none h-full w-full min-h-full min-w-full"
          style={{
            background:
              "radial-gradient(ellipse at 60% 20%, #96FFA622 0%, transparent 70%), radial-gradient(ellipse at 20% 80%, #006C2C22 0%, transparent 70%)",
            zIndex: 0,
          }}
        />
        {/* Ícone Contribuição */}
        <div className="flex items-center gap-4 mb-6 relative z-10">
          <PillarIconAnimated color="radial-gradient(circle at 30% 30%, #96FFA6 0%, #00C853 55%, #006C2C 100%)" shadow="#00C85399">
            <svg width="56" height="56" viewBox="0 0 56 56" fill="none">
              <circle cx="28" cy="28" r="26" fill="#00C853" fillOpacity="0.15" />
              <circle cx="17.5" cy="36" r="6.5" stroke="#96FFA6" strokeWidth="2.5" fill="none"/>
              <circle cx="38.5" cy="36" r="6.5" stroke="#96FFA6" strokeWidth="2.5" fill="none"/>
              <circle cx="28" cy="19" r="6.5" stroke="#96FFA6" strokeWidth="2.5" fill="none"/>
              <path d="M22 40c3.2 2.2 12.8 2.2 16 0" stroke="#96FFA6" strokeWidth="2" fill="none"/>
              <path d="M23.5 24c-3.2 2.2-6.5 6.5-6.5 9.5" stroke="#96FFA6" strokeWidth="2" fill="none"/>
              <path d="M32.5 24c3.2 2.2 6.5 6.5 6.5 9.5" stroke="#96FFA6" strokeWidth="2" fill="none"/>
            </svg>
          </PillarIconAnimated>

          <div>
            <h3
              className="text-white font-bold text-2xl leading-tight"
              style={{ fontFamily: "inherit" }}
            >
              Contribua
            </h3>
            <span className="text-white/80 text-sm" style={{ fontWeight: 400 }}>
              Faça parte da comunidade
            </span>
          </div>
        </div>

        {/* ——— Descrição breve ——— */}
        <div className="mb-6 text-white/80 text-sm leading-relaxed relative z-10">
          Código aberto, comunidade vibrante e espaço para todos crescerem
          juntos. Compartilhe ideias, envie PRs e colabore para transformar o
          Syntropy!
        </div>

        {/* ——— Barra divisória ——— */}
        <div
          className="w-full h-[2px] my-4 rounded"
          style={{
            background:
              "linear-gradient(90deg, #96FFA6 0%, #00C853 55%, #006C2C 100%)",
            opacity: 0.25,
            boxShadow: "0 1px 8px #00C85333",
          }}
        />

        {/* ——— Bullets ——— */}
        <div className="space-y-4 mt-8 relative z-10">
          {[
            {
              icon: <Lightbulb className="h-6 w-6 text-emerald-300" />,
              text: "Sugerir melhorias e novas features",
            },
            {
              icon: <Check className="h-6 w-6 text-green-400" />,
              text: "Corrigir bugs e problemas",
            },
            {
              icon: <FileText className="h-6 w-6 text-lime-300" />,
              text: "Melhorar a documentação",
            },
            {
              icon: <MessageCircle className="h-6 w-6 text-yellow-400" />,
              text: "Participar das discussões",
            },
          ].map((item, i) => (
            <div
              key={i}
              className="flex items-center gap-3 group cursor-pointer transition-all hover:scale-105"
            >
              <span className="w-8 h-8 flex items-center justify-center">
                {item.icon}
              </span>
              <span className="text-white/80 text-base">{item.text}</span>
            </div>
          ))}
        </div>

        {/* ——— Inner shadow p/ profundidade ——— */}
        <div
          className="pointer-events-none absolute inset-0 rounded-[16px] h-full w-full min-h-full min-w-full"
          style={{
            boxShadow:
              "inset 0 2px 24px 0 #0008, inset 0 -2px 24px 0 #006C2C22",
            zIndex: 2,
          }}
        />
      </motion.div>
    </Link>
  );
}

export default function HomePage() {
  const { scrollYProgress } = useScroll()
  const heroY = useTransform(scrollYProgress, [0, 0.3], [0, -100])
  const heroOpacity = useTransform(scrollYProgress, [0, 0.3], [1, 0])
  const { user, loading } = useAuth()

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
            O ecossistema open source que une aprendizado prático, desenvolvimento colaborativo e pesquisa científica em uma plataforma integrada
          </motion.p>

          {/* Three Pillars */}
          <motion.div
            className="grid md:grid-cols-3 gap-12 max-w-4xl mx-auto"
            initial={{ opacity: 0, y: 50 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ delay: 1.2, duration: 0.8 }}
          >
            {[
              {
                icon: (
                  <PillarIconAnimated
                    color="radial-gradient(circle at 30% 30%, #4DA8FF 0%, #0060FF 60%, #003DD6 100%)"
                    shadow="#0075FFAA"
                  >
                    <BookOpen className="h-12 w-12 text-blue-100" strokeWidth={1.5} />
                  </PillarIconAnimated>
                ),
                title: "Aprenda",
                sectionId: "aprenda",
              },
              {
                icon: (
                  <PillarIconAnimated
                    color="radial-gradient(circle at 30% 30%, #C28DFF 0%, #6B00FF 55%, #3E009E 100%)"
                    shadow="#6B00FF99"
                  >
                    <Users className="h-12 w-12 text-purple-100" strokeWidth={1.5} />
                  </PillarIconAnimated>
                ),
                title: "Desenvolva",
                sectionId: "desenvolva",
              },
              {
                icon: (
                  <PillarIconAnimated
                    color="radial-gradient(circle at 30% 30%, #F065FF 0%, #9D00FF 60%, #5A00A8 100%)"
                    shadow="#9D00FF99"
                  >
                    <FlaskConical className="h-12 w-12 text-pink-100" strokeWidth={1.5} />
                  </PillarIconAnimated>
                ),
                title: "Pesquise",
                sectionId: "pesquise",
              },
            ].map(({ icon, title, sectionId }) => (
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
                <div className="mb-6">{icon}</div>
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
              <SyntropyLearnCard />
            </div>
            <div>
              <div className="hidden md:block">
                <h2 className="text-4xl md:text-5xl font-bold mb-6 text-white">Aprenda construindo projetos reais</h2>
                <p className="text-xl text-white/80 mb-8 leading-relaxed">
                  Desenvolva habilidades através de trilhas interativas e projetos práticos em um ambiente de desenvolvimento 100% online. Construa seu portfólio enquanto aprende, publique projetos open source e conecte-se com uma comunidade colaborativa global.
                </p>
                <div className="space-y-4 mb-8">
                  {["Trilhas baseadas em projetos", "Aprenda fazendo, sem instalações", "Portifólio Integrado"].map((item, index) => (
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
                  <Link href="/learn">Conhecer Syntropy Learn</Link>
                </Button>
              </div>
            </div>
          </div>
        </div>
      </AnimatedSection>

      {/* Build Section */}
      <AnimatedSection id="desenvolva" className="bg-white/5">
        <div className="container mx-auto">
          <div className="grid lg:grid-cols-2 gap-16 items-center max-w-6xl mx-auto">
            <div>
              <div className="hidden md:block">
                <h2 className="text-4xl md:text-5xl font-bold mb-6 text-white">Colabore em projetos open source</h2>
                <p className="text-xl text-white/80 mb-8 leading-relaxed">
                  Descubra projetos open source alinhados ao seu perfil e contribua com facilidade. Ambiente colaborativo completo, ferramentas integradas e sistema de financiamento transparente, tudo para transformar suas ideias em soluções reais que impactam a comunidade.
                </p>
                <div className="space-y-4 mb-8">
                  {["Descoberta inteligente de projetos", "Ferramentas colaborativas integradas", "Sistema de financiamento transparente"].map(
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
                  <Link href="/projects">Conhecer Syntropy Projects</Link>
                </Button>
              </div>
            </div>
            <div className="flex justify-center">
              <SyntropyProjectsCard />
            </div>
          </div>
        </div>
      </AnimatedSection>

      {/* Research Section */}
      <AnimatedSection id="pesquise">
        <div className="container mx-auto">
          <div className="grid lg:grid-cols-2 gap-16 items-center max-w-6xl mx-auto">
            <div className="flex justify-center">
              <SyntropyLabsCard />
            </div>
            <div>
              <div className="hidden md:block">
                <h2 className="text-4xl md:text-5xl font-bold mb-6 text-white">Ciência aberta e colaborativa</h2>
                <p className="text-xl text-white/80 mb-8 leading-relaxed">
                  Revolucione a pesquisa científica. Participe de laboratórios temáticos descentralizados, colabore com pesquisadores globalmente e publique descobertas com revisão por pares transparente. Transforme a ciência em um processo aberto, reprodutível e acessível a todos.
                </p>
                <div className="space-y-4 mb-8">
                  {["Laboratórios descentralizados", "Revisão por pares transparente", "Publicação científica aberta"].map((item, index) => (
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
                  <Link href="/labs">Conhecer Syntropy Labs</Link>
                </Button>
              </div>
            </div>
          </div>
        </div>
      </AnimatedSection>

      {/* Portfolio Section */}
      <AnimatedSection id="portfolio">
        <div className="container mx-auto">
          <div className="grid lg:grid-cols-2 gap-16 items-center max-w-6xl mx-auto">
            <div>
              <div className="hidden md:block">
                <h2 className="text-4xl md:text-5xl font-bold mb-6">Seu currículo vivo no ecossistema Syntropy</h2>
                <p className="text-xl text-white/80 mb-8 leading-relaxed">
                  Transforme cada ação no ecossistema Syntropy em conquista profissional. Cursos, projetos, contribuições open source e pesquisas científicas se integram automaticamente ao seu portfólio dinâmico. Comprove suas habilidades com evidências reais de impacto.
                </p>
                <div className="space-y-4 mb-8">
                  {[
                    "Cursos e certificações verificáveis",
                    "Projetos com métricas de impacto",
                    "Contribuições científicas documentadas",
                    "Histórico completo de colaborações",
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
                  <Link href="/portfolio">Começar meu portfólio</Link>
                </Button>
              </div>
            </div>
            <div className="flex justify-center">
              <PortfolioCard />
            </div>
          </div>
        </div>
      </AnimatedSection>

      {/* CTA Section */}
      {(!loading && !user) && (
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
                Faça parte do ecossistema que conecta aprendizado prático, desenvolvimento colaborativo e pesquisa científica descentralizada.
              </p>
              <Button size="lg" className="bg-blue-600 hover:bg-blue-700 text-white px-12 py-4 text-lg">
                <Link href="/auth?mode=signup">Começar minha jornada</Link>
              </Button>
            </div>
          </div>
        </AnimatedSection>
      )}

      {/* Contribute Section */}
      <AnimatedSection id="contribute" className="bg-gradient-to-r from-blue-900/30 via-slate-900 to-pink-900/20">
        <div className="container mx-auto">
          <div className="flex flex-col md:flex-row-reverse items-center justify-center gap-12 max-w-5xl mx-auto py-12">
            <motion.div
              className="flex-1 text-center md:text-left hidden md:block"
              initial={{ opacity: 0, x: -40 }}
              whileInView={{ opacity: 1, x: 0 }}
              transition={{ duration: 0.8 }}
            >
              <h2 className="text-4xl md:text-5xl font-bold mb-6">
                Construa o futuro com a gente!
              </h2>
              <p className="text-xl text-white/80 mb-8 max-w-xl">
                O Syntropy é feito por pessoas como você. Contribua com código, ideias ou documentação e faça parte de uma comunidade que valoriza colaboração, inovação e impacto real. Toda contribuição conta!
              </p>
              <Button size="lg" className="bg-blue-600 hover:bg-blue-700 text-white px-10 py-4 text-xl">
                <Link href="/contribute">Quero contribuir</Link>
              </Button>
            </motion.div>
            <motion.div
              className="flex-1 flex justify-center"
              initial={{ opacity: 0, x: 40 }}
              whileInView={{ opacity: 1, x: 0 }}
              transition={{ duration: 0.8, delay: 0.2 }}
            >
              <ContributeCard />
            </motion.div>
          </div>
        </div>
      </AnimatedSection>
    </div>
  )
}
