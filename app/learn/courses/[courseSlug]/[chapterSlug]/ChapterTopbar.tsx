import Link from "next/link"
import { Button } from "@/components/ui/button"
import { ChevronLeft, Menu } from "lucide-react"

export function ChapterTopbar({ course, progressPct }: { course: any; progressPct: number }) {
  return (
    <header className="flex items-center justify-between px-8 py-4 border-b bg-background">
      <div className="flex items-center gap-4">
        <Menu className="md:hidden" />
        <Link href={`/learn/courses/${course.slug}`}>
          <Button variant="ghost" size="icon">
            <ChevronLeft className="h-4 w-4" />
          </Button>
        </Link>
        <span className="font-bold text-lg">{course.title}</span>
      </div>
      <div className="flex-1 mx-8">
        <div className="h-2 bg-muted rounded-full overflow-hidden">
          <div className="bg-primary h-2" style={{ width: `${progressPct}%` }} />
        </div>
        <div className="text-xs text-muted-foreground mt-1">
          {Math.round(progressPct)} % concluído
        </div>
      </div>
    </header>
  )
} 