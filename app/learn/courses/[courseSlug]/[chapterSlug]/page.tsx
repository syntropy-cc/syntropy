// app/learn/courses/[courseSlug]/[chapterSlug]/page.tsx
import { getCourseSummary, getChapterContent } from "@/lib/courses";
import { ChapterSidebar } from "./ChapterSidebar";
import { ChapterTopbar } from "./ChapterTopbar";
import ChapterContent from "./ChapterContent";
import { ChapterIDE } from "./ChapterIDE";
import { SidebarProvider } from "./SidebarProvider";
import { notFound } from "next/navigation";

export default async function ChapterPage({
  params,
}: {
  params: { courseSlug: string; chapterSlug: string };
}) {
  const { courseSlug, chapterSlug } = params;

  console.log('[DEBUG PAGE] Carregando página do capítulo:', { courseSlug, chapterSlug });

  const course = await getCourseSummary(courseSlug);
  if (!course) {
    console.error('[DEBUG PAGE] Curso não encontrado:', courseSlug);
    notFound();
  }

  const idx = course.chapters.findIndex((c) => c.slug === chapterSlug);
  if (idx === -1) {
    console.error('[DEBUG PAGE] Capítulo não encontrado:', chapterSlug);
    notFound();
  }

  const chapter = course.chapters[idx];
  const prevChapter = idx > 0 ? course.chapters[idx - 1] : null;
  const nextChapter =
    idx < course.chapters.length - 1 ? course.chapters[idx + 1] : null;

  // Carregar o conteúdo do markdown do capítulo usando a nova função
  const mdSource = await getChapterContent(courseSlug, chapterSlug);
  if (!mdSource) {
    console.error('[DEBUG PAGE] Conteúdo markdown não encontrado:', { courseSlug, chapterSlug });
    notFound();
  }

  console.log('[DEBUG PAGE] Tudo carregado com sucesso, renderizando página');

  const progressPct = ((idx + 1) / course.chapters.length) * 100;

  return (
    <SidebarProvider>
      <div className="flex flex-col h-screen">
        <ChapterTopbar course={course} progressPct={progressPct} />

        <div className="flex flex-1 overflow-hidden">
          <ChapterSidebar course={course} chapterSlug={chapterSlug} />

          <main className="flex-1 flex overflow-hidden">
            <ChapterContent
              chapter={chapter}
              idx={idx}
              course={course}
              prevChapter={prevChapter}
              nextChapter={nextChapter}
              chapterCount={course.chapters.length}
              mdSource={mdSource}
            />

            {/* ChapterIDE oculto em telas pequenas (mobile) */}
            <div className="hidden xl:block">
              <ChapterIDE chapterTitle={chapter.title} />
            </div>
          </main>
        </div>
      </div>
    </SidebarProvider>
  );
}