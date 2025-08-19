import Link from "next/link"
import { Github, Twitter, Linkedin } from "lucide-react"

export function Footer() {
  return (
    <footer className="border-t bg-muted/50">
      <div className="container py-12">
        <div className="grid grid-cols-1 md:grid-cols-4 gap-8">
          <div className="space-y-4">
            <div className="flex items-center gap-2">
              <img
                src="/images/syntropy-logo-transparent.png"
                alt="Logo Syntropy"
                className="h-8 w-8 object-contain"
                width={32}
                height={32}
              />
              <span className="font-bold text-xl">Syntropy</span>
            </div>
            <p className="text-sm text-muted-foreground">
              Uma plataforma moderna de aprendizado para desenvolvedores dominarem novas tecnologias.
            </p>
            <div className="flex gap-4">
              <Link href="#" className="text-muted-foreground hover:text-primary">
                <Github className="h-5 w-5" />
              </Link>
              <Link href="#" className="text-muted-foreground hover:text-primary">
                <Twitter className="h-5 w-5" />
              </Link>
              <Link href="#" className="text-muted-foreground hover:text-primary">
                <Linkedin className="h-5 w-5" />
              </Link>
            </div>
          </div>

          <div>
            <h3 className="font-semibold mb-4">Aprenda</h3>
            <ul className="space-y-2 text-sm">
              <li>
                <Link href="/learn/courses" className="text-muted-foreground hover:text-primary">
                  Todos os Cursos
                </Link>
              </li>
              <li>
                <Link href="/learn" className="text-muted-foreground hover:text-primary">
                  Trilhas de Aprendizagem
                </Link>
              </li>
              <li>
                <Link href="#" className="text-muted-foreground hover:text-primary">
                  Certificações
                </Link>
              </li>
            </ul>
          </div>

          <div>
            <h3 className="font-semibold mb-4">Construa</h3>
            <ul className="space-y-2 text-sm">
              <li>
                <Link href="/projects" className="text-muted-foreground hover:text-primary">
                  Projetos
                </Link>
              </li>
              <li>
                <Link href="/labs" className="text-muted-foreground hover:text-primary">
                  Laboratórios
                </Link>
              </li>
              <li>
                <Link href="#" className="text-muted-foreground hover:text-primary">
                  Modelos
                </Link>
              </li>
            </ul>
          </div>

          <div>
            <h3 className="font-semibold mb-4">Comunidade</h3>
            <ul className="space-y-2 text-sm">
              <li>
                <Link href="#" className="text-muted-foreground hover:text-primary">
                  Discord
                </Link>
              </li>
              <li>
                <Link href="#" className="text-muted-foreground hover:text-primary">
                  Fórum
                </Link>
              </li>
              <li>
                <Link href="#" className="text-muted-foreground hover:text-primary">
                  Blog
                </Link>
              </li>
            </ul>
          </div>
        </div>

        <div className="border-t mt-8 pt-8 text-center text-sm text-muted-foreground">
          <p>&copy; 2024 Syntropy. Todos os direitos reservados.</p>
        </div>
      </div>
    </footer>
  )
}
