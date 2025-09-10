import { Button } from "@/components/ui/button"
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card"
import { Badge } from "@/components/ui/badge"
import { Progress } from "@/components/ui/progress"
import { Play, Clock, BookOpen, Award, Users, Star, CheckCircle, Zap, Target, Code2, ChevronLeft, Bot, Rocket, DollarSign, Wrench } from "lucide-react"
import Link from "next/link"
import { getCourseSummary } from "@/lib/courses"
import { notFound } from "next/navigation"

export default async function CoursePage({
  params,
}: {
  params: { courseSlug: string }
}) {
  // Debug: Log do parâmetro recebido
  console.log('courseSlug recebido:', params.courseSlug)
  
  try {
    const course = await getCourseSummary(params.courseSlug)
    
    // Debug: Log do curso retornado
    console.log('Curso encontrado:', course ? 'SIM' : 'NÃO')
    console.log('Dados do curso:', course)
    
    // Verificação explícita se o curso existe
    if (!course) {
      console.log('Curso não encontrado, redirecionando para 404')
      notFound()
      return
    }

    // Verificação se tem blocos
    if (!course.blocks || course.blocks.length === 0) {
      console.log('Curso sem blocos')
      notFound()
      return
    }

    return (
      <div className="min-h-screen bg-gradient-to-br from-background to-muted/20">
        <div className="max-w-4xl mx-auto p-8">

        <div className="mb-6">
          <Link href="/learn/courses">
            <Button variant="ghost" className="flex items-center gap-2 text-muted-foreground hover:text-foreground">
              <ChevronLeft className="h-4 w-4" />
              Voltar para Cursos
            </Button>
          </Link>
        </div>


          {/* Hero Section */}
          <div className="relative mb-12">
            <div className="absolute inset-0 bg-gradient-to-r from-syntropy-600/10 to-transparent rounded-3xl" />
            <div className="relative p-8 md:p-12">
              <div className="flex items-center gap-2 mb-6">
                <Badge variant="secondary" className="text-sm px-3 py-1">
                  {course.level}
                </Badge>
                <Badge variant="outline" className="text-sm px-3 py-1">
                  <Clock className="mr-1 h-3 w-3" />
                  {course.duration} Horas
                </Badge>
                <Badge variant="outline" className="text-sm px-3 py-1">
                  <BookOpen className="mr-1 h-3 w-3" />
                  {course.unitCount} Unidades
                </Badge>
              </div>
              
              <h1 className="text-5xl md:text-6xl font-bold mb-6 bg-gradient-to-r from-foreground to-muted-foreground bg-clip-text text-transparent">
                {course.title}
              </h1>
              
              <p className="text-xl md:text-2xl text-muted-foreground mb-8 max-w-3xl leading-relaxed">
                {course.description}
              </p>

              {/* Instructor */}
              <div className="flex items-center gap-4 mb-8">
                <div className="w-12 h-12 bg-gradient-to-br from-syntropy-600 to-syntropy-700 rounded-full flex items-center justify-center text-white font-semibold text-lg">
                  {course.author?.name?.charAt(0) || 'A'}
                </div>
                <div>
                  <p className="font-semibold text-lg">{course.author?.name || 'Autor não informado'}</p>
                  <p className="text-muted-foreground">{course.author?.bio || 'Bio não informada'}</p>
                </div>
              </div>

              {/* Primary CTAs */}
              <div className="flex flex-col sm:flex-row gap-4">
                <Button asChild size="lg" className="text-lg px-8 py-6 shadow-lg hover:shadow-xl transition-all">
                  <Link href={`/learn/courses/${course.slug}/${course.blocks[0]?.units[0]?.slug}`}>
                    <Play className="mr-2 h-5 w-5" />
                    Começar Agora - Grátis
                  </Link>
                </Button>
                <Button asChild variant="outline" size="lg" className="text-lg px-8 py-6">
                  <Link href="#course-content">
                    <BookOpen className="mr-2 h-5 w-5" />
                    Ver Conteúdo Completo
                  </Link>
                </Button>
              </div>
            </div>
          </div>

          {/* Course Highlights - Subtle Design */}
          <div className="mb-8">
            <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
              {/* Duration */}
              <div className="group relative bg-muted/30 border border-border/50 rounded-xl p-4 hover:bg-muted/50 transition-all duration-200">
                <div className="flex items-center justify-center mb-2">
                  <Clock className="h-4 w-4 text-muted-foreground" />
                </div>
                <div className="text-center space-y-1">
                  <div className="text-2xl font-bold text-foreground">{course.duration}h</div>
                  <div className="text-sm text-muted-foreground">Duração</div>
                </div>
              </div>

              {/* Chapters */}
              <div className="group relative bg-muted/30 border border-border/50 rounded-xl p-4 hover:bg-muted/50 transition-all duration-200">
                <div className="flex items-center justify-center mb-2">
                  <BookOpen className="h-4 w-4 text-muted-foreground" />
                </div>
                <div className="text-center space-y-1">
                  <div className="text-2xl font-bold text-foreground">{course.unitCount}</div>
                  <div className="text-sm text-muted-foreground">Unidades</div>
                </div>
              </div>

              {/* Real Project */}
              <div className="group relative bg-muted/30 border border-border/50 rounded-xl p-4 hover:bg-muted/50 transition-all duration-200">
                <div className="flex items-center justify-center mb-2">
                  <Target className="h-4 w-4 text-muted-foreground" />
                </div>
                <div className="text-center space-y-1">
                  <div className="text-lg font-bold text-foreground">Projeto Real</div>
                  <div className="text-sm text-muted-foreground">Portfólio</div>
                </div>
              </div>

              {/* Community */}
              <div className="group relative bg-muted/30 border border-border/50 rounded-xl p-4 hover:bg-muted/50 transition-all duration-200">
                <div className="flex items-center justify-center mb-2">
                  <Users className="h-4 w-4 text-muted-foreground" />
                </div>
                <div className="text-center space-y-1">
                  <div className="text-lg font-bold text-foreground">Comunidade</div>
                  <div className="text-sm text-muted-foreground">Suporte mútuo</div>
                </div>
              </div>
            </div>
          </div>

          {/* Learning Points Section */}
          <div className="mb-12">
            <h2 className="text-3xl font-bold mb-8 text-center">O que você vai aprender neste curso</h2>
            <div className="grid md:grid-cols-2 lg:grid-cols-4 gap-6">
              {course.learningPoints?.map((point, index) => (
                <Card key={index} className="text-center p-6 hover:shadow-lg transition-all border-2 hover:border-syntropy-600/20">
                  <div className="w-12 h-12 bg-syntropy-100 rounded-full flex items-center justify-center mx-auto mb-4">
                    {index === 0 && <Bot className="h-6 w-6 text-syntropy-600" />}
                    {index === 1 && <Rocket className="h-6 w-6 text-syntropy-600" />}
                    {index === 2 && <DollarSign className="h-6 w-6 text-syntropy-600" />}
                    {index === 3 && <Wrench className="h-6 w-6 text-syntropy-600" />}
                  </div>
                  <h3 className="font-semibold mb-2">{point.title}</h3>
                  <p className="text-sm text-muted-foreground">{point.subtitle}</p>
                </Card>
              ))}
            </div>
          </div>

          {/* Project Description */}
          <Card className="border-2 mb-8">
            <CardHeader>
              <CardTitle className="text-2xl flex items-center gap-2">
                <Code2 className="h-6 w-6 text-syntropy-600" />
                Projeto que você vai construir
              </CardTitle>
              <CardDescription>Um produto real que funcionará em produção</CardDescription>
            </CardHeader>
            <CardContent>
              {/* Project Overview */}
              <div className="mb-6 p-4 bg-muted/30 rounded-lg border">
                <h3 className="font-semibold text-lg mb-2">{course.projectDescription?.title}</h3>
                <p className="text-muted-foreground">{course.projectDescription?.description}</p>
              </div>

              {/* Project Features */}
              <div className="mb-6">
                <div className="grid md:grid-cols-2 gap-4">
                  {course.projectDescription?.features?.map((feature, index) => (
                    <div key={index} className="group p-4 bg-background border border-border/50 rounded-lg hover:border-syntropy-600/30 transition-all duration-200">
                      <div className="flex items-start gap-3">
                        <div className="w-6 h-6 bg-syntropy-100 rounded-full flex items-center justify-center flex-shrink-0 mt-0.5">
                          <CheckCircle className="h-3 w-3 text-syntropy-600" />
                        </div>
                        <span className="text-sm font-medium group-hover:text-syntropy-600 transition-colors">{feature}</span>
                      </div>
                    </div>
                  ))}
                </div>
              </div>

              {/* Tech Stack */}
              <div>
                <h4 className="font-medium mb-3">Stack tecnológica:</h4>
                <div className="flex flex-wrap gap-2">
                  {course.projectDescription?.techStack?.map((tech, index) => (
                    <Badge key={index} variant="secondary" className="text-xs">
                      {tech}
                    </Badge>
                  ))}
                </div>
              </div>
            </CardContent>
          </Card>

          {/* Course Content */}
          <Card className="border-2" id="course-content">
            <CardHeader>
              <CardTitle className="text-2xl">Conteúdo do Curso</CardTitle>
              <CardDescription>
                {course.blocks.reduce((total, block) => total + block.units.length, 0)} unidades • {course.duration} horas de conteúdo prático
                {course.finished === "false" && (
                  <span className="ml-2 inline-flex items-center gap-1 px-2 py-1 bg-orange-100 text-orange-800 text-xs font-medium rounded-full">
                    <Clock className="h-3 w-3" />
                    Em construção
                  </span>
                )}
              </CardDescription>
            </CardHeader>
            <CardContent>
              <div className="space-y-6">
                {course.blocks.map((block, blockIndex) => (
                  <div key={block.id} className="space-y-3">
                    {/* Block Header */}
                    <div className="border-l-4 border-syntropy-600 pl-4 py-2">
                      <h3 className="font-bold text-lg text-syntropy-600">{block.title}</h3>
                      <p className="text-sm text-muted-foreground">{block.description}</p>
                    </div>
                    
                    {/* Units in Block */}
                    <div className="ml-4 space-y-3">
                      {block.units.map((unit, unitIndex) => (
                        <div key={unit.id} className="group border rounded-lg overflow-hidden hover:shadow-md transition-all">
                          {/* Unit Details Toggle */}
                          <details className="group/details">
                            <summary className="list-none">
                              {/* Main Unit Content - Clickable Link */}
                              <div className="relative group/unit">
                                <Link href={`/learn/courses/${course.slug}/${unit.slug}`} className="block p-4 hover:bg-muted/50 transition-colors">
                                  <div className="flex items-center gap-4">
                                    <div className="w-10 h-10 bg-gradient-to-br from-syntropy-600 to-syntropy-700 rounded-full flex items-center justify-center text-white font-semibold">
                                      {blockIndex + 1}.{unitIndex + 1}
                                    </div>
                                    <div className="flex-1">
                                      <h4 className="font-semibold text-lg group-hover:text-syntropy-600 transition-colors">
                                        {unit.title}
                                      </h4>
                                      {unit.description && (
                                        <p className="text-muted-foreground mt-1">
                                          {unit.description}
                                        </p>
                                      )}
                                      <div className="flex items-center gap-4 mt-2">
                                        {unit.duration && (
                                          <span className="text-sm text-muted-foreground flex items-center gap-1">
                                            <Clock className="h-3 w-3" />
                                            {unit.duration} min
                                          </span>
                                        )}
                                        {unit.artifact && (
                                          <span className="text-sm text-green-600 font-medium">
                                            ✓ Artefato prático incluído
                                          </span>
                                        )}
                                      </div>
                                    </div>
                                  </div>
                                </Link>
                                
                                {/* Hover Overlay with CTA Button */}
                                <div className="absolute inset-0 bg-black/70 opacity-0 group-hover/unit:opacity-100 transition-all duration-300 flex items-center justify-center backdrop-blur-sm">
                                  <Button 
                                    asChild 
                                    size="lg" 
                                    className="bg-syntropy-600 hover:bg-syntropy-700 text-white shadow-xl transform scale-95 group-hover/unit:scale-100 transition-all duration-300"
                                  >
                                    <Link href={`/learn/courses/${course.slug}/${unit.slug}`}>
                                      <Play className="mr-2 h-5 w-5" />
                                      Iniciar Unidade
                                    </Link>
                                  </Button>
                                </div>
                              </div>
                              
                              {/* Expandable Bottom Bar */}
                              <div className="h-8 bg-gradient-to-r from-syntropy-600/20 to-syntropy-600/60 group-hover:from-syntropy-600/40 group-hover:to-syntropy-600/80 transition-all cursor-pointer flex items-center justify-center relative">
                                <span className="text-xs text-white font-medium opacity-90 group-hover:opacity-100 transition-opacity">
                                  Ver fragmentos e conteúdo detalhado
                                </span>
                                <div className="absolute inset-0 bg-gradient-to-r from-transparent via-white/5 to-transparent animate-pulse" />
                              </div>
                            </summary>
                            
                            {/* Expandable Section Details */}
                            <div className="border-t bg-muted/30 p-4">
                              <h5 className="font-medium text-sm mb-3 text-muted-foreground uppercase tracking-wide">
                                Fragmentos da Unidade
                              </h5>
                              <div className="space-y-2">
                                {unit.fragments?.map((fragment, fragmentIndex) => (
                                  <div key={fragmentIndex} className="flex items-center justify-between py-2 px-3 bg-background rounded-md">
                                    <div className="flex items-center gap-3">
                                      <div className="w-2 h-2 rounded-full bg-blue-500" />
                                      <span className="text-sm">{fragment}</span>
                                    </div>
                                  </div>
                                ))}
                                {unit.artifact && (
                                  <div className="mt-3 p-3 bg-green-50 border border-green-200 rounded-md">
                                    <div className="flex items-start gap-3">
                                      <div className="w-2 h-2 rounded-full bg-green-500 mt-2" />
                                      <div>
                                        <span className="text-sm font-medium text-green-800">Artefato Prático:</span>
                                        <p className="text-sm text-green-700 mt-1">{unit.artifact}</p>
                                      </div>
                                    </div>
                                  </div>
                                )}
                              </div>
                            </div>
                          </details>
                        </div>
                      ))}
                    </div>
                  </div>
                ))}
              </div>
            </CardContent>
          </Card>



          {/* Final CTA */}
          <Card className="bg-gradient-to-br from-syntropy-600 to-syntropy-700 text-white border-0 mt-8">
            <CardContent className="p-8 text-center">
              <h3 className="font-bold text-2xl mb-3">Pronto para começar?</h3>
              <p className="text-syntropy-100 mb-6 text-lg">
                Junte-se a milhares de alunos que já transformaram suas carreiras
              </p>
              <Button asChild variant="secondary" size="lg" className="text-lg px-8 py-6">
                <Link href={`/learn/courses/${course.slug}/${course.blocks[0]?.units[0]?.slug}`}>
                  <Play className="mr-2 h-5 w-5" />
                  Começar Agora
                </Link>
              </Button>
            </CardContent>
          </Card>
        </div>
      </div>
    )
  } catch (error) {
    console.error('Erro ao carregar o curso:', error)
    notFound()
  }
}