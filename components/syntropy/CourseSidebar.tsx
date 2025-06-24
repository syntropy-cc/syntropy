"use client"

import { useState } from "react"
import Link from "next/link"
import { usePathname } from "next/navigation"
import type { CourseSummary } from "@/types/course"
import { Button } from "@/components/ui/button"
import { Progress } from "@/components/ui/progress"
import { Badge } from "@/components/ui/badge"
import { Collapsible, CollapsibleContent, CollapsibleTrigger } from "@/components/ui/collapsible"
import { ChevronDown, ChevronRight, CheckCircle, Circle, Lock } from "lucide-react"
import { cn } from "@/lib/utils"

interface CourseSidebarProps {
  course: CourseSummary
  progress?: number
  completedChapters?: string[]
}

export function CourseSidebar({ course, progress = 0, completedChapters = [] }: CourseSidebarProps) {
  const [isOpen, setIsOpen] = useState(true)
  const pathname = usePathname()

  return (
    <div className="w-80 border-r bg-muted/30 p-6">
      <div className="space-y-6">
        {/* Course Header */}
        <div>
          <h2 className="font-bold text-lg line-clamp-2">{course.title}</h2>
          <p className="text-sm text-muted-foreground mt-1">by {course.author.name}</p>
          <div className="flex items-center gap-2 mt-2">
            <Badge variant="secondary">{course.level}</Badge>
            <span className="text-sm text-muted-foreground">{course.duration}h total</span>
          </div>
        </div>

        {/* Progress */}
        <div className="space-y-2">
          <div className="flex justify-between text-sm">
            <span>Progress</span>
            <span>{Math.round(progress)}%</span>
          </div>
          <Progress value={progress} className="h-2" />
          <p className="text-xs text-muted-foreground">
            {completedChapters.length} of {course.chapters.length} chapters completed
          </p>
        </div>

        {/* Chapters */}
        <Collapsible open={isOpen} onOpenChange={setIsOpen}>
          <CollapsibleTrigger asChild>
            <Button variant="ghost" className="w-full justify-between p-0 h-auto">
              <span className="font-medium">Course Content</span>
              {isOpen ? <ChevronDown className="h-4 w-4" /> : <ChevronRight className="h-4 w-4" />}
            </Button>
          </CollapsibleTrigger>
          <CollapsibleContent className="space-y-1 mt-4">
            {course.chapters.map((chapter, index) => {
              const isCompleted = completedChapters.includes(chapter.id)
              const isLocked =
                chapter.locked &&
                !isCompleted &&
                index > 0 &&
                !completedChapters.includes(course.chapters[index - 1].id)
              const isCurrent = pathname.includes(chapter.slug)

              return (
                <Link
                  key={chapter.id}
                  href={`/learn/courses/${course.slug}/${chapter.slug}`}
                  className={cn(
                    "flex items-center gap-3 p-3 rounded-lg text-sm transition-colors",
                    isCurrent ? "bg-primary text-primary-foreground" : "hover:bg-muted",
                    isLocked && "opacity-50 cursor-not-allowed",
                  )}
                  onClick={(e) => {
                    if (isLocked) {
                      e.preventDefault()
                    }
                  }}
                >
                  <div className="flex-shrink-0">
                    {isLocked ? (
                      <Lock className="h-4 w-4" />
                    ) : isCompleted ? (
                      <CheckCircle className="h-4 w-4 text-green-500" />
                    ) : (
                      <Circle className="h-4 w-4" />
                    )}
                  </div>
                  <div className="flex-1 min-w-0">
                    <p className="font-medium line-clamp-1">{chapter.title}</p>
                    {chapter.duration && <p className="text-xs text-muted-foreground">{chapter.duration} min</p>}
                  </div>
                </Link>
              )
            })}
          </CollapsibleContent>
        </Collapsible>
      </div>
    </div>
  )
}
