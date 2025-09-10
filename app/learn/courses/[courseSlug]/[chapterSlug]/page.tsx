// app/learn/courses/[courseSlug]/[chapterSlug]/page.tsx
import { getCourseSummary, getChapterContent, CourseSummary } from "@/lib/courses";
import { ChapterSidebar } from "./ChapterSidebar";
import { ChapterTopbar } from "./ChapterTopbar";
import ChapterContent from "./ChapterContent";
import { ChapterIDE } from "./ChapterIDE";
import { SidebarProvider } from "./SidebarProvider";
import { notFound } from "next/navigation";
import { CourseUnit, CourseBlock } from "@/types/course";

export default async function ChapterPage({
  params,
}: {
  params: { courseSlug: string; chapterSlug: string };
}) {
  const { courseSlug, chapterSlug } = params;

  console.log('[DEBUG PAGE] Carregando página da unidade:', { courseSlug, chapterSlug });

  const course: CourseSummary | null = await getCourseSummary(courseSlug);
  if (!course) {
    console.error('[DEBUG PAGE] Curso não encontrado:', courseSlug);
    notFound();
  }

  // Encontrar a unidade nos blocos
  let unit: CourseUnit | null = null;
  let block: CourseBlock | null = null;
  let blockIndex = -1;
  let unitIndex = -1;
  
  for (let i = 0; i < course.blocks.length; i++) {
    const currentBlock = course.blocks[i];
    const foundUnitIndex = currentBlock.units.findIndex((u) => u.slug === chapterSlug);
    if (foundUnitIndex !== -1) {
      unit = currentBlock.units[foundUnitIndex];
      block = currentBlock;
      blockIndex = i;
      unitIndex = foundUnitIndex;
      break;
    }
  }

  if (!unit || !block) {
    console.error('[DEBUG PAGE] Unidade não encontrada:', chapterSlug);
    notFound();
  }

  // Encontrar unidade anterior e próxima
  let prevUnit: CourseUnit | null = null;
  let nextUnit: CourseUnit | null = null;
  
  if (unitIndex > 0) {
    prevUnit = course.blocks[blockIndex].units[unitIndex - 1];
  } else if (blockIndex > 0) {
    const prevBlock = course.blocks[blockIndex - 1];
    if (prevBlock.units.length > 0) {
      prevUnit = prevBlock.units[prevBlock.units.length - 1];
    }
  }
  
  if (unitIndex < course.blocks[blockIndex].units.length - 1) {
    nextUnit = course.blocks[blockIndex].units[unitIndex + 1];
  } else if (blockIndex < course.blocks.length - 1) {
    const nextBlock = course.blocks[blockIndex + 1];
    if (nextBlock.units.length > 0) {
      nextUnit = nextBlock.units[0];
    }
  }

  // Carregar o conteúdo do markdown da unidade usando a nova função
  const mdSource = await getChapterContent(courseSlug, chapterSlug);
  if (!mdSource) {
    console.error('[DEBUG PAGE] Conteúdo markdown não encontrado:', { courseSlug, chapterSlug });
    notFound();
  }

  console.log('[DEBUG PAGE] Tudo carregado com sucesso, renderizando página');

  // Calcular progresso baseado no total de unidades
  const totalUnits = course.blocks.reduce((total, block) => total + block.units.length, 0);
  const currentUnitNumber = course.blocks.slice(0, blockIndex).reduce((total, block) => total + block.units.length, 0) + unitIndex + 1;
  const progressPct = (currentUnitNumber / totalUnits) * 100;

  return (
    <SidebarProvider>
      <div className="flex flex-col h-screen">
        <ChapterTopbar course={course} progressPct={progressPct} />

        <div className="flex flex-1 overflow-hidden">
          <ChapterSidebar course={course} unitSlug={chapterSlug} />

          <main className="flex-1 flex overflow-hidden">
            <ChapterContent
              unit={unit}
              block={block}
              idx={currentUnitNumber - 1}
              course={course}
              prevUnit={prevUnit}
              nextUnit={nextUnit}
              unitCount={totalUnits}
              mdSource={mdSource}
            />

            {/* ChapterIDE oculto em telas pequenas (mobile) */}
            <div className="hidden xl:block">
              <ChapterIDE chapterTitle={unit.title} />
            </div>
          </main>
        </div>
      </div>
    </SidebarProvider>
  );
}