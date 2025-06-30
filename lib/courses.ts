// lib/courses.ts - Versão simplificada para /public/courses
import { cache } from "react";
import fs from "fs/promises";
import path from "path";
import matter from "gray-matter";

export interface CourseSummary {
  slug: string;
  title: string;
  description?: string;
  level?: 'beginner' | 'intermediate' | 'advanced';
  duration?: number;
  cover?: string;
  author?: {
    name: string;
    bio?: string;
  };
  tags?: string[];
  outcomes?: Array<{
    title: string;
    description: string;
  }>;
  chapters: Array<{
    id?: string;
    slug: string;
    title: string;
    description?: string;
    duration?: number;
    completed?: boolean;
    sections?: string[];
    project?: string;
  }>;
}

/** Caminho absoluto para a pasta de cursos em /public */
const COURSES_DIR = path.join(process.cwd(), "public", "courses");

/**
 * Carrega um curso a partir do summary.json em /public/courses/[courseSlug]/
 */
export const getCourseSummary = cache(
  async (courseSlug: string): Promise<CourseSummary | null> => {
    try {
      const summaryPath = path.join(COURSES_DIR, courseSlug, "summary.json");
      
      // Verificar se o arquivo existe
      try {
        await fs.access(summaryPath);
      } catch {
        console.error(`[COURSES] summary.json não encontrado: ${summaryPath}`);
        return null;
      }
      
      // Ler o arquivo summary.json
      const summaryContent = await fs.readFile(summaryPath, 'utf8');
      const summaryData = JSON.parse(summaryContent);
      
      // Construir o caminho da capa
      let coverPath: string | undefined;
      if (summaryData.cover) {
        // Se a capa já começar com '/', usar como está, senão construir o caminho
        coverPath = summaryData.cover.startsWith('/') 
          ? summaryData.cover 
          : `/courses/${courseSlug}/${summaryData.cover}`;
      }
      
      const courseSummary: CourseSummary = {
        ...summaryData,
        slug: courseSlug,
        cover: coverPath,
      };
      
      return courseSummary;
    } catch (error) {
      console.error(`[COURSES] Erro ao carregar curso ${courseSlug}:`, error);
      return null;
    }
  }
);

/**
 * Lista todos os cursos disponíveis lendo /public/courses/
 */
export const getAllCourses = cache(async (): Promise<CourseSummary[]> => {
  try {
    // Verificar se o diretório existe
    try {
      await fs.access(COURSES_DIR);
    } catch {
      console.error('[COURSES] Diretório não encontrado:', COURSES_DIR);
      return [];
    }
    
    // Ler todas as pastas em /public/courses/
    const courseDirs = await fs.readdir(COURSES_DIR, { withFileTypes: true });
    const courseSlugList = courseDirs
      .filter(dirent => dirent.isDirectory())
      .map(dirent => dirent.name);
    
    const courses: CourseSummary[] = [];
    
    for (const courseSlug of courseSlugList) {
      const course = await getCourseSummary(courseSlug);
      if (course) {
        courses.push(course);
      }
    }
    
    return courses;
  } catch (error) {
    console.error('[COURSES] Erro ao listar cursos:', error);
    return [];
  }
});

/**
 * Carrega o conteúdo markdown de um capítulo de /public/courses/
 */
export const getChapterContent = cache(
  async (courseSlug: string, chapterSlug: string): Promise<string | null> => {
    try {
      const filePath = path.join(COURSES_DIR, courseSlug, `${chapterSlug}.md`);
      
      // Verificar se o arquivo existe
      try {
        await fs.access(filePath);
      } catch {
        console.error(`[COURSES] Markdown não encontrado: ${filePath}`);
        return null;
      }
      
      const content = await fs.readFile(filePath, 'utf8');
      
      // Remove frontmatter se existir
      const { content: markdownContent } = matter(content);
      
      return markdownContent;
    } catch (error) {
      console.error(`[COURSES] Erro ao carregar markdown ${courseSlug}/${chapterSlug}:`, error);
      return null;
    }
  }
);

// Funções de progresso do usuário (Supabase) permanecem inalteradas
export interface CourseProgress {
  course_id: string;
  user_id: string;
  current_chapter: string;
  last_accessed_at: string;
}

export const getCourseProgress = async (
  courseId: string,
  userId: string,
): Promise<CourseProgress | null> => {
  try {
    const { createServerSupabaseClient } = await import('./supabase-server');
    const supabase = await createServerSupabaseClient();
    
    if (!supabase) return null;

    const { data, error } = await supabase
      .from("course_progress")
      .select("*")
      .eq("course_id", courseId)
      .eq("user_id", userId)
      .single();

    if (error && error.code !== "PGRST116") throw error;
    return data;
  } catch (error) {
    console.error('Erro ao buscar progresso do curso:', error);
    return null;
  }
};

export const updateCourseProgress = async (
  courseId: string,
  userId: string,
  chapterId: string,
): Promise<void> => {
  try {
    const { createServerSupabaseClient } = await import('./supabase-server');
    const supabase = await createServerSupabaseClient();
    
    if (!supabase) return;

    const { error } = await supabase.from("course_progress").upsert({
      course_id: courseId,
      user_id: userId,
      current_chapter: chapterId,
      last_accessed_at: new Date().toISOString(),
    });

    if (error) throw error;
  } catch (error) {
    console.error('Erro ao atualizar progresso do curso:', error);
  }
};