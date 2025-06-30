import Link from "next/link"
import { Clock, PlayCircle, BookOpen, Trophy, Target, ChevronRight } from "lucide-react"

interface Chapter {
  slug: string
  title: string
  duration?: number
  type?: 'lesson' | 'project' | 'quiz' | 'milestone'
  difficulty?: 'beginner' | 'intermediate' | 'advanced'
}

interface Course {
  slug: string
  title: string
  chapters: Chapter[]
}

interface ChapterSidebarProps {
  course: Course
  chapterSlug: string
}

export function ChapterSidebar({ course, chapterSlug }: ChapterSidebarProps) {
  const getChapterIcon = (chapter: Chapter) => {
    switch (chapter.type) {
      case 'project': return Target
      case 'quiz': return Trophy
      case 'milestone': return BookOpen
      default: return PlayCircle
    }
  }

  const getChapterTypeLabel = (type?: string) => {
    switch (type) {
      case 'project': return 'Projeto'
      case 'quiz': return 'Quiz'
      case 'milestone': return 'Marco'
      default: return 'Aula'
    }
  }

  return (
    <aside className="hidden md:flex flex-col w-80 bg-slate-900/50 border-r border-slate-700/50 backdrop-blur-sm isolate">
      {/* Header */}
      <div className="p-6 border-b border-slate-700/50">
        <div className="space-y-3">
          <div>
            <h2 className="font-semibold text-lg text-white mb-2">
              {course.title}
            </h2>
            <p className="text-sm text-slate-400">
              {course.chapters.length} capítulos disponíveis
            </p>
          </div>
        </div>
      </div>

      {/* Lista de Capítulos */}
      <nav className="flex-1 p-4 overflow-y-auto">
        <div className="space-y-2">
          {course.chapters.map((chapter, index) => {
            const Icon = getChapterIcon(chapter)
            const isActive = chapter.slug === chapterSlug
            
            return (
              <Link
                key={chapter.slug}
                href={`/learn/courses/${course.slug}/${chapter.slug}`}
                className={`group relative flex items-center gap-3 p-4 rounded-lg transition-all duration-200 hover:bg-slate-800/50 hover:border-slate-600/50 border border-transparent ${
                  isActive 
                    ? "bg-blue-500/10 border-blue-500/30 shadow-lg shadow-blue-500/5" 
                    : ""
                }`}
              >
                {/* Número do Capítulo */}
                <div className={`flex items-center justify-center w-8 h-8 rounded-full text-sm font-semibold transition-colors bg-slate-800 border border-slate-600 text-slate-300 ${
                  isActive 
                    ? "bg-blue-500/20 border-blue-500/50 text-blue-300" 
                    : ""
                }`}>
                  {index + 1}
                </div>

                {/* Conteúdo do Capítulo */}
                <div className="flex-1 min-w-0">
                  <div className="flex items-start justify-between gap-2">
                    <h3 className={`font-medium text-sm leading-tight mb-1 ${
                      isActive 
                        ? "text-blue-300" 
                        : "text-white group-hover:text-blue-200"
                    }`}>
                      {chapter.title}
                    </h3>
                    
                    <ChevronRight className={`w-4 h-4 flex-shrink-0 transition-transform text-slate-500 group-hover:text-slate-300 ${
                      isActive 
                        ? "text-blue-400 transform translate-x-1" 
                        : ""
                    }`} />
                  </div>
                  
                  {/* Metadados do Capítulo */}
                  <div className="flex items-center gap-3 text-xs">
                    {/* Tipo do Capítulo */}
                    <div className="flex items-center gap-1.5">
                      <Icon className={
                        chapter.type === 'project' ? 'w-3 h-3 text-purple-400' :
                        chapter.type === 'quiz' ? 'w-3 h-3 text-amber-400' :
                        chapter.type === 'milestone' ? 'w-3 h-3 text-emerald-400' :
                        'w-3 h-3 text-blue-400'
                      } />
                      <span className="text-slate-400">
                        {getChapterTypeLabel(chapter.type)}
                      </span>
                    </div>
                    
                    {/* Duração */}
                    {chapter.duration && (
                      <div className="flex items-center gap-1">
                        <Clock className="w-3 h-3 text-slate-500" />
                        <span className="text-slate-400">{chapter.duration}min</span>
                      </div>
                    )}
                    
                    {/* Dificuldade */}
                    {chapter.difficulty && (
                      <div className="flex items-center gap-1">
                        <div className={
                          chapter.difficulty === 'advanced' ? 'w-2 h-2 rounded-full bg-red-400' :
                          chapter.difficulty === 'intermediate' ? 'w-2 h-2 rounded-full bg-yellow-400' :
                          'w-2 h-2 rounded-full bg-green-400'
                        } />
                        <span className={`capitalize ${
                          chapter.difficulty === 'advanced' ? 'text-red-400' :
                          chapter.difficulty === 'intermediate' ? 'text-yellow-400' :
                          'text-green-400'
                        }`}>
                          {chapter.difficulty === 'beginner' ? 'Iniciante' :
                           chapter.difficulty === 'intermediate' ? 'Intermediário' :
                           'Avançado'}
                        </span>
                      </div>
                    )}
                  </div>
                </div>
              </Link>
            )
          })}
        </div>
      </nav>
    </aside>
  )
}