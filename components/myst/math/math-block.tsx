import React, { useMemo, useRef, useEffect } from 'react';
import katex from 'katex';
import 'katex/dist/katex.min.css';

interface MathBlockProps {
  children: string | React.ReactNode;
  label?: string; // Label será passado pelo parser MDX/MyST
  equationNumber?: number; // Número da equação para indexação (opcional)
}

// Context para controlar a numeração global das equações
let globalEquationCounter = 0;

export default function MathBlock({ children, label, equationNumber }: MathBlockProps) {
  // Ref para garantir que o número seja atribuído apenas uma vez
  const equationNumberRef = useRef<number | null>(null);
  
  // Atribui o número da equação apenas uma vez na primeira renderização
  if (equationNumberRef.current === null) {
    if (equationNumber !== undefined) {
      equationNumberRef.current = equationNumber;
    } else {
      equationNumberRef.current = ++globalEquationCounter;
    }
    console.log('[DEBUG] Atribuindo número da equação:', equationNumberRef.current, 'para label:', label);
  }

  // Extrai o texto do conteúdo
  const extractText = (node: any): string => {
    if (typeof node === 'string') return node;
    if (Array.isArray(node)) return node.map(extractText).join('');
    if (React.isValidElement(node)) return extractText(node.props.children);
    return String(node || '');
  };

  // Processa o conteúdo 
  const mathEquation = useMemo(() => {
    return extractText(children).trim();
  }, [children]);

  const mathContent = useMemo(() => {
    try {
      // Renderiza para HTML string
      const html = katex.renderToString(mathEquation, {
        displayMode: true,
        throwOnError: false,
        errorColor: '#ef4444',
        trust: true,
        strict: false,
      });
     
      return { html, error: null };
    } catch (err) {
      console.error('[MathBlock] Erro ao renderizar:', err);
      return {
        html: `<span style="color: #ef4444;">Erro: ${mathEquation}</span>`,
        error: err instanceof Error ? err.message : 'Erro desconhecido'
      };
    }
  }, [mathEquation]);

  return (
    <div className="my-8 relative group">
      <div className="bg-gray-800/50 backdrop-blur-sm rounded-xl border border-gray-700/50 p-6 shadow-xl hover:shadow-2xl transition-all duration-300">
        {/* Faixa do título - só aparece se houver label */}
        {label && (
          <div className="mb-4 -mx-6 -mt-6 px-6 py-3 bg-gradient-to-r from-blue-600/20 via-purple-600/20 to-blue-600/20 border-b border-gray-700/50 rounded-t-xl">
            <h3 className="text-lg font-semibold text-blue-200">
              {label}
            </h3>
          </div>
        )}

        {/* Botão de copiar */}
        <div className={`absolute ${label ? 'top-3' : 'top-6'} right-3`}>
          <button
            onClick={() => {
              navigator.clipboard.writeText(mathEquation);
            }}
            className="opacity-0 group-hover:opacity-100 transition-opacity duration-200 text-gray-400 hover:text-white p-1.5 rounded-lg hover:bg-gray-700/50"
            title="Copiar equação"
          >
            <svg className="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M8 16H6a2 2 0 01-2-2V6a2 2 0 012-2h8a2 2 0 012 2v2m-6 12h8a2 2 0 002-2v-8a2 2 0 00-2-2h-8a2 2 0 00-2 2v8a2 2 0 002 2z" />
            </svg>
          </button>
        </div>
       
        {/* Área da equação */}
        <div className="relative overflow-x-auto">
          <div className="min-h-[3rem] flex items-center justify-between py-2">
            {/* Equação centralizada */}
            <div className="flex-1 flex justify-center">
              <div
                className="katex-display-wrapper"
                dangerouslySetInnerHTML={{ __html: mathContent.html }}
                style={{
                  fontSize: '1.5rem',
                  color: '#e5e7eb',
                }}
              />
            </div>
            {/* Número da equação à direita */}
            <div className="ml-4 text-gray-400 font-mono text-sm">
              ({equationNumberRef.current})
            </div>
          </div>
        </div>
      </div>
     
      {/* Linha decorativa à esquerda */}
      <div className="absolute left-0 top-0 bottom-0 w-1 bg-gradient-to-b from-blue-500/50 via-purple-500/50 to-pink-500/50 rounded-full opacity-0 group-hover:opacity-100 transition-opacity duration-300" />
    </div>
  );
}

// Função para resetar o contador (útil quando começar um novo documento)
export const resetEquationCounter = () => {
  globalEquationCounter = 0;
};