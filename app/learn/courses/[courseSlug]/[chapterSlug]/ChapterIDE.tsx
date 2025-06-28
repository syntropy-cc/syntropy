import { CourseIDE } from "@/components/syntropy/CourseIDE"

export function ChapterIDE({ chapterTitle }: { chapterTitle: string }) {
  return (
    <aside className="w-96 border-l">
      <CourseIDE
        initialCode={`// ${chapterTitle}\n// Experimente aqui\n`}
        language="javascript"
      />
    </aside>
  )
} 