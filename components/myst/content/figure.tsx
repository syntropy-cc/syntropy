import React from 'react';
import Image from 'next/image';

export interface FigureProps {
  /** Caminho da imagem (ex: /images/python-img.png) */
  src: string;
  /** Texto alternativo */
  alt?: string;
  /** Largura da imagem */
  width?: string | number;
  /** Altura da imagem */
  height?: string | number;
  /** Alinhamento da figura */
  align?: 'left' | 'center' | 'right';
  /** Legenda da figura */
  caption?: React.ReactNode;
  /** Slug do curso para resolução de caminho */
  courseSlug?: string;
  /** Propriedades adicionais da imagem */
  imageProps?: Partial<React.ComponentProps<typeof Image>>;
}

/**
 * Resolve o caminho da imagem baseado no curso atual
 * Se courseSlug for fornecido, resolve para /content/courses/[courseSlug]/images/
 * Caso contrário, assume que o caminho já está correto ou usa uma URL absoluta
 */
function resolveImagePath(src: string, courseSlug?: string): string {
  console.log('[DEBUG FIGURE] Resolvendo caminho da imagem:', { src, courseSlug });
  
  // Se já é uma URL absoluta (http/https), retorna como está
  if (src.startsWith('http://') || src.startsWith('https://')) {
    console.log('[DEBUG FIGURE] URL absoluta detectada:', src);
    return src;
  }
  
  // Se começa com /images/ e temos courseSlug, resolve para o diretório do curso
  if (src.startsWith('/images/') && courseSlug) {
    const resolvedPath = `/content/courses/${courseSlug}${src}`;
    console.log('[DEBUG FIGURE] Resolvido caminho /images/ com courseSlug:', resolvedPath);
    return resolvedPath;
  }
  
  // Se começa com /content/, já está no formato correto
  if (src.startsWith('/content/')) {
    console.log('[DEBUG FIGURE] Caminho /content/ já está correto:', src);
    return src;
  }
  
  // Fallback: assume que é um caminho relativo da pasta images do curso
  if (courseSlug) {
    const imageName = src.replace(/^\/+/, ''); // Remove barras iniciais
    const resolvedPath = `/content/courses/${courseSlug}/images/${imageName}`;
    console.log('[DEBUG FIGURE] Fallback para caminho relativo:', resolvedPath);
    return resolvedPath;
  }
  
  console.log('[DEBUG FIGURE] Nenhuma resolução aplicada, retornando src original:', src);
  return src;
}

/**
 * Converte valor de largura/altura para formato adequado
 */
function parseSize(size: string | number | undefined): number | undefined {
  if (!size) return undefined;
  if (typeof size === 'number') return size;
  
  // Remove 'px' e converte para número
  const numericValue = parseInt(size.replace('px', ''), 10);
  return isNaN(numericValue) ? undefined : numericValue;
}

/**
 * Componente Figure para renderizar imagens com estilização do Syntropy
 */
const Figure: React.FC<FigureProps> = ({
  src,
  alt = '',
  width,
  height,
  align = 'center',
  caption,
  courseSlug,
  imageProps = {}
}) => {
  console.log('[DEBUG FIGURE] Props recebidas:', { src, alt, width, height, align, courseSlug });
  
  const resolvedSrc = resolveImagePath(src, courseSlug);
  const parsedWidth = parseSize(width);
  const parsedHeight = parseSize(height);

  console.log('[DEBUG FIGURE] Caminho final resolvido:', resolvedSrc);
  console.log('[DEBUG FIGURE] Dimensões parseadas:', { parsedWidth, parsedHeight });

  // Classes de alinhamento
  const alignmentClasses = {
    left: 'justify-start',
    center: 'justify-center',
    right: 'justify-end'
  };

  // Classes do container baseadas na estética do Syntropy
  const containerClasses = `
    flex ${alignmentClasses[align]} w-full my-8
  `.trim();

  const figureClasses = `
    relative max-w-full
    bg-gradient-to-br from-slate-800/50 to-slate-900/50
    border border-slate-700/50
    rounded-xl p-4
    shadow-lg shadow-black/20
    backdrop-blur-sm
  `.trim();

  const imageWrapperClasses = `
    relative overflow-hidden rounded-lg
    bg-slate-800/30 border border-slate-600/30
  `.trim();

  return (
    <div className={containerClasses}>
      <figure className={figureClasses} style={{ maxWidth: parsedWidth ? `${parsedWidth}px` : 'fit-content' }}>
        <div className={imageWrapperClasses}>
          {/* Usando Next.js Image para otimização */}
          <Image
            src={resolvedSrc}
            alt={alt}
            width={parsedWidth || 400}
            height={parsedHeight || 300}
            className="object-cover w-full h-auto transition-transform duration-300 hover:scale-105"
            style={{
              width: parsedWidth ? `${parsedWidth}px` : 'auto',
              height: parsedHeight ? `${parsedHeight}px` : 'auto'
            }}
            placeholder="blur"
            blurDataURL="data:image/jpeg;base64,/9j/4AAQSkZJRgABAQAAAQABAAD/2wBDAAYEBQYFBAYGBQYHBwYIChAKCgkJChQODwwQFxQYGBcUFhYaHSUfGhsjHBYWICwgIyYnKSopGR8tMC0oMCUoKSj/2wBDAQcHBwoIChMKChMoGhYaKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCj/wAARCAABAAEDASIAAhEBAxEB/8QAFQABAQAAAAAAAAAAAAAAAAAAAAv/xAAUEAEAAAAAAAAAAAAAAAAAAAAA/8QAFQEBAQAAAAAAAAAAAAAAAAAAAAX/xAAUEQEAAAAAAAAAAAAAAAAAAAAA/9oADAMBAAIRAxEAPwCdABmX/9k="
            onError={(e) => {
              console.error('[DEBUG FIGURE] Erro ao carregar imagem:', {
                src: resolvedSrc,
                originalSrc: src,
                courseSlug,
                error: e
              });
            }}
            onLoad={() => {
              console.log('[DEBUG FIGURE] Imagem carregada com sucesso:', resolvedSrc);
            }}
            {...imageProps}
          />
        </div>
        
        {caption && (
          <figcaption className="mt-4 text-sm text-slate-400 text-center leading-relaxed">
            {caption}
          </figcaption>
        )}
      </figure>
    </div>
  );
};

export default Figure;