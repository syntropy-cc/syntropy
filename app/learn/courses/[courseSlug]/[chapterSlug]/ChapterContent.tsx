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
          <p className="text-sm text-muted-foreground mb-4">
            {block.description}
          </p>
        </div>

        {/* Informações da Unidade */}
        <div className="flex items-center gap-2 mb-4">
          <Badge variant="outline">
            Unidade {idx + 1} / {unitCount}
          </Badge>
          {unit.duration && (
            <span className="text-sm text-muted-foreground">
              {unit.duration} min
            </span>
          )}
        </div>

        {/* Título da Unidade */}
        <h1 className="text-2xl font-bold mb-2">{unit.title}</h1>
        {unit.description && (
          <p className="text-muted-foreground mb-4">{unit.description}</p>
        )}

        {/* Artifact (exercício) */}
        {unit.artifact && (
          <div className="bg-blue-50 dark:bg-blue-950/20 border border-blue-200 dark:border-blue-800 rounded-lg p-4 mb-6">
            <div className="flex items-center gap-2 mb-2">
              <Target className="w-4 h-4 text-blue-600 dark:text-blue-400" />
              <span className="font-medium text-blue-800 dark:text-blue-200">
                Exercício
              </span>
            </div>
            <p className="text-sm text-blue-700 dark:text-blue-300">
              {unit.artifact}
            </p>
          </div>
        )}

        {/* Fragments (seções) */}
        {unit.fragments && unit.fragments.length > 0 && (
          <div className="bg-slate-50 dark:bg-slate-900/50 border border-slate-200 dark:border-slate-700 rounded-lg p-4 mb-6">
            <h3 className="font-medium mb-3 text-slate-800 dark:text-slate-200">
              Conteúdo desta unidade:
            </h3>
            <ul className="space-y-2">
              {unit.fragments.map((fragment: string, index: number) => (
                <li key={index} className="flex items-start gap-2 text-sm text-slate-600 dark:text-slate-400">
                  <span className="w-1.5 h-1.5 rounded-full bg-slate-400 mt-2 flex-shrink-0" />
                  {fragment}
                </li>
              ))}
            </ul>
          </div>
        )}
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