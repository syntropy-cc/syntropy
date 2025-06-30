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
 * Mapeia para a pasta /public/courses/ para que o Next.js sirva automaticamente
 */
function resolveImagePath(src: string, courseSlug?: string): string {
  console.log('[DEBUG FIGURE] Resolvendo caminho da imagem:', { src, courseSlug });
  
  // Se já é uma URL absoluta (http/https), retorna como está
  if (src.startsWith('http://') || src.startsWith('https://')) {
    console.log('[DEBUG FIGURE] URL absoluta detectada:', src);
    return src;
  }
  
  // NOVA LÓGICA: Mapear para /public/courses/[courseSlug]/images/
  if (src.startsWith('/images/') && courseSlug) {
    const imageName = src.replace('/images/', '');
    const resolvedPath = `/courses/${courseSlug}/images/${imageName}`;
    console.log('[DEBUG FIGURE] Resolvido para /public/courses:', resolvedPath);
    return resolvedPath;
  }
  
  // Se já começa com /courses/, assume que está correto
  if (src.startsWith('/courses/')) {
    console.log('[DEBUG FIGURE] Caminho /courses/ já está correto:', src);
    return src;
  }
  
  // Fallback: assume que é um caminho relativo da pasta images do curso
  if (courseSlug) {
    const imageName = src.replace(/^\/+/, ''); // Remove barras iniciais
    const resolvedPath = `/courses/${courseSlug}/images/${imageName}`;
    console.log('[DEBUG FIGURE] Fallback para /public/courses:', resolvedPath);
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
 * Calcula dimensões responsivas baseadas no tamanho especificado
 */
function getResponsiveDimensions(width?: string | number, height?: string | number) {
  const parsedWidth = parseSize(width);
  const parsedHeight = parseSize(height);
  
  // Valores padrão otimizados - usa largura total disponível
  const defaultWidth = 800;  // Largura padrão mais generosa para ocupar o conteúdo
  const defaultHeight = 500; // Altura proporcional
  
  // Se apenas largura foi especificada, calcular altura proporcionalmente (16:10)
  if (parsedWidth && !parsedHeight) {
    return {
      width: parsedWidth,
      height: Math.round(parsedWidth * 0.625) // Proporção 16:10 (mais widescreen)
    };
  }
  
  // Se apenas altura foi especificada, calcular largura proporcionalmente
  if (parsedHeight && !parsedWidth) {
    return {
      width: Math.round(parsedHeight * 1.6), // Proporção 16:10
      height: parsedHeight
    };
  }
  
  // Se ambos foram especificados, usar valores especificados
  if (parsedWidth && parsedHeight) {
    return {
      width: parsedWidth,
      height: parsedHeight
    };
  }
  
  // Valores padrão se nada foi especificado
  return {
    width: defaultWidth,
    height: defaultHeight
  };
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
  const dimensions = getResponsiveDimensions(width, height);

  console.log('[DEBUG FIGURE] Caminho final resolvido:', resolvedSrc);
  console.log('[DEBUG FIGURE] Dimensões calculadas:', dimensions);

  // Classes de alinhamento
  const alignmentClasses = {
    left: 'justify-start',
    center: 'justify-center',
    right: 'justify-end'
  };

  // Classes do container - ocupa largura total do conteúdo
  const containerClasses = `flex ${alignmentClasses[align]} w-full my-8`;

  // Moldura mais fina e responsiva - só aparece se a imagem for grande o suficiente
  const shouldShowFrame = dimensions.width >= 400; // Só mostra moldura para imagens >= 400px
  
  const figureClasses = shouldShowFrame ? `
    relative w-full
    bg-gradient-to-br from-slate-800/30 to-slate-900/30
    border border-slate-700/30
    rounded-lg p-2 sm:p-3
    shadow-md shadow-black/10
    backdrop-blur-sm
  `.trim() : `
    relative w-full
  `.trim();

  const imageWrapperClasses = shouldShowFrame ? `
    relative overflow-hidden rounded-md
    bg-slate-800/20 border border-slate-600/20
  `.trim() : `
    relative overflow-hidden rounded-lg
  `.trim();

  return (
    <div className={containerClasses}>
      <figure className={figureClasses}>
        <div className={imageWrapperClasses}>
          {/* Imagem ocupa toda a largura disponível */}
          <Image
            src={resolvedSrc}
            alt={alt}
            width={dimensions.width}
            height={dimensions.height}
            className="w-full h-auto object-contain transition-transform duration-300 hover:scale-[1.02]"
            style={{
              maxWidth: '100%',
              height: 'auto'
            }}
            sizes="(max-width: 640px) 100vw, (max-width: 1024px) 90vw, 85vw"
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