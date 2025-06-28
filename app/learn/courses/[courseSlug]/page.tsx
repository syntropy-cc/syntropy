import { Button } from "@/components/ui/button"
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card"
import { Badge } from "@/components/ui/badge"
import { Progress } from "@/components/ui/progress"
import { Play, Clock, BookOpen, Award, Users, Star, CheckCircle, Zap, Target, Code2, ChevronLeft } from "lucide-react"
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

    // Verificação se tem capítulos
    if (!course.chapters || course.chapters.length === 0) {
      console.log('Curso sem capítulos')
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
                  {course.duration} hours
                </Badge>
                <Badge variant="outline" className="text-sm px-3 py-1">
                  <BookOpen className="mr-1 h-3 w-3" />
                  {course.chapters.length} chapters
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
                  <Link href={`/learn/courses/${course.slug}/${course.chapters[0]?.slug}`}>
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

          {/* Course Info Card - Simplified */}
          <Card className="mb-8 border">
            <CardContent className="p-6">
              <div className="grid grid-cols-2 md:grid-cols-4 gap-6 text-center">
                <div>
                  <div className="flex items-center justify-center gap-2 mb-1">
                    <Clock className="h-4 w-4 text-muted-foreground" />
                  </div>
                  <span className="font-semibold text-lg">{course.duration}h</span>
                  <p className="text-sm text-muted-foreground">Duração</p>
                </div>
                
                <div>
                  <div className="flex items-center justify-center gap-2 mb-1">
                    <BookOpen className="h-4 w-4 text-muted-foreground" />
                  </div>
                  <span className="font-semibold text-lg">{course.chapters.length}</span>
                  <p className="text-sm text-muted-foreground">Capítulos</p>
                </div>
                
                <div>
                  <div className="flex items-center justify-center gap-2 mb-1">
                    <Award className="h-4 w-4 text-muted-foreground" />
                  </div>
                  <span className="font-semibold text-lg text-green-600">Sim</span>
                  <p className="text-sm text-muted-foreground">Certificado</p>
                </div>
                
                <div>
                  <div className="flex items-center justify-center gap-2 mb-1">
                    <Users className="h-4 w-4 text-muted-foreground" />
                  </div>
                  <span className="font-semibold text-lg">Vitalício</span>
                  <p className="text-sm text-muted-foreground">Acesso</p>
                </div>
              </div>
            </CardContent>
          </Card>

          {/* Key Benefits Section */}
          <div className="mb-12">
            <h2 className="text-3xl font-bold mb-8 text-center">Por que escolher este curso?</h2>
            <div className="grid md:grid-cols-2 lg:grid-cols-4 gap-6">
              <Card className="text-center p-6 hover:shadow-lg transition-all border-2 hover:border-syntropy-600/20">
                <div className="w-12 h-12 bg-green-100 rounded-full flex items-center justify-center mx-auto mb-4">
                  <Zap className="h-6 w-6 text-green-600" />
                </div>
                <h3 className="font-semibold mb-2">100% Hands-on</h3>
                <p className="text-sm text-muted-foreground">Código desde a primeira aula</p>
              </Card>
              
              <Card className="text-center p-6 hover:shadow-lg transition-all border-2 hover:border-syntropy-600/20">
                <div className="w-12 h-12 bg-blue-100 rounded-full flex items-center justify-center mx-auto mb-4">
                  <Target className="h-6 w-6 text-blue-600" />
                </div>
                <h3 className="font-semibold mb-2">Projetos Reais</h3>
                <p className="text-sm text-muted-foreground">Para seu portfólio</p>
              </Card>
              
              <Card className="text-center p-6 hover:shadow-lg transition-all border-2 hover:border-syntropy-600/20">
                <div className="w-12 h-12 bg-purple-100 rounded-full flex items-center justify-center mx-auto mb-4">
                  <Users className="h-6 w-6 text-purple-600" />
                </div>
                <h3 className="font-semibold mb-2">Suporte Direto</h3>
                <p className="text-sm text-muted-foreground">Com a instrutora</p>
              </Card>
              
              <Card className="text-center p-6 hover:shadow-lg transition-all border-2 hover:border-syntropy-600/20">
                <div className="w-12 h-12 bg-orange-100 rounded-full flex items-center justify-center mx-auto mb-4">
                  <Award className="h-6 w-6 text-orange-600" />
                </div>
                <h3 className="font-semibold mb-2">Certificado</h3>
                <p className="text-sm text-muted-foreground">Reconhecido no mercado</p>
              </Card>
            </div>
          </div>

          {/* What You'll Learn */}
          <Card className="border-2 mb-8">
            <CardHeader>
              <CardTitle className="text-2xl flex items-center gap-2">
                <Code2 className="h-6 w-6 text-syntropy-600" />
                O que você vai conseguir fazer
              </CardTitle>
              <CardDescription>Habilidades práticas que você desenvolverá</CardDescription>
            </CardHeader>
            <CardContent>
              <div className="grid md:grid-cols-2 gap-4">
                {course.outcomes?.map((outcome, index) => (
                  <div key={index} className="flex items-start gap-3">
                    <CheckCircle className="h-5 w-5 text-green-600 mt-0.5 flex-shrink-0" />
                    <div>
                      <h4 className="font-medium">{outcome.title}</h4>
                      <p className="text-sm text-muted-foreground">{outcome.description}</p>
                    </div>
                  </div>
                ))}
              </div>
            </CardContent>
          </Card>

          {/* Course Content */}
          <Card className="border-2" id="course-content">
            <CardHeader>
              <CardTitle className="text-2xl">Conteúdo do Curso</CardTitle>
              <CardDescription>
                {course.chapters.length} capítulos • {course.duration} horas de conteúdo prático
              </CardDescription>
            </CardHeader>
            <CardContent>
              <div className="space-y-3">
                {course.chapters.map((chapter, index) => (
                  <div key={chapter.id} className="group border rounded-lg overflow-hidden hover:shadow-md transition-all">
                    {/* Chapter Details Toggle */}
                    <details className="group/details">
                      <summary className="list-none">
                        {/* Main Chapter Content - Clickable Link */}
                        <div className="relative group/chapter">
                          <Link href={`/learn/courses/${course.slug}/${chapter.slug}`} className="block p-4 hover:bg-muted/50 transition-colors">
                            <div className="flex items-center gap-4">
                              <div className="w-10 h-10 bg-gradient-to-br from-syntropy-600 to-syntropy-700 rounded-full flex items-center justify-center text-white font-semibold">
                                {index + 1}
                              </div>
                              <div className="flex-1">
                                <h3 className="font-semibold text-lg group-hover:text-syntropy-600 transition-colors">
                                  {chapter.title}
                                </h3>
                                {chapter.description && (
                                  <p className="text-muted-foreground mt-1">
                                    {chapter.description}
                                  </p>
                                )}
                                <div className="flex items-center gap-4 mt-2">
                                  {chapter.duration && (
                                    <span className="text-sm text-muted-foreground flex items-center gap-1">
                                      <Clock className="h-3 w-3" />
                                      {chapter.duration} min
                                    </span>
                                  )}
                                  {chapter.project && (
                                    <span className="text-sm text-green-600 font-medium">
                                      ✓ Projeto prático incluído
                                    </span>
                                  )}

                                </div>
                              </div>
                            </div>
                          </Link>
                          
                          {/* Hover Overlay with CTA Button */}
                          <div className="absolute inset-0 bg-black/70 opacity-0 group-hover/chapter:opacity-100 transition-all duration-300 flex items-center justify-center backdrop-blur-sm">
                            <Button 
                              asChild 
                              size="lg" 
                              className="bg-syntropy-600 hover:bg-syntropy-700 text-white shadow-xl transform scale-95 group-hover/chapter:scale-100 transition-all duration-300"
                            >
                              <Link href={`/learn/courses/${course.slug}/${chapter.slug}`}>
                                <Play className="mr-2 h-5 w-5" />
                                Iniciar Capítulo
                              </Link>
                            </Button>
                          </div>
                        </div>
                        
                        {/* Expandable Bottom Bar */}
                        <div className="h-8 bg-gradient-to-r from-syntropy-600/20 to-syntropy-600/60 group-hover:from-syntropy-600/40 group-hover:to-syntropy-600/80 transition-all cursor-pointer flex items-center justify-center relative">
                          <span className="text-xs text-white font-medium opacity-90 group-hover:opacity-100 transition-opacity">
                            Ver tópicos e conteúdo detalhado
                          </span>
                          <div className="absolute inset-0 bg-gradient-to-r from-transparent via-white/5 to-transparent animate-pulse" />
                        </div>
                      </summary>
                      
                      {/* Expandable Section Details */}
                      <div className="border-t bg-muted/30 p-4">
                        <h4 className="font-medium text-sm mb-3 text-muted-foreground uppercase tracking-wide">
                          Seções do Capítulo
                        </h4>
                        <div className="space-y-2">
                          {chapter.sections?.map((section, sectionIndex) => (
                            <div key={sectionIndex} className="flex items-center justify-between py-2 px-3 bg-background rounded-md">
                              <div className="flex items-center gap-3">
                                <div className="w-2 h-2 rounded-full bg-blue-500" />
                                <span className="text-sm">{section}</span>
                              </div>
                            </div>
                          ))}
                          {chapter.project && (
                            <div className="mt-3 p-3 bg-green-50 border border-green-200 rounded-md">
                              <div className="flex items-start gap-3">
                                <div className="w-2 h-2 rounded-full bg-green-500 mt-2" />
                                <div>
                                  <span className="text-sm font-medium text-green-800">Projeto Prático:</span>
                                  <p className="text-sm text-green-700 mt-1">{chapter.project}</p>
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
                <Link href={`/learn/courses/${course.slug}/${course.chapters[0]?.slug}`}>
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