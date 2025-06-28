// app/lib/courses.ts
import type { CourseSummary, CourseProgress } from "@/types/course"
import { unstable_cache } from "next/cache"
import { createServerSupabaseClient } from "./supabase-server"
import fs from "fs/promises"
import path from "path"

/* ------------------------------------------------------------------ */
/* Helpers                                                             */
/* ------------------------------------------------------------------ */

/** Caminho absoluto para a pasta de cursos. */
const COURSES_DIR = path.join(process.cwd(), "content", "courses")

/** Lê o diretório content/courses e devolve uma lista de *slugs* (nome das sub-pastas) */
async function discoverCourseSlugs(): Promise<string[]> {
  const dirents = await fs.readdir(COURSES_DIR, { withFileTypes: true })
  return dirents.filter((d) => d.isDirectory()).map((d) => d.name)
}

/* ------------------------------------------------------------------ */
/* API pública                                                         */
/* ------------------------------------------------------------------ */

/**
 * Carrega o módulo `index.ts` de um curso.  
 * Esse arquivo deve fazer import estático da capa (`course-cover.png`)
 * de modo que o Next gere a URL otimizada automaticamente.
 */
export const getCourseSummary = unstable_cache(
  async (courseSlug: string): Promise<CourseSummary> => {
    try {
      const courseModule = await import(
        /* webpackInclude: /index\.ts$/ */
        /* webpackMode: "lazy" */
        `@/content/courses/${courseSlug}/index.ts`
      )
      // o módulo padrão exporta o objeto que satisfaz CourseSummary
      return courseModule.default as CourseSummary
    } catch {
      throw new Error(`Course not found or invalid: ${courseSlug}`)
    }
  },
  ["course-summary"],
  { revalidate: 3600 },
)

/**
 * Descobre automaticamente todos os cursos lendo o disco
 * e carregando seu respectivo `index.ts`.
 */
export const getAllCourses = unstable_cache(
  async (): Promise<CourseSummary[]> => {
    const slugs = await discoverCourseSlugs()

    const summaries = await Promise.all(
      slugs.map(async (slug) => {
        try {
          return await getCourseSummary(slug)
        } catch {
          // ignora cursos com arquivo ausente ou inválido
          return null
        }
      }),
    )

    return summaries.filter(Boolean) as CourseSummary[]
  },
  ["all-courses"],
  { revalidate: 3600 },
)

/* ------------------------------------------------------------------ */
/* MDX capítulo                                                        */
/* ------------------------------------------------------------------ */

export const getChapterMdx = async (courseSlug: string, chapterSlug: string) => {
  try {
    const chapterModule = await import(
      /* webpackInclude: /\.mdx$/ */
      `@/content/courses/${courseSlug}/${chapterSlug}.mdx`
    )
    return chapterModule
  } catch {
    throw new Error(`Chapter not found: ${courseSlug}/${chapterSlug}`)
  }
}

/* ------------------------------------------------------------------ */
/* Progresso do usuário (Supabase)                                     */
/* ------------------------------------------------------------------ */

import { createClient } from "./supabase" // (mantido, caso use em outro lugar)

export const getCourseProgress = async (
  courseId: string,
  userId: string,
): Promise<CourseProgress | null> => {
  const supabase = await createServerSupabaseClient()

  const { data, error } = await supabase
    .from("course_progress")
    .select("*")
    .eq("course_id", courseId)
    .eq("user_id", userId)
    .single()

  if (error && error.code !== "PGRST116") throw error
  return data
}

export const updateCourseProgress = async (
  courseId: string,
  userId: string,
  chapterId: string,
): Promise<void> => {
  const supabase = await createServerSupabaseClient()

  const { error } = await supabase.from("course_progress").upsert({
    course_id: courseId,
    user_id: userId,
    current_chapter: chapterId,
    last_accessed_at: new Date().toISOString(),
  })

  if (error) throw error
}
