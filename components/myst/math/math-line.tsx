import React, { useMemo } from 'react';
import katex from 'katex';
import 'katex/dist/katex.min.css';

interface MathLineProps {
  children: string | React.ReactNode;
}

export default function MathLine({ children }: MathLineProps) {
  // Extrai o texto do conteúdo
  const extractText = (node: any): string => {
    if (typeof node === 'string') return node;
    if (Array.isArray(node)) return node.map(extractText).join('');
    if (React.isValidElement(node)) return extractText(node.props.children);
    return String(node || '');
  };

  const mathContent = useMemo(() => {
    const value = extractText(children).trim();
    
    try {
      // Renderiza para HTML string
      const html = katex.renderToString(value, {
        displayMode: false,
        throwOnError: false,
        errorColor: '#ef4444',
        trust: true,
        strict: false,
      });
      
      return { html, error: null };
    } catch (err) {
      console.error('[MathLine] Erro ao renderizar:', err);
      return {
        html: `<span style="color: #ef4444;">Erro: ${value}</span>`,
        error: err instanceof Error ? err.message : 'Erro desconhecido'
      };
    }
  }, [children]);

  return (
    <span 
      className="inline-block px-2 py-1 mx-1 bg-gray-800/60 backdrop-blur-sm rounded-md border border-gray-700/40 shadow-lg hover:shadow-xl transition-all duration-200"
      style={{
        textShadow: '0 2px 8px rgba(0, 0, 0, 0.6), 0 1px 4px rgba(0, 0, 0, 0.4)',
        boxShadow: '0 4px 12px rgba(0, 0, 0, 0.3), 0 2px 6px rgba(0, 0, 0, 0.2), inset 0 1px 2px rgba(255, 255, 255, 0.1)'
      }}
    >
      <span
        className="katex-inline-wrapper"
        dangerouslySetInnerHTML={{ __html: mathContent.html }}
        style={{
          color: '#e5e7eb',
          filter: 'drop-shadow(0 2px 4px rgba(0, 0, 0, 0.5))'
        }}
      />
    </span>
  );
}