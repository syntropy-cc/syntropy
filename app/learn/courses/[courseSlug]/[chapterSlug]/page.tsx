import type React from "react"
import fs from "fs/promises"
import path from "path"
import matter from "gray-matter"
import { notFound } from "next/navigation"
import { MDXRemote } from "next-mdx-remote/rsc"
import remarkGfm from "remark-gfm"
import rehypeHighlight from "rehype-highlight"
import { getCourseSummary } from "@/lib/courses"
import { CourseIDE } from "@/components/syntropy/CourseIDE"
import { Button } from "@/components/ui/button"
import { Badge } from "@/components/ui/badge"
import { ChevronLeft, ChevronRight, CheckCircle, Menu, X } from "lucide-react"
import Link from "next/link"
import { useState } from "react"

const components = {
  h1: (props: any) => <h1 className="text-3xl font-bold mb-6" {...props} />,
  h2: (props: any) => <h2 className="text-2xl font-semibold mb-4 mt-8" {...props} />,
  h3: (props: any) => <h3 className="text-xl font-medium mb-3 mt-6" {...props} />,
  p: (props: any) => <p className="mb-4 leading-relaxed" {...props} />,
  ul: (props: any) => <ul className="mb-4 ml-6 list-disc" {...props} />,
  ol: (props: any) => <ol className="mb-4 ml-6 list-decimal" {...props} />,
  li: (props: any) => <li className="mb-2" {...props} />,
  code: (props: any) => <code className="bg-muted px-2 py-1 rounded text-sm" {...props} />,
  pre: (props: any) => <pre className="bg-muted p-4 rounded-lg overflow-x-auto mb-4" {...props} />,
  blockquote: (props: any) => <blockquote className="border-l-4 border-primary pl-4 italic my-4" {...props} />,
  Alert: ({ children, type = "info" }: { children: React.ReactNode; type?: "info" | "warning" | "error" }) => (
    <div
      className={`p-4 rounded-lg mb-4 ${
        type === "info"
          ? "bg-blue-50 border border-blue-200 text-blue-800"
          : type === "warning"
            ? "bg-yellow-50 border border-yellow-200 text-yellow-800"
            : "bg-red-50 border border-red-200 text-red-800"
      }`}
    >
      {children}
    </div>
  ),
  CodeBlock: ({ children, language = "javascript" }: { children: string; language?: string }) => (
    <CourseIDE initialCode={children} language={language} className="mb-6" />
  ),
}

async function getChapterContent(courseSlug: string, chapterSlug: string) {
  const filePath = path.join(process.cwd(), "content/courses", courseSlug, `${chapterSlug}.md`)
  try {
    const file = await fs.readFile(filePath, "utf8")
    const { content } = matter(file)
    return content
  } catch (e) {
    return null
  }
}

