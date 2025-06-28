// app/learn/courses/[courseSlug]/[chapterSlug]/page.tsx
import path from "path";
import { readFile } from "fs/promises";
import matter from "gray-matter";
import { notFound } from "next/navigation";

import { getCourseSummary } from "@/lib/courses";
import { ChapterSidebar } from "./ChapterSidebar";
import { ChapterTopbar } from "./ChapterTopbar";
import ChapterContent from "./ChapterContent";
import { ChapterIDE } from "./ChapterIDE";

async function loadChapterMD(course: string, chapter: string) {
  try {
    const raw = await readFile(
      path.join(process.cwd(), "content/courses", course, `${chapter}.md`),
      "utf8"
    );
    return matter(raw).content;
  } catch {
    return null;
  }
}

export default async function ChapterPage({
  params,
}: {
  params: { courseSlug: string; chapterSlug: string };
}) {
  const { courseSlug, chapterSlug } = params;

  const course = await getCourseSummary(courseSlug);
  if (!course) notFound();

  const idx = course.chapters.findIndex((c) => c.slug === chapterSlug);
  if (idx === -1) notFound();

  const chapter = course.chapters[idx];
  const prevChapter = idx > 0 ? course.chapters[idx - 1] : null;
  const nextChapter =
    idx < course.chapters.length - 1 ? course.chapters[idx + 1] : null;

  const mdSource = await loadChapterMD(courseSlug, chapterSlug);
  if (!mdSource) notFound();

  const progressPct = ((idx + 1) / course.chapters.length) * 100;

  return (
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
            mdSource={mdSource}
            chapterCount={course.chapters.length}
          />

          <ChapterIDE chapterTitle={chapter.title} />
        </main>
      </div>
    </div>
  );
}
