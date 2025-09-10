"use client";

import Link from "next/link"
import { Clock, PlayCircle, BookOpen, Trophy, Target, ChevronRight, ChevronDown, ChevronUp } from "lucide-react"
import { useSidebar } from "./SidebarProvider"
import { useState } from "react"
import { CourseSummary } from "@/lib/courses"
import { CourseUnit, CourseBlock } from "@/types/course"

interface ChapterSidebarProps {
  course: CourseSummary
  unitSlug: string
}

export function ChapterSidebar({ course, unitSlug }: ChapterSidebarProps) {
  const { isCollapsed } = useSidebar();
  const [expandedBlocks, setExpandedBlocks] = useState<Set<string>>(new Set());

  const getUnitIcon = (unit: CourseUnit) => {
    switch (unit.type) {
      case 'project': return Target
      case 'quiz': return Trophy
      case 'milestone': return BookOpen
      default: return PlayCircle
    }
  }

  const getUnitTypeLabel = (type?: string) => {
    switch (type) {
      case 'project': return 'Projeto'
      case 'quiz': return 'Quiz'
      case 'milestone': return 'Marco'
      default: return 'Aula'
    }
  }

  const toggleBlock = (blockId: string) => {
    const newExpanded = new Set(expandedBlocks);
    if (newExpanded.has(blockId)) {
      newExpanded.delete(blockId);
    } else {
      newExpanded.add(blockId);
    }
    setExpandedBlocks(newExpanded);
  };

  // Calcular total de unidades
  const totalUnits = course.blocks.reduce((total, block) => total + block.units.length, 0);

  return (
    <aside className={`hidden md:flex flex-col bg-slate-900/50 border-r border-slate-700/50 backdrop-blur-sm isolate transition-all duration-300 ease-in-out ${
      isCollapsed ? 'w-16' : 'w-80'
    }`}>
      {/* Header */}
      {!isCollapsed && (
        <div className="p-6 border-b border-slate-700/50">
          <div className="space-y-3">
            <div>
              <h2 className="font-semibold text-lg text-white mb-2">
                {course.title}
              </h2>
              <p className="text-sm text-slate-400">
                {totalUnits} unidades em {course.blocks.length} blocos
              </p>
            </div>
          </div>
        </div>
      )}

      {/* Lista de Blocos e Unidades */}
      <nav className="flex-1 p-4 overflow-y-auto">
        <div className="space-y-4">
          {course.blocks.map((block, blockIndex) => {
            const isBlockExpanded = expandedBlocks.has(block.id);
            const hasActiveUnit = block.units.some(unit => unit.slug === unitSlug);
            
            return (
              <div key={block.id} className="space-y-2">
                {/* Cabeçalho do Bloco */}
                <button
                  onClick={() => toggleBlock(block.id)}
                  className={`w-full flex items-center gap-3 p-3 rounded-lg transition-all duration-200 ${
                    hasActiveUnit 
                      ? "bg-blue-500/10 border border-blue-500/30" 
                      : "hover:bg-slate-800/30"
                  }`}
                >
                  <div className="flex items-center justify-center w-6 h-6 rounded bg-slate-700 text-slate-300 text-xs font-semibold flex-shrink-0">
                    {blockIndex + 1}
                  </div>
                  
                  {!isCollapsed && (
                    <>
                      <div className="flex-1 text-left">
                        <h3 className={`font-medium text-sm ${
                          hasActiveUnit ? "text-blue-300" : "text-white"
                        }`}>
                          {block.title}
                        </h3>
                        <p className="text-xs text-slate-400 mt-1 line-clamp-2">
                          {block.description}
                        </p>
                      </div>
                      
                      {isBlockExpanded ? (
                        <ChevronUp className="w-4 h-4 text-slate-400" />
                      ) : (
                        <ChevronDown className="w-4 h-4 text-slate-400" />
                      )}
                    </>
                  )}
                </button>

                {/* Lista de Unidades do Bloco */}
                {(!isCollapsed && isBlockExpanded) && (
                  <div className="ml-4 space-y-1">
                    {block.units.map((unit, unitIndex) => {
                      const Icon = getUnitIcon(unit);
                      const isActive = unit.slug === unitSlug;
                      
                      return (
                        <Link
                          key={unit.slug}
                          href={`/learn/courses/${course.slug}/${unit.slug}`}
                          className={`group relative flex items-center gap-3 p-3 rounded-lg transition-all duration-200 ${
                            isActive 
                              ? "bg-blue-500/10 border border-blue-500/30 shadow-lg shadow-blue-500/5" 
                              : "hover:bg-slate-800/50 hover:border-slate-600/50 border border-transparent"
                          }`}
                        >
                          {/* Número da Unidade */}
                          <div className={`flex items-center justify-center text-xs font-semibold transition-colors w-6 h-6 rounded-full ${
                            isActive 
                              ? "bg-blue-500/20 border border-blue-500/50 text-blue-300" 
                              : "bg-slate-800 border border-slate-600 text-slate-300"
                          } flex-shrink-0`}>
                            {unitIndex + 1}
                          </div>

                          {/* Conteúdo da Unidade */}
                          <div className="flex-1 min-w-0">
                            <div className="flex items-start justify-between gap-2">
                              <h4 className={`font-medium text-sm leading-tight mb-1 ${
                                isActive 
                                  ? "text-blue-300" 
                                  : "text-white group-hover:text-blue-200"
                              }`}>
                                {unit.title}
                              </h4>
                              
                              <ChevronRight className={`w-3 h-3 flex-shrink-0 transition-transform text-slate-500 group-hover:text-slate-300 ${
                                isActive 
                                  ? "text-blue-400 transform translate-x-1" 
                                  : ""
                              }`} />
                            </div>
                            
                            {/* Metadados da Unidade */}
                            <div className="flex items-center gap-3 text-xs">
                              {/* Tipo da Unidade */}
                              <div className="flex items-center gap-1.5">
                                <Icon className={
                                  unit.type === 'project' ? 'w-3 h-3 text-purple-400' :
                                  unit.type === 'quiz' ? 'w-3 h-3 text-amber-400' :
                                  unit.type === 'milestone' ? 'w-3 h-3 text-emerald-400' :
                                  'w-3 h-3 text-blue-400'
                                } />
                                <span className="text-slate-400">
                                  {getUnitTypeLabel(unit.type)}
                                </span>
                              </div>
                              
                              {/* Duração */}
                              {unit.duration && (
                                <div className="flex items-center gap-1">
                                  <Clock className="w-3 h-3 text-slate-500" />
                                  <span className="text-slate-400">{unit.duration}min</span>
                                </div>
                              )}
                              
                              {/* Artifact indicator */}
                              {unit.artifact && (
                                <div className="flex items-center gap-1">
                                  <Target className="w-3 h-3 text-green-400" />
                                  <span className="text-green-400">Exercício</span>
                                </div>
                              )}
                            </div>
                          </div>
                        </Link>
                      );
                    })}
                  </div>
                )}
              </div>
            );
          })}
        </div>
      </nav>
    </aside>
  )
}