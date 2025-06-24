import type React from "react"
import { CourseSidebar } from "@/components/syntropy/CourseSidebar"
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
      <div className="flex h-[calc(100vh-4rem)]">
        <CourseSidebar course={course} />
        <div className="flex-1 overflow-auto">{children}</div>
      </div>
    )
  } catch (error) {
    notFound()
  }
}
