import { Button } from "@/components/ui/button"
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card"
import { Badge } from "@/components/ui/badge"
import { Input } from "@/components/ui/input"
import { Search, Plus } from "lucide-react"
import Link from "next/link"
import { getAllCourses } from "@/lib/courses"

export default async function CoursesPage() {
  const courses = await getAllCourses()

  // Filtros simulados (em produção, viriam de um backend ou contexto)
  const categorias = [
    "Data Science",
    "Inteligência Artificial",
    "Machine Learning",
  ]
  const niveis = ["Todos", "Iniciante", "Intermediário", "Avançado"]

  return (
    <div className="min-h-screen bg-gradient-to-br from-slate-900 via-blue-900/20 to-slate-900 text-white pb-16">
      <div className="container pt-10">
        {/* Barra de busca e filtros principais */}
        <div className="flex flex-col md:flex-row md:items-center md:justify-between gap-6 mb-8">
          <div className="flex-1">
            <div className="relative">
              <Search className="absolute left-4 top-1/2 -translate-y-1/2 h-5 w-5 text-blue-300" />
              <Input
                placeholder="Buscar cursos e trilhas..."
                className="bg-slate-800/80 border-none pl-12 text-white placeholder:text-blue-200/60 h-12 text-lg shadow focus:ring-2 focus:ring-blue-500"
              />
            </div>
          </div>
          <Button asChild className="h-12 px-6 text-base font-semibold bg-blue-600 hover:bg-blue-700">
            <Link href="#">
              <Plus className="mr-2 h-5 w-5" />
              Novo Curso
            </Link>
          </Button>
        </div>

        {/* Filtros de tipo e categoria */}
        <div className="flex flex-wrap items-center gap-3 mb-6">
          <span className="text-blue-200/80 font-medium mr-2">Filtros:</span>
          <Button variant="secondary" className="px-5 py-1.5 rounded-full text-base font-semibold bg-blue-700/80 text-white">Cursos</Button>
          <Button variant="ghost" className="px-5 py-1.5 rounded-full text-base font-semibold text-white/80">Trilhas</Button>
          <Button variant="secondary" className="px-5 py-1.5 rounded-full text-base font-semibold bg-blue-700/80 text-white">Todos</Button>
          {categorias.map((cat) => (
            <Button key={cat} variant="ghost" className="px-5 py-1.5 rounded-full text-base font-semibold text-white/80">
              {cat}
            </Button>
          ))}
        </div>

        {/* Filtros de nível */}
        <div className="flex flex-wrap gap-3 mb-8">
          {niveis.map((nivel, i) => (
            <Button
              key={nivel}
              variant={i === 0 ? "secondary" : "ghost"}
              className={`px-4 py-1.5 rounded-full text-sm font-medium ${i === 0 ? "bg-blue-600 text-white" : "text-white/80"}`}
            >
              {nivel}
            </Button>
          ))}
        </div>

        {/* Título e contagem */}
        <div className="flex flex-col md:flex-row md:items-end md:justify-between mb-6 gap-2">
          <div>
            <h1 className="text-4xl font-bold mb-1 text-white">Cursos Disponíveis</h1>
            <p className="text-blue-200/80 text-lg">{courses.length} cursos encontrados</p>
          </div>
        </div>

        {/* Grid de cursos */}
        <div className="grid md:grid-cols-2 lg:grid-cols-3 gap-8">
          {courses.map((course) => (
            <Card key={course.id} className="bg-slate-800/80 border-none shadow-lg hover:shadow-xl transition-shadow relative">
              <CardHeader className="pb-3">
                <div className="flex justify-between items-start mb-2">
                  <Badge
                    variant="secondary"
                    className={`px-3 py-1 rounded-full text-sm font-semibold ${
                      course.level === "beginner"
                        ? "bg-green-700/80 text-green-200"
                        : course.level === "intermediate"
                        ? "bg-yellow-700/80 text-yellow-200"
                        : "bg-red-800/80 text-red-200"
                    }`}
                  >
                    {course.level === "beginner"
                      ? "Iniciante"
                      : course.level === "intermediate"
                      ? "Intermediário"
                      : "Avançado"}
                  </Badge>
                  <span className="text-base text-blue-200/80 font-medium flex items-center gap-1">
                    <svg className="w-4 h-4 mr-1 text-yellow-400" fill="currentColor" viewBox="0 0 20 20"><path d="M9.049 2.927c.3-.921 1.603-.921 1.902 0l1.286 3.967a1 1 0 00.95.69h4.178c.969 0 1.371 1.24.588 1.81l-3.385 2.46a1 1 0 00-.364 1.118l1.287 3.966c.3.922-.755 1.688-1.54 1.118l-3.385-2.46a1 1 0 00-1.175 0l-3.385 2.46c-.784.57-1.838-.196-1.54-1.118l1.287-3.966a1 1 0 00-.364-1.118L2.045 9.394c-.783-.57-.38-1.81.588-1.81h4.178a1 1 0 00.95-.69l1.286-3.967z"/></svg>
                    4.8
                  </span>
                </div>
                <CardTitle className="line-clamp-2 text-white text-2xl font-bold mb-1">{course.title}</CardTitle>
                <CardDescription className="line-clamp-3 text-blue-100/90 text-base mb-2">{course.description}</CardDescription>
              </CardHeader>
              <CardContent className="pt-0">
                <div className="flex flex-wrap gap-2 mb-3">
                  {course.tags.slice(0, 3).map((tag) => (
                    <Badge key={tag} variant="outline" className="text-xs border-blue-400/40 text-blue-200/90">
                      {tag}
                    </Badge>
                  ))}
                  {course.tags.length > 3 && (
                    <Badge variant="outline" className="text-xs border-blue-400/40 text-blue-200/90">
                      +{course.tags.length - 3}
                    </Badge>
                  )}
                </div>
                <div className="flex items-center justify-between text-blue-200/80 text-sm mb-2">
                  <span>⏱ {course.duration} semanas</span>
                  <span>📖 {course.chapters.length} capítulos</span>
                  <span>👥 {Math.floor(Math.random() * 2000) + 100} alunos</span>
                </div>
                <div className="flex items-center gap-2 mt-2">
                  <div className="w-8 h-8 rounded-full bg-blue-700 flex items-center justify-center text-white font-bold text-lg">
                    {course.author.name.charAt(0)}
                  </div>
                  <span className="text-blue-100/90 text-base font-medium">por {course.author.name}</span>
                </div>
                <Button asChild size="sm" className="mt-4 w-full bg-blue-600 hover:bg-blue-700 text-white font-semibold">
                  <Link href={`/learn/courses/${course.slug}`}>Acessar Curso</Link>
                </Button>
              </CardContent>
              {/* Selo de destaque */}
              {course.level === "advanced" && (
                <div className="absolute top-4 right-4 bg-blue-900/80 rounded-full p-2">
                  <svg className="w-5 h-5 text-blue-300" fill="none" stroke="currentColor" strokeWidth="2" viewBox="0 0 24 24"><path strokeLinecap="round" strokeLinejoin="round" d="M12 17.75l-6.172 3.245 1.179-6.873-5-4.873 6.9-1.002L12 2.25l3.093 6.997 6.9 1.002-5 4.873 1.179 6.873z"/></svg>
                </div>
              )}
            </Card>
          ))}
        </div>
      </div>
    </div>
  )
}