export default async function ChapterPage({
  params,
}: {
  params: { courseSlug: string; chapterSlug: string }
}) {
  const course = await getCourseSummary(params.courseSlug)
  const currentChapterIndex = course.chapters.findIndex((ch) => ch.slug === params.chapterSlug)
  if (currentChapterIndex === -1) notFound()
  const currentChapter = course.chapters[currentChapterIndex]
  const prevChapter = currentChapterIndex > 0 ? course.chapters[currentChapterIndex - 1] : null
  const nextChapter = currentChapterIndex < course.chapters.length - 1 ? course.chapters[currentChapterIndex + 1] : null

  const chapterContent = await getChapterContent(params.courseSlug, params.chapterSlug)
  if (!chapterContent) notFound()

  // Progresso (exemplo simples)
  const progress = ((currentChapterIndex + 1) / course.chapters.length) * 100

  return (
    <div className="flex flex-col h-screen">
      {/* Topbar */}
      <div className="flex items-center justify-between px-8 py-4 border-b bg-background z-10">
        <div className="flex items-center gap-4">
          <Menu className="md:hidden" />
          <span className="font-bold text-lg">{course.title}</span>
        </div>
        <div className="flex-1 mx-8">
          <div className="h-2 bg-muted rounded-full overflow-hidden">
            <div className="bg-primary h-2 rounded-full" style={{ width: `${progress}%` }} />
          </div>
          <div className="text-xs text-muted-foreground mt-1">Nível 3 • {Math.round(progress)}% concluído • 750/1000 XP</div>
        </div>
        <div className="flex items-center gap-4">
          <span className="text-sm">Próximo nível</span>
          <div className="w-24 h-2 bg-muted rounded-full overflow-hidden">
            <div className="bg-yellow-400 h-2 rounded-full" style={{ width: `25%` }} />
          </div>
          <span className="text-xs text-muted-foreground">250 XP</span>
        </div>
      </div>
      <div className="flex flex-1 overflow-hidden">
        {/* Sidebar */}
        <aside className="hidden md:flex flex-col w-72 border-r bg-background p-6 overflow-y-auto">
          <div className="font-semibold text-lg mb-4">Capítulos</div>
          <nav className="flex flex-col gap-2">
            {course.chapters.map((ch, idx) => (
              <Link
                key={ch.slug}
                href={`/learn/courses/${course.slug}/${ch.slug}`}
                className={`flex items-center gap-2 px-3 py-2 rounded transition-colors ${
                  ch.slug === params.chapterSlug
                    ? "bg-primary/10 text-primary font-bold"
                    : "hover:bg-muted"
                }`}
              >
                <span className="w-6 h-6 flex items-center justify-center rounded-full border text-xs font-bold">
                  {idx + 1}
                </span>
                <span>{ch.title}</span>
                {ch.completed && <CheckCircle className="ml-auto w-4 h-4 text-green-500" />}
              </Link>
            ))}
          </nav>
        </aside>
        {/* Conteúdo principal + IDE */}
        <main className="flex-1 flex overflow-hidden">
          {/* Conteúdo do capítulo */}
          <section className="flex-1 p-8 overflow-auto">
            <div className="max-w-4xl mx-auto">
              <div className="mb-8">
                <div className="flex items-center gap-2 mb-4">
                  <Badge variant="outline">
                    Capítulo {currentChapterIndex + 1} de {course.chapters.length}
                  </Badge>
                  {currentChapter.duration && (
                    <span className="text-sm text-muted-foreground">{currentChapter.duration} min</span>
                  )}
                </div>
                <h1 className="text-3xl font-bold mb-2">{currentChapter.title}</h1>
                {currentChapter.description && (
                  <p className="text-lg text-muted-foreground">{currentChapter.description}</p>
                )}
              </div>
              <div className="prose prose-slate dark:prose-invert max-w-none mb-12">
                <MDXRemote
                  source={chapterContent}
                  components={components}
                  options={{
                    mdxOptions: {
                      remarkPlugins: [remarkGfm],
                      rehypePlugins: [rehypeHighlight],
                    },
                  }}
                />
              </div>
              {/* Navegação entre capítulos */}
              <div className="border-t pt-8">
                <div className="flex justify-between items-center">
                  <div>
                    {prevChapter && (
                      <Button asChild variant="outline">
                        <Link href={`/learn/courses/${course.slug}/${prevChapter.slug}`}>
                          <ChevronLeft className="mr-2 h-4 w-4" />
                          Anterior: {prevChapter.title}
                        </Link>
                      </Button>
                    )}
                  </div>
                  <div className="flex items-center gap-4">
                    <Button variant="outline">
                      <CheckCircle className="mr-2 h-4 w-4" />
                      Marcar como concluído
                    </Button>
                    {nextChapter && (
                      <Button asChild>
                        <Link href={`/learn/courses/${course.slug}/${nextChapter.slug}`}>
                          Próximo: {nextChapter.title}
                          <ChevronRight className="ml-2 h-4 w-4" />
                        </Link>
                      </Button>
                    )}
                  </div>
                </div>
              </div>
            </div>
          </section>
          {/* IDE expansível */}
          <aside className="w-96 border-l bg-background flex flex-col">
            <CourseIDE
              initialCode={`// Capítulo ${currentChapterIndex + 1}: ${currentChapter.title}\n// Pratique aqui\n\nconsole.log("Bem-vindo ao capítulo!");`}
              language="javascript"
            />
          </aside>
        </main>
      </div>
    </div>
  )
}
