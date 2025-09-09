/* app/learn/courses/page.tsx - Versão simplificada */

import Image from "next/image"
import { Card } from "@/components/ui/card"
import { Badge } from "@/components/ui/badge"
import Link from "next/link"
import { getAllCourses } from "@/lib/courses"

export default async function CoursesPage() {
  const courses = await getAllCourses()

  return (
    <div className="min-h-screen bg-gradient-to-br from-slate-900 via-blue-900/20 to-slate-900 text-white pb-16">
      <div className="container pt-16">
        {courses.length === 0 ? (
          <div className="text-center py-16">
            <div className="text-6xl mb-4">📚</div>
            <h2 className="text-2xl font-bold mb-2">Nenhum curso encontrado</h2>
            <p className="text-slate-400">
              Verifique se os cursos estão no diretório /public/courses/
            </p>
          </div>
        ) : (
          <div className="grid grid-cols-[repeat(auto-fill,minmax(280px,1fr))] gap-6 md:gap-8">
            {courses.map((course, i) => {
              // Ajustar número de tags visíveis baseado no tamanho dos nomes
              const MAX_VISIBLE_TAGS = 6 // Aumentado para aproveitar melhor o espaço
              const allTags = course.tags ?? []
              
              // Função para estimar se as tags cabem na linha
              const getVisibleTags = () => {
                for (let count = MAX_VISIBLE_TAGS; count > 0; count--) {
                  const tags = allTags.slice(0, count)
                  const totalLength = tags.join('').length + (count * 3) // +3 para espaçamento e padding
                  if (totalLength <= 35) return { tags, count } // Aumentado limite para mais tags
                }
                return { tags: allTags.slice(0, 3), count: 3 } // Fallback mínimo aumentado
              }
              
              const { tags: visibleTags, count: visibleCount } = getVisibleTags()
              const hiddenCount = allTags.length - visibleCount

              return (
                <Link
                  key={course.slug}
                  href={`/learn/courses/${course.slug}`}
                  className="group focus:outline-none"
                  aria-label={`Acessar curso ${course.title}`}
                >
                  <Card className="relative flex flex-col overflow-hidden rounded-2xl bg-slate-800/80 shadow-md transition-shadow hover:shadow-lg h-[520px] w-full">
                    {/* ----------- CAPA 4:5 ----------- */}
                    <figure className="relative aspect-[4/5] w-full overflow-hidden">
                      {course.cover ? (
                        <Image
                          src={course.cover}
                          alt={`Capa do curso ${course.title}`}
                          width={320}
                          height={400}
                          sizes="(max-width:640px) 60vw,
                                 (max-width:1024px) 30vw,
                                 (max-width:1280px) 23vw,
                                 320px"
                          priority={i < 4}
                          className="absolute inset-0 h-full w-full object-cover transition-transform duration-300 group-hover:scale-105"
                        />
                      ) : (
                        <div className="absolute inset-0 flex items-center justify-center bg-gradient-to-br from-slate-700 to-slate-800">
                          <div className="text-center">
                            <div className="text-4xl mb-2">📚</div>
                            <div className="text-xs text-slate-400">Sem capa</div>
                          </div>
                        </div>
                      )}

                      {/* ----------- OVERLAY COM RESUMO DO CURSO ----------- */}
                      <div className="absolute inset-0 bg-black/90 opacity-0 transition-opacity duration-300 group-hover:opacity-100 flex flex-col justify-between p-4">
                        <div className="text-left">
                          <h3 className="font-bold text-lg text-white mb-3 line-clamp-2">
                            {course.title}
                          </h3>
                          <p className="text-sm text-blue-100/90 line-clamp-6 leading-relaxed">
                            {course.description || 'Sem descrição disponível'}
                          </p>
                        </div>
                        
                        {/* Botão Ver Curso */}
                        <div className="flex justify-center">
                          <span className="rounded-full bg-indigo-600 py-2 px-4 text-sm font-medium shadow-lg">
                            Ver curso
                          </span>
                        </div>
                      </div>
                    </figure>

                    {/* ----------- INFORMAÇÕES BÁSICAS ----------- */}
                    <div className="flex flex-col gap-3 p-4 flex-1">
                      {/* Primeira linha: nível • capítulos • horas */}
                      <div className="flex items-center gap-3">
                        <Badge
                          className={`px-3 py-1 shrink-0 rounded-full font-medium text-xs ${
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

                        <div className="flex items-center gap-1 text-white text-sm">
                          <span className="text-blue-200/70">📚</span>
                          <span className="font-medium">{course.chapterCount || course.chapters?.length || 0} capítulos</span>
                        </div>

                        {course.duration && (
                          <div className="flex items-center gap-1 text-white text-sm">
                            <span className="text-blue-200/70">⏱️</span>
                            <span className="font-medium">{course.duration}h</span>
                          </div>
                        )}
                      </div>

                      {/* Segunda linha: tags */}
                      <div className="flex items-center gap-1.5 overflow-hidden">
                        {visibleTags.map((tag) => (
                          <Badge
                            key={tag}
                            className="shrink-0 border-blue-400/30 bg-slate-700/40 text-xs text-blue-200/80 px-2 py-1 rounded-full whitespace-nowrap"
                          >
                            {tag}
                          </Badge>
                        ))}

                        {hiddenCount > 0 && (
                          <Badge className="shrink-0 border-blue-400/30 bg-slate-700/40 text-xs text-blue-300/80 px-2 py-1 rounded-full whitespace-nowrap">
                            +{hiddenCount}
                          </Badge>
                        )}
                      </div>

                      {/* Terceira linha: autor (canto direito) */}
                      <div className="flex justify-between items-center">
                        {/* Indicação de curso em construção */}
                        {(course as any).finished === "false" && (
                          <div className="flex items-center gap-1">
                            <div className="w-2 h-2 bg-yellow-500 rounded-full animate-pulse"></div>
                            <span className="text-xs text-yellow-400 font-medium">Em construção</span>
                          </div>
                        )}
                        
                        {/* Autor */}
                        <div className="flex items-center gap-2">
                          <div className="flex h-6 w-6 items-center justify-center rounded-full bg-blue-700 text-xs font-bold text-white">
                            {course.author?.name?.charAt(0) || '?'}
                          </div>
                          <span className="text-xs text-blue-100/80 font-medium">
                            {course.author?.name || 'Autor desconhecido'}
                          </span>
                        </div>
                      </div>
                    </div>
                  </Card>
                </Link>
              )
            })}
          </div>
        )}
      </div>
    </div>
  )
}