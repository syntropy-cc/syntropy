import React, { useEffect, useRef, useState } from 'react';
import katex from 'katex';
import 'katex/dist/katex.min.css';

interface MathBlockProps {
  value: string;
  label?: string;
}

export default function MathBlock({ value, label }: MathBlockProps) {
  const mathRef = useRef<HTMLDivElement>(null);
  const [error, setError] = useState<string | null>(null);
  const [isLoaded, setIsLoaded] = useState(false);

  useEffect(() => {
    if (!mathRef.current || !value) return;

    try {
      // Limpa o conteúdo anterior
      mathRef.current.innerHTML = '';
      
      // Renderiza a equação com KaTeX
      katex.render(value, mathRef.current, {
        displayMode: true,
        throwOnError: false,
        errorColor: '#ef4444',
        trust: true,
        strict: false,
        macros: {
          "\\RR": "\\mathbb{R}",
          "\\NN": "\\mathbb{N}",
          "\\ZZ": "\\mathbb{Z}",
          "\\QQ": "\\mathbb{Q}",
          "\\CC": "\\mathbb{C}",
        }
      });
      
      setError(null);
      setIsLoaded(true);
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Erro ao renderizar equação');
      setIsLoaded(true);
    }
  }, [value]);

  return (
    <div className="my-8 relative group">
      <div className="bg-gray-800/50 backdrop-blur-sm rounded-xl border border-gray-700/50 p-6 shadow-xl hover:shadow-2xl transition-all duration-300">
        {/* Header com label */}
        {label && (
          <div className="flex items-center justify-between mb-4">
            <span className="text-sm font-medium text-blue-400/80">
              Equação {label}
            </span>
            <button
              onClick={() => {
                navigator.clipboard.writeText(value);
              }}
              className="opacity-0 group-hover:opacity-100 transition-opacity duration-200 text-gray-400 hover:text-white p-1.5 rounded-lg hover:bg-gray-700/50"
              title="Copiar equação"
            >
              <svg className="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M8 16H6a2 2 0 01-2-2V6a2 2 0 012-2h8a2 2 0 012 2v2m-6 12h8a2 2 0 002-2v-8a2 2 0 00-2-2h-8a2 2 0 00-2 2v8a2 2 0 002 2z" />
              </svg>
            </button>
          </div>
        )}
        
        {/* Área da equação */}
        <div className="relative overflow-x-auto">
          <div className="min-h-[3rem] flex items-center justify-center">
            {error ? (
              <div className="text-red-400 text-sm font-mono">
                <span className="block text-xs text-red-300 mb-1">Erro na equação:</span>
                {error}
              </div>
            ) : (
              <div 
                ref={mathRef}
                className={`text-white text-lg transition-opacity duration-300 ${
                  isLoaded ? 'opacity-100' : 'opacity-0'
                }`}
                style={{
                  fontSize: '1.125rem',
                  color: '#e5e7eb',
                }}
              />
            )}
          </div>
        </div>
        
        {/* Indicador de carregamento */}
        {!isLoaded && !error && (
          <div className="absolute inset-0 flex items-center justify-center bg-gray-800/50 backdrop-blur-sm rounded-xl">
            <div className="w-6 h-6 border-2 border-blue-400 border-t-transparent rounded-full animate-spin" />
          </div>
        )}
      </div>
      
      {/* Linha decorativa à esquerda */}
      <div className="absolute left-0 top-0 bottom-0 w-1 bg-gradient-to-b from-blue-500/50 via-purple-500/50 to-pink-500/50 rounded-full opacity-0 group-hover:opacity-100 transition-opacity duration-300" />
    </div>
  );
}