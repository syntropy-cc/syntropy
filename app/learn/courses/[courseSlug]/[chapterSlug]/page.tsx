import type React from "react"
import { MDXRemote } from "next-mdx-remote/rsc"
import { getCourseSummary } from "@/lib/courses"
import { CourseIDE } from "@/components/syntropy/CourseIDE"
import { Button } from "@/components/ui/button"
import { Badge } from "@/components/ui/badge"
import { ChevronLeft, ChevronRight, CheckCircle } from "lucide-react"
import Link from "next/link"
import { notFound } from "next/navigation"
import remarkGfm from "remark-gfm"
import rehypeHighlight from "rehype-highlight"

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

export default async function ChapterPage({
  params,
}: {
  params: { courseSlug: string; chapterSlug: string }
}) {
  try {
    const course = await getCourseSummary(params.courseSlug)
    const currentChapterIndex = course.chapters.findIndex((ch) => ch.slug === params.chapterSlug)

    if (currentChapterIndex === -1) {
      notFound()
    }

    const currentChapter = course.chapters[currentChapterIndex]
    const prevChapter = currentChapterIndex > 0 ? course.chapters[currentChapterIndex - 1] : null
    const nextChapter =
      currentChapterIndex < course.chapters.length - 1 ? course.chapters[currentChapterIndex + 1] : null

    // In a real implementation, this would load the actual MDX content
    const mockMdxContent = `
# ${currentChapter.title}

Welcome to this chapter! Here you'll learn about the fundamentals of this topic.

## Overview

This chapter covers the essential concepts you need to understand.

<Alert type="info">
This is an informational alert to help guide your learning.
</Alert>

## Code Example

Let's start with a simple example:

<CodeBlock language="javascript">
// This is a sample code block
function greet(name) {
  return \`Hello, \${name}!\`;
}

console.log(greet("Syntropy"));
</CodeBlock>

## Key Points

- Important concept 1
- Important concept 2  
- Important concept 3

## Practice Exercise

Try modifying the code above to:
1. Add error handling
2. Support multiple languages
3. Add input validation

<Alert type="warning">
Remember to test your code thoroughly before moving to the next chapter.
</Alert>

## Summary

In this chapter, you learned about the core concepts and practiced implementing them. 

Ready for the next challenge? Let's continue!
    `

    return (
      <div className="flex h-full">
        {/* Content Area */}
        <div className="flex-1 p-8 overflow-auto">
          <div className="max-w-4xl mx-auto">
            {/* Chapter Header */}
            <div className="mb-8">
              <div className="flex items-center gap-2 mb-4">
                <Badge variant="outline">
                  Chapter {currentChapterIndex + 1} of {course.chapters.length}
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

            {/* MDX Content */}
            <div className="prose prose-slate dark:prose-invert max-w-none mb-12">
              <MDXRemote
                source={mockMdxContent}
                components={components}
                options={{
                  mdxOptions: {
                    remarkPlugins: [remarkGfm],
                    rehypePlugins: [rehypeHighlight],
                  },
                }}
              />
            </div>

            {/* Chapter Navigation */}
            <div className="border-t pt-8">
              <div className="flex justify-between items-center">
                <div>
                  {prevChapter && (
                    <Button asChild variant="outline">
                      <Link href={`/learn/courses/${course.slug}/${prevChapter.slug}`}>
                        <ChevronLeft className="mr-2 h-4 w-4" />
                        Previous: {prevChapter.title}
                      </Link>
                    </Button>
                  )}
                </div>
                <div className="flex items-center gap-4">
                  <Button variant="outline">
                    <CheckCircle className="mr-2 h-4 w-4" />
                    Mark Complete
                  </Button>
                  {nextChapter && (
                    <Button asChild>
                      <Link href={`/learn/courses/${course.slug}/${nextChapter.slug}`}>
                        Next: {nextChapter.title}
                        <ChevronRight className="ml-2 h-4 w-4" />
                      </Link>
                    </Button>
                  )}
                </div>
              </div>
            </div>
          </div>
        </div>

        {/* IDE Sidebar */}
        <div className="w-96 border-l">
          <CourseIDE
            initialCode={`// Chapter ${currentChapterIndex + 1}: ${currentChapter.title}
// Practice what you've learned here

console.log("Welcome to ${currentChapter.title}!");`}
            language="javascript"
          />
        </div>
      </div>
    )
  } catch (error) {
    notFound()
  }
}
