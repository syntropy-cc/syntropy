"use client";

import Link from "next/link"
import { Button } from "@/components/ui/button"
import { ChevronLeft, Menu, BookOpen } from "lucide-react"
import { useSidebar } from "./SidebarProvider"
import { CourseSummary } from "@/lib/courses"

interface ChapterTopbarProps {
  course: CourseSummary
  progressPct: number
}

export function ChapterTopbar({ course, progressPct }: ChapterTopbarProps) {
  const { toggleSidebar } = useSidebar();

  // Calcular estatísticas do curso
  const totalUnits = course.blocks.reduce((total: number, block) => total + block.units.length, 0);
  const totalBlocks = course.blocks.length;

  return (
    <header className="flex items-center justify-between px-8 py-4 border-b bg-background">
      <div className="flex items-center gap-4">
        {/* Menu hamburger - controla sidebar */}
        <Button 
          variant="ghost" 
          size="icon"
          onClick={toggleSidebar}
          className="hover:bg-slate-100 dark:hover:bg-slate-800"
          aria-label="Toggle sidebar"
        >
          <Menu className="h-4 w-4" />
        </Button>
        
        <Link href={`/learn/courses/${course.slug}`}>
          <Button variant="ghost" size="icon">
            <ChevronLeft className="h-4 w-4" />
          </Button>
        </Link>
        
        <div className="flex items-center gap-2">
          <BookOpen className="h-5 w-5 text-blue-500" />
          <span className="font-bold text-lg">{course.title}</span>
        </div>
      </div>
      
      <div className="flex items-center gap-6">
        {/* Estatísticas do curso */}
        <div className="hidden md:flex items-center gap-4 text-sm text-muted-foreground">
          <div className="flex items-center gap-1">
            <span className="font-medium">{totalBlocks}</span>
            <span>blocos</span>
          </div>
          <div className="flex items-center gap-1">
            <span className="font-medium">{totalUnits}</span>
            <span>unidades</span>
          </div>
        </div>
        
        {/* Barra de progresso */}
        <div className="flex-1 mx-4 min-w-0">
          <div className="h-2 bg-muted rounded-full overflow-hidden">
            <div className="bg-primary h-2 transition-all duration-300" style={{ width: `${progressPct}%` }} />
          </div>
          <div className="text-xs text-muted-foreground mt-1 text-center">
            {Math.round(progressPct)}% concluído
          </div>
        </div>
      </div>
    </header>
  )
}