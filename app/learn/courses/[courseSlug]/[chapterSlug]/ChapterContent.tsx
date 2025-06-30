"use client";                // ① indica que este arquivo roda no browser

import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import Link from "next/link";
import { ChevronLeft, ChevronRight } from "lucide-react";
import { MystRenderer } from "@/lib/myst/main";

interface Props {
  chapter: any;
  idx: number;
  course: any;
  prevChapter: any | null;
  nextChapter: any | null;
  mdSource: string;
  chapterCount: number;
}

export default function ChapterContent({
  chapter,
  idx,
  course,
  prevChapter,
  nextChapter,
  mdSource,
  chapterCount,
}: Props) {
  return (
    <section className="flex-1 p-8 overflow-y-auto">
      {/* cabeçalho */}
      <div className="mb-8">
        <div className="flex items-center gap-2 mb-4">
          <Badge variant="outline">
            Capítulo {idx + 1} / {chapterCount}
          </Badge>
          {chapter.duration && (
            <span className="text-sm text-muted-foreground">
              {chapter.duration} min
            </span>
          )}
        </div>
        
      </div>

      {/* conteúdo MyST - AGORA COM courseSlug */}
      <MystRenderer 
        content={mdSource} 
        courseSlug={course.slug}
      />

      {/* navegação */}
      <div className="border-t pt-8 flex justify-between">
        {prevChapter ? (
          <Button asChild variant="outline">
            <Link href={`/learn/courses/${course.slug}/${prevChapter.slug}`}>
              <ChevronLeft className="mr-2 h-4 w-4" />
              {prevChapter.title}
            </Link>
          </Button>
        ) : (
          <span />
        )}

        {nextChapter && (
          <Button asChild>
            <Link href={`/learn/courses/${course.slug}/${nextChapter.slug}`}>
              {nextChapter.title}
              <ChevronRight className="ml-2 h-4 w-4" />
            </Link>
          </Button>
        )}
      </div>
    </section>
  );
}