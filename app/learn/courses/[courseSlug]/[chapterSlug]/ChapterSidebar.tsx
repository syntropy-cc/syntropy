import Link from "next/link"
import { CheckCircle } from "lucide-react"

export function ChapterSidebar({ course, chapterSlug }: { course: any; chapterSlug: string }) {
  return (
    <aside className="hidden md:flex flex-col w-72 border-r p-6 overflow-y-auto">
      <div className="font-semibold text-lg mb-4">Capítulos</div>
      {course.chapters.map((c: any, i: number) => (
        <Link
          key={c.slug}
          href={`/learn/courses/${course.slug}/${c.slug}`}
          className={`flex items-center gap-2 px-3 py-2 rounded ${
            c.slug === chapterSlug
              ? "bg-primary/10 text-primary font-bold"
              : "hover:bg-muted"
          }`}
        >
          <span className="w-6 h-6 flex items-center justify-center rounded-full border text-xs font-bold">
            {i + 1}
          </span>
          <span>{c.title}</span>
          {c.completed && (
            <CheckCircle className="ml-auto w-4 h-4 text-green-500" />
          )}
        </Link>
      ))}
    </aside>
  )
} 