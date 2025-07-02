"use client"

import { motion } from "framer-motion"
import { Button } from "@/components/ui/button"
import { Github, Terminal, ListChecks, FileEdit, GitPullRequest, Users } from "lucide-react"
import Link from "next/link"

const steps = [
  {
    icon: <Github className="h-14 w-14 text-white drop-shadow-lg" />,
    color: "from-blue-700 via-blue-600 to-blue-800",
    title: "1. Crie uma conta no GitHub",
    description: (
      <>
        O GitHub é onde todo o código do Syntropy está hospedado. Se você ainda não tem uma conta, <b>crie uma gratuitamente</b> para começar a contribuir.
      </>
    ),
    action: (
      <Button asChild variant="secondary" className="mt-6" aria-label="Criar conta no GitHub">
        <Link href="https://github.com/join" target="_blank" rel="noopener noreferrer">
          Criar conta
        </Link>
      </Button>
    ),
  },
  {
    icon: <Terminal className="h-14 w-14 text-white drop-shadow-lg" />,
    color: "from-purple-700 via-purple-600 to-purple-800",
    title: "2. Instale o Git e clone o repositório",
    description: (
      <>
        O <b>Git</b> é a ferramenta para baixar e enviar código. Instale o Git no seu computador (<Link href="https://git-scm.com/downloads" target="_blank" rel="noopener noreferrer" className="underline hover:text-cyan-300">download</Link>), abra o terminal e rode:
        <pre className="bg-slate-900/80 rounded-lg p-3 mt-3 text-sm text-white select-all overflow-x-auto border border-slate-700">git clone https://github.com/jescott07/syntropy.git</pre>
      </>
    ),
  },
  {
    icon: <ListChecks className="h-14 w-14 text-white drop-shadow-lg" />,
    color: "from-pink-700 via-pink-600 to-pink-800",
    title: "3. Escolha uma tarefa (issue)",
    description: (
      <>
        No GitHub, procure por <b>issues</b> marcadas como <span className="inline-block bg-blue-600/80 text-white px-2 py-0.5 rounded text-xs ml-1">good first issue</span> para iniciantes. Leia a descrição e escolha uma para começar.
      </>
    ),
    action: (
      <Button asChild variant="secondary" className="mt-6" aria-label="Ver issues para iniciantes">
        <Link href="https://github.com/jescott07/syntropy/issues?q=is%3Aissue+is%3Aopen+label%3A%22good+first+issue%22" target="_blank" rel="noopener noreferrer">
          Ver issues
        </Link>
      </Button>
    ),
  },
  {
    icon: <FileEdit className="h-14 w-14 text-white drop-shadow-lg" />,
    color: "from-blue-800 via-blue-700 to-blue-900",
    title: "4. Faça uma alteração no código",
    description: (
      <>
        Crie uma nova branch com <code className="bg-slate-800 px-2 py-1 rounded text-white">git checkout -b minha-contribuicao</code>, edite o arquivo desejado, salve e depois rode:
        <pre className="bg-slate-900/80 rounded-lg p-3 mt-3 text-sm text-white select-all overflow-x-auto border border-slate-700">git add .
git commit -m "Minha contribuição"
git push origin minha-contribuicao</pre>
      </>
    ),
  },
  {
    icon: <GitPullRequest className="h-14 w-14 text-white drop-shadow-lg" />,
    color: "from-purple-800 via-purple-700 to-purple-900",
    title: "5. Abra uma Pull Request (PR)",
    description: (
      <>
        No GitHub, clique em <b>Compare &amp; pull request</b> para enviar sua contribuição. Escreva um título claro e explique o que mudou. <Link href="https://docs.github.com/pt/pull-requests/collaborating-with-pull-requests/proposing-changes-to-your-work-with-pull-requests/about-pull-requests" target="_blank" rel="noopener noreferrer" className="underline hover:text-pink-300">Saiba mais</Link>.
      </>
    ),
  },
  {
    icon: <Users className="h-14 w-14 text-white drop-shadow-lg" />,
    color: "from-pink-800 via-pink-700 to-pink-900",
    title: "6. Participe da comunidade",
    description: (
      <>
        Tire dúvidas, compartilhe ideias e acompanhe novidades nos nossos canais. Sua participação é fundamental!
      </>
    ),
    action: (
      <div className="flex gap-3 mt-6">
        <Button asChild variant="secondary" aria-label="Entrar no YouTube">
          <Link href="https://www.youtube.com/@syntropy-cc" target="_blank" rel="noopener noreferrer">
            YouTube
          </Link>
        </Button>
        <Button asChild variant="secondary" aria-label="Entrar no Discord">
          <Link href="https://discord.gg/7w2n7n6" target="_blank" rel="noopener noreferrer">
            Discord
          </Link>
        </Button>
      </div>
    ),
  },
]

function StepSection({ step, i }: { step: typeof steps[0], i: number }) {
  return (
    <motion.section
      className={`w-full py-16 md:py-24 px-4 md:px-0 flex flex-col md:flex-row items-center justify-center gap-10 md:gap-16 bg-gradient-to-r ${step.color}`}
      initial={{ opacity: 0, y: 60 }}
      whileInView={{ opacity: 1, y: 0 }}
      viewport={{ once: true, margin: "-100px" }}
      transition={{ duration: 0.7, delay: i * 0.08 + 0.1, type: "spring" }}
      tabIndex={0}
      aria-label={step.title}
    >
      <div className="flex-shrink-0 flex items-center justify-center w-full md:w-auto">
        <div className="rounded-full bg-white/10 p-6 md:p-8 shadow-xl border-2 border-white/10 flex items-center justify-center">
          {step.icon}
        </div>
      </div>
      <div className="max-w-2xl text-center md:text-left">
        <h2 className="text-2xl md:text-3xl font-bold text-white mb-4 leading-tight">{step.title}</h2>
        <div className="text-white/90 text-lg leading-relaxed mb-6">{step.description}</div>
        {step.action && <div>{step.action}</div>}
      </div>
    </motion.section>
  )
}

export default function HowToContributePage() {
  return (
    <main className="bg-gradient-to-br from-[#0a1020] via-[#1e2a44]/40 to-[#181c2a] min-h-screen text-white overflow-x-hidden">
      <a href="#conteudo" className="skip-link">Pular para o conteúdo principal</a>
      <header className="text-center py-16 md:py-24">
        <motion.h1
          className="mb-4 text-4xl md:text-5xl font-bold"
          initial={{ opacity: 0, y: 30 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.8 }}
        >
          Guia passo a passo para contribuir
        </motion.h1>
        <motion.p
          className="max-w-2xl mx-auto text-xl text-white/80"
          initial={{ opacity: 0, y: 30 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ delay: 0.2, duration: 0.8 }}
        >
          Nunca contribuiu com open source? Siga este tutorial visual e faça parte do Syntropy, mesmo sem experiência prévia!
        </motion.p>
      </header>
      <section id="conteudo" tabIndex={-1} aria-label="Como contribuir passo a passo">
        {steps.map((step, i) => (
          <StepSection key={step.title} step={step} i={i} />
        ))}
      </section>
      <div className="text-center py-16">
        <Button asChild size="lg" className="btn btn-primary px-10 py-4 text-xl" aria-label="Voltar para página de contribuição">
          <Link href="/contribute">Voltar</Link>
        </Button>
      </div>
    </main>
  )
}
