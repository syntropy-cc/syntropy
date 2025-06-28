"use client";                // ① indica que este arquivo roda no browser

import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import Link from "next/link";
import { ChevronLeft, ChevronRight } from "lucide-react";
import { MystRenderer } from "@/lib/myst/main";
import { useEffect, useState } from "react";

import path from "path";
import { readFile } from "fs/promises";
import matter from "gray-matter";

// Adaptar interface para receber courseSlug e chapterSlug
interface Props {
  chapter: any;
  idx: number;
  course: any;
  prevChapter: any | null;
  nextChapter: any | null;
  chapterCount: number;
  courseSlug: string;
  chapterSlug: string;
}

export default function ChapterContent({
  chapter,
  idx,
  course,
  prevChapter,
  nextChapter,
  chapterCount,
  courseSlug,
  chapterSlug,
}: Props) {
  const [mdSource, setMdSource] = useState<string>("");
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    async function fetchMD() {
      setLoading(true);
      setError(null);
      try {
        // Caminho absoluto para SSR/Edge, pode precisar de ajuste para ambiente Next.js
        const filePath = path.join(process.cwd(), "content/courses", courseSlug, `${chapterSlug}.md`);
        const raw = await readFile(filePath, "utf8");
        setMdSource(matter(raw).content);
      } catch (err: any) {
        setError("Conteúdo não encontrado.");
      } finally {
        setLoading(false);
      }
    }
    fetchMD();
  }, [courseSlug, chapterSlug]);

  if (loading) {
    return <div className="p-8 text-muted-foreground">Carregando conteúdo...</div>;
  }
  if (error) {
    return <div className="p-8 text-red-500">{error}</div>;
  }

  /* --------- 1. Parse + compile no browser ---------- */

  /* -------------------- UI -------------------------- */
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
        <h1 className="text-3xl font-bold mb-2">{chapter.title}</h1>
        {chapter.description && (
          <p className="text-lg text-muted-foreground">
            {chapter.description}
          </p>
        )}
      </div>

      {/* conteúdo MyST */}
      <MystRenderer content={mdSource} />

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
