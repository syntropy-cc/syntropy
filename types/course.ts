export interface CourseChapter {
  id: string
  title: string
  slug: string
  description?: string
  duration?: number
  completed?: boolean
  locked?: boolean
}

export interface CourseSummary {
  id: string
  title: string
  slug: string
  description: string
  author: {
    name: string
    avatar?: string
    bio?: string
  }
  level: "beginner" | "intermediate" | "advanced"
  duration: number
  tags: string[]
  chapters: CourseChapter[]
  thumbnail?: string
  published: boolean
  createdAt: string
  updatedAt: string
}

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
