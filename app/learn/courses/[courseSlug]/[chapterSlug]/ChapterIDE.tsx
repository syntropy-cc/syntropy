"use client"

import React, { useState } from "react"
import { Button } from "@/components/ui/button"
import { Menu, Code2, ChevronLeft, Sparkles } from "lucide-react"
import { cn } from "@/lib/utils"

interface CourseIDEProps {
  chapterTitle: string
  className?: string
}

export function ChapterIDE({ chapterTitle, className }: CourseIDEProps) {
  const [isMinimized, setIsMinimized] = useState(false)

  const toggleMinimize = () => {
    setIsMinimized(!isMinimized)
  }

  return (
    <div className={cn(
      "transition-all duration-300 ease-in-out bg-slate-50 dark:bg-slate-900", 
      isMinimized ? "w-16" : "w-96", 
      className
    )}>
      {/* Minimized State - Sidebar */}
      {isMinimized && (
        <div className="h-full flex flex-col border-l border-slate-200 dark:border-slate-700">
          {/* Mini Topbar */}
          <div className="h-12 flex items-center justify-center bg-white dark:bg-slate-800 border-b border-slate-200 dark:border-slate-700">
            <Button
              variant="ghost"
              size="sm"
              onClick={toggleMinimize}
              className="h-8 w-8 p-0"
              aria-label="Expand IDE"
            >
              <Menu className="h-4 w-4" />
            </Button>
          </div>

          {/* Vertical Title - logo abaixo do menu */}
          <div className="flex items-center justify-center pt-4 pb-6">
            <div 
              className="text-xs font-medium text-slate-600 dark:text-slate-400 tracking-wider"
              style={{ 
                writingMode: 'vertical-rl', 
                textOrientation: 'mixed',
                transform: 'rotate(180deg)'
              }}
            >
              CODE EDITOR
            </div>
          </div>

          {/* Spacer */}
          <div className="flex-1"></div>

          {/* Coming Soon Indicator */}
          <div className="flex flex-col items-center justify-center py-4 space-y-2">
            <div className="w-2 h-2 bg-yellow-500 rounded-full animate-pulse"></div>
            <div 
              className="text-xs font-medium text-yellow-600 dark:text-yellow-400"
              style={{ 
                writingMode: 'vertical-rl',
                transform: 'rotate(180deg)'
              }}
            >
              SOON
            </div>
          </div>
        </div>
      )}

      {/* Expanded State - Full IDE */}
      {!isMinimized && (
        <div className="h-full flex flex-col border-l border-slate-200 dark:border-slate-700">
          {/* IDE Topbar */}
          <div className="h-12 flex items-center justify-between px-4 bg-white dark:bg-slate-800 border-b border-slate-200 dark:border-slate-700">
            <div className="flex items-center gap-3">
              <Button
                variant="ghost"
                size="sm"
                onClick={toggleMinimize}
                className="h-8 w-8 p-0"
                aria-label="Minimize IDE"
              >
                <Menu className="h-4 w-4" />
              </Button>
              
              <div className="flex items-center gap-2">
                <Code2 className="h-4 w-4 text-blue-600" />
                <span className="font-semibold text-sm text-slate-700 dark:text-slate-300">
                  Code Editor
                </span>
              </div>
            </div>

            {/* Coming Soon Badge */}
            <div className="flex items-center gap-2 px-3 py-1 bg-gradient-to-r from-yellow-100 to-orange-100 dark:from-yellow-900/30 dark:to-orange-900/30 rounded-full border border-yellow-200 dark:border-yellow-700">
              <Sparkles className="h-3 w-3 text-yellow-600 dark:text-yellow-400" />
              <span className="text-xs font-medium text-yellow-700 dark:text-yellow-300">
                Coming Soon
              </span>
            </div>
          </div>

          {/* Coming Soon Content */}
          <div className="flex-1 flex flex-col items-center justify-center p-8 bg-gradient-to-br from-slate-50 to-slate-100 dark:from-slate-900 dark:to-slate-800">
            {/* Main Icon */}
            <div className="relative mb-6">
              <div className="w-20 h-20 bg-gradient-to-br from-blue-500 to-purple-600 rounded-2xl flex items-center justify-center shadow-lg">
                <Code2 className="h-10 w-10 text-white" />
              </div>
              <div className="absolute -top-1 -right-1 w-6 h-6 bg-yellow-500 rounded-full flex items-center justify-center">
                <Sparkles className="h-3 w-3 text-white" />
              </div>
            </div>

            {/* Title */}
            <h3 className="text-xl font-bold text-slate-800 dark:text-slate-200 mb-2 text-center">
              Interactive Code Editor
            </h3>
            
            {/* Description */}
            <p className="text-sm text-slate-600 dark:text-slate-400 text-center mb-6 max-w-sm leading-relaxed">
              Estamos preparando um ambiente de desenvolvimento completo integrado com o ecossistema {" "}
              <span className="font-semibold text-blue-600 dark:text-blue-400">Syntropy</span>{" "}
              para uma experiência de aprendizado hands-on.
            </p>

            {/* Features Preview */}
            <div className="space-y-3 w-full max-w-sm">
              <div className="flex items-center gap-3 p-3 bg-white dark:bg-slate-800 rounded-lg border border-slate-200 dark:border-slate-700">
                <div className="w-2 h-2 bg-green-500 rounded-full"></div>
                <span className="text-sm text-slate-700 dark:text-slate-300">Execução de código em tempo real</span>
              </div>
              
              <div className="flex items-center gap-3 p-3 bg-white dark:bg-slate-800 rounded-lg border border-slate-200 dark:border-slate-700">
                <div className="w-2 h-2 bg-blue-500 rounded-full"></div>
                <span className="text-sm text-slate-700 dark:text-slate-300">Desenvolvimento interativo</span>
              </div>
              
              <div className="flex items-center gap-3 p-3 bg-white dark:bg-slate-800 rounded-lg border border-slate-200 dark:border-slate-700">
                <div className="w-2 h-2 bg-purple-500 rounded-full"></div>
                <span className="text-sm text-slate-700 dark:text-slate-300">Integração com Syntropy Projects</span>
              </div>
            </div>

            {/* CTA */}
            <div className="mt-8 text-center">
              <div className="inline-flex items-center gap-2 px-4 py-2 bg-gradient-to-r from-blue-600 to-purple-600 text-white text-sm font-medium rounded-lg shadow-lg">
                <div className="w-2 h-2 bg-white rounded-full animate-pulse"></div>
                Em desenvolvimento
              </div>
            </div>
          </div>
        </div>
      )}
    </div>
  )
}