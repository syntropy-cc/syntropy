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
          <div className="grid grid-cols-[repeat(auto-fill,minmax(250px,1fr))] gap-6 md:gap-8">
            {courses.map((course, i) => {
              const VISIBLE_TAGS = 4 // Aumentado para mostrar mais tags na linha dedicada
              const visibleTags = course.tags?.slice(0, VISIBLE_TAGS) ?? []
              const hiddenCount = (course.tags?.length ?? 0) - visibleTags.length

              return (
                <Link
                  key={course.slug}
                  href={`/learn/courses/${course.slug}`}
                  className="group focus:outline-none"
                  aria-label={`Acessar curso ${course.title}`}
                >
                  <Card className="relative flex flex-col overflow-hidden rounded-2xl bg-slate-800/80 shadow-md transition-shadow hover:shadow-lg">
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
                      <div className="absolute inset-0 bg-black/60 opacity-0 transition-opacity duration-300 group-hover:opacity-100 flex flex-col justify-center p-4">
                        <div className="text-center">
                          <h3 className="font-bold text-lg text-white mb-2 line-clamp-2">
                            {course.title}
                          </h3>
                          <p className="text-sm text-blue-100/90 line-clamp-4">
                            {course.description || 'Sem descrição disponível'}
                          </p>
                        </div>
                      </div>
                    </figure>

                    {/* ----------- INFORMAÇÕES BÁSICAS ----------- */}
                    <div className="flex flex-col gap-3 p-4">
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
                          <span className="font-medium">{course.chapters?.length || 0} capítulos</span>
                        </div>

                        {course.duration && (
                          <div className="flex items-center gap-1 text-white text-sm">
                            <span className="text-blue-200/70">⏱️</span>
                            <span className="font-medium">{Math.round(course.duration / 60)}h</span>
                          </div>
                        )}
                      </div>

                      {/* Segunda linha: tags */}
                      <div className="flex items-center gap-2 flex-wrap">
                        {visibleTags.map((tag) => (
                          <Badge
                            key={tag}
                            className="shrink-0 border-blue-400/30 bg-slate-700/40 text-xs text-blue-200/80 px-2 py-1 rounded-full"
                          >
                            {tag}
                          </Badge>
                        ))}

                        {hiddenCount > 0 && (
                          <span className="text-xs text-blue-300/80 font-medium">+{hiddenCount}</span>
                        )}
                      </div>

                      {/* Terceira linha: autor (canto direito) */}
                      <div className="flex justify-end">
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