/* app/learn/courses/page.tsx */

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
        <div className="grid grid-cols-[repeat(auto-fill,minmax(250px,1fr))] gap-6 md:gap-8">
          {courses.map((course, i) => {
            /* ――― cálculo das tags que aparecerão na linha ――― */
            const VISIBLE_TAGS = 2
            const visibleTags = course.tags?.slice(0, VISIBLE_TAGS) ?? []
            const hiddenCount = (course.tags?.length ?? 0) - visibleTags.length

            return (
              <Link
                key={course.id}
                href={`/learn/courses/${course.slug}`}
                className="group focus:outline-none"
                aria-label={`Acessar curso ${course.title}`}
              >
                <Card className="relative flex flex-col overflow-hidden rounded-2xl bg-slate-800/80 shadow-md transition-shadow hover:shadow-lg">
                  {/* ----------- CAPA 3:4 ----------- */}
                  <figure className="relative aspect-[3/4] w-full overflow-hidden">
                    <Image
                      src={course.cover}
                      alt={`Capa do curso ${course.title}`}
                      width={320}
                      height={427}
                      sizes="(max-width:640px) 60vw,
                             (max-width:1024px) 30vw,
                             (max-width:1280px) 23vw,
                             320px"
                      priority={i < 4}
                      className="absolute inset-0 h-full w-full object-cover transition-transform duration-300 group-hover:scale-105"
                    />
                  </figure>

                  {/* ----------- CORPO ----------- */}
                  <div className="flex flex-col gap-3 p-4 grow">
                    {/* Descrição */}
                    <p className="text-sm text-blue-100/80 line-clamp-3">
                      {course.description}
                    </p>

                    {/* --- Linha única: nível • capítulos • tags --- */}
                    <div className="flex items-center gap-2 text-xs text-blue-200/70">
                      {/* Nível */}
                      <Badge
                        variant="secondary"
                        className={`px-2 py-0.5 shrink-0 rounded-full font-medium ${
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

                      {/* Capítulos */}
                      <span className="shrink-0">{course.chapters.length} capítulos</span>

                      {/* Tags visíveis */}
                      {visibleTags.map((tag) => (
                        <Badge
                          key={tag}
                          variant="outline"
                          className="shrink-0 border-blue-400/30 bg-slate-700/40 text-[10px] text-blue-200/80 px-2 py-0.5"
                        >
                          {tag}
                        </Badge>
                      ))}

                      {/* Indicador de tags escondidas */}
                      {hiddenCount > 0 && (
                        <span className="shrink-0 text-blue-300/80">+{hiddenCount}</span>
                      )}
                    </div>

                    {/* Autor */}
                    <div className="mt-auto flex items-center gap-2">
                      <div className="flex h-7 w-7 items-center justify-center rounded-full bg-blue-700 text-base font-bold">
                        {course.author.name.charAt(0)}
                      </div>
                      <span className="text-xs text-blue-100/80">
                        {course.author.name}
                      </span>
                    </div>
                  </div>

                  {/* ----------- OVERLAY ----------- */}
                  <div className="absolute inset-0 flex items-center justify-center bg-black/40 opacity-0 transition-opacity duration-300 group-hover:opacity-100">
                    <span className="rounded-full bg-indigo-600 py-2 px-4 text-sm font-medium shadow">
                      Ver curso
                    </span>
                  </div>
                </Card>
              </Link>
            )
          })}
        </div>
      </div>
    </div>
  )
}
