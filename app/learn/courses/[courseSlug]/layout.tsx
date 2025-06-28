import type React from "react"
import { getCourseSummary } from "@/lib/courses"
import { notFound } from "next/navigation"

export default async function CourseLayout({
  children,
  params,
}: {
  children: React.ReactNode
  params: { courseSlug: string }
}) {
  try {
    const course = await getCourseSummary(params.courseSlug)

    return (
      <div className="h-[calc(100vh-4rem)]">
        <div className="h-full overflow-auto">{children}</div>
      </div>
    )
  } catch (error) {
    notFound()
  }
}