import type { CourseSummary, CourseProgress } from "@/types/course"
import { unstable_cache } from "next/cache"
import { createServerSupabaseClient } from "./supabase"

export const getCourseSummary = unstable_cache(
  async (courseSlug: string): Promise<CourseSummary> => {
    try {
      const summaryModule = await import(`@/content/courses/${courseSlug}/summary.json`)
      return summaryModule.default
    } catch (error) {
      throw new Error(`Course not found: ${courseSlug}`)
    }
  },
  ["course-summary"],
  { revalidate: 3600 },
)

export const getAllCourses = unstable_cache(
  async (): Promise<CourseSummary[]> => {
    // In a real app, this would fetch from a database or file system
    // For now, we'll return mock data
    const courses = ["javascript-fundamentals", "react-basics", "nextjs-advanced", "typescript-essentials"]

    const courseSummaries = await Promise.all(
      courses.map(async (slug) => {
        try {
          return await getCourseSummary(slug)
        } catch {
          return null
        }
      }),
    )

    return courseSummaries.filter(Boolean) as CourseSummary[]
  },
  ["all-courses"],
  { revalidate: 3600 },
)

export const getChapterMdx = async (courseSlug: string, chapterSlug: string) => {
  try {
    const chapterModule = await import(`@/content/courses/${courseSlug}/${chapterSlug}.mdx`)
    return chapterModule
  } catch (error) {
    throw new Error(`Chapter not found: ${courseSlug}/${chapterSlug}`)
  }
}

export const getCourseProgress = async (courseId: string, userId: string): Promise<CourseProgress | null> => {
  const supabase = await createServerSupabaseClient()

  const { data, error } = await supabase
    .from("course_progress")
    .select("*")
    .eq("course_id", courseId)
    .eq("user_id", userId)
    .single()

  if (error && error.code !== "PGRST116") {
    throw error
  }

  return data
}

export const updateCourseProgress = async (courseId: string, userId: string, chapterId: string): Promise<void> => {
  const supabase = await createServerSupabaseClient()

  const { error } = await supabase.from("course_progress").upsert({
    course_id: courseId,
    user_id: userId,
    current_chapter: chapterId,
    last_accessed_at: new Date().toISOString(),
  })

  if (error) {
    throw error
  }
}
