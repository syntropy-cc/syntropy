// app/learn/courses/[courseSlug]/[chapterSlug]/MinimizableIDE.tsx
"use client";

import { ChapterIDE } from "./ChapterIDE";
import { useSidebar } from "./SidebarProvider";

interface MinimizableIDEProps {
  chapterTitle: string;
}

export function MinimizableIDE({ chapterTitle }: MinimizableIDEProps) {
  const { isIdeMinimized } = useSidebar();

  return (
    <div 
      className={`transition-all duration-300 ease-in-out overflow-hidden ${
        isIdeMinimized ? 'w-0 opacity-0' : 'w-96 opacity-100'
      }`}
    >
      <ChapterIDE chapterTitle={chapterTitle} />
    </div>
  );
}