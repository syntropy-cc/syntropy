// Re-exportar tipos do lib/courses.ts para manter consistência
export type { CourseSummary } from '@/lib/courses'

export interface CourseUnit {
  id: string
  slug: string
  title: string
  description?: string
  duration?: number
  artifact?: string
  fragments?: string[]
  completed?: boolean
  locked?: boolean
  type?: 'lesson' | 'project' | 'quiz' | 'milestone'
  difficulty?: 'beginner' | 'intermediate' | 'advanced'
}

export interface CourseBlock {
  id: string
  title: string
  description: string
  units: CourseUnit[]
}

// Manter compatibilidade com versão anterior
export interface CourseChapter extends CourseUnit {}

export interface CourseProgress {
  courseId: string
  userId: string
  completedChapters: string[]
  currentChapter?: string
  progress: number
  lastAccessedAt: string
}

export interface User {
  id: string
  email: string
  name: string
  avatar?: string
  createdAt: string
}
