"use client";                // ① indica que este arquivo roda no browser

import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import Link from "next/link";
import { ChevronLeft, ChevronRight, BookOpen, Target } from "lucide-react";
import { MystRenderer } from "@/lib/myst/main";
import { CourseSummary } from "@/lib/courses";
import { CourseUnit, CourseBlock } from "@/types/course";

interface Props {
  unit: CourseUnit;
  block: CourseBlock;
  idx: number;
  course: CourseSummary;
  prevUnit: CourseUnit | null;
  nextUnit: CourseUnit | null;
  mdSource: string;
  unitCount: number;
}

export default function ChapterContent({
  unit,
  block,
  idx,
  course,
  prevUnit,
  nextUnit,
  mdSource,
  unitCount,
}: Props) {
  return (
    <section className="flex-1 p-8 overflow-y-auto">
      {/* cabeçalho */}
      <div className="mb-8">
        {/* Informações do Bloco */}
        <div className="mb-4">
          <div className="flex items-center gap-2 mb-2">
            <BookOpen className="w-4 h-4 text-blue-500" />
            <span className="text-sm font-medium text-blue-600 dark:text-blue-400">
              {block.title}
            </span>
          </div>
        </div>

        {/* Informações da Unidade */}
        <div className="flex items-center gap-2 mb-4">
          <Badge variant="outline">
            Unidade {idx + 1} / {course.unitCount}
          </Badge>
          {unit.duration && (
            <span className="text-sm text-muted-foreground">
              {unit.duration} min de leitura
            </span>
          )}
        </div>

        {/* Título da Unidade */}
        <h1 className="text-2xl font-bold mb-2">{unit.title}</h1>

      </div>

      {/* conteúdo MyST - AGORA COM courseSlug */}
      <MystRenderer 
        content={mdSource} 
        courseSlug={course.slug}
      />

      {/* navegação */}
      <div className="border-t pt-8 flex justify-between">
        {prevUnit ? (
          <Button asChild variant="outline">
            <Link href={`/learn/courses/${course.slug}/${prevUnit.slug}`}>
              <ChevronLeft className="mr-2 h-4 w-4" />
              {prevUnit.title}
            </Link>
          </Button>
        ) : (
          <span />
        )}

        {nextUnit && (
          <Button asChild>
            <Link href={`/learn/courses/${course.slug}/${nextUnit.slug}`}>
              {nextUnit.title}
              <ChevronRight className="ml-2 h-4 w-4" />
            </Link>
          </Button>
        )}
      </div>
    </section>
  );
}