import React, { useEffect, useRef, useState } from 'react';
import katex from 'katex';
import 'katex/dist/katex.min.css';

interface MathLineProps {
  value: string;
}

export default function MathLine({ value }: MathLineProps) {
  const mathRef = useRef<HTMLSpanElement>(null);
  const [error, setError] = useState<string | null>(null);
  const [isLoaded, setIsLoaded] = useState(false);

  useEffect(() => {
    if (!mathRef.current || !value) return;

    try {
      // Limpa o conteúdo anterior
      mathRef.current.innerHTML = '';
      
      // Renderiza a equação com KaTeX
      katex.render(value, mathRef.current, {
        displayMode: false,
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
      setError(err instanceof Error ? err.message : 'Erro');
      setIsLoaded(true);
    }
  }, [value]);

  if (error) {
    return (
      <span className="inline-flex items-center px-2 py-0.5 mx-1 text-xs bg-red-900/30 text-red-400 rounded-md font-mono border border-red-800/30">
        <svg className="w-3 h-3 mr-1" fill="currentColor" viewBox="0 0 20 20">
          <path fillRule="evenodd" d="M18 10a8 8 0 11-16 0 8 8 0 0116 0zm-7 4a1 1 0 11-2 0 1 1 0 012 0zm-1-9a1 1 0 00-1 1v4a1 1 0 102 0V6a1 1 0 00-1-1z" clipRule="evenodd" />
        </svg>
        {value}
      </span>
    );
  }

  return (
    <span className="relative inline-flex items-baseline group">
      {/* Highlight de fundo ao passar o mouse */}
      <span className="absolute inset-0 -mx-1 -my-0.5 bg-blue-500/10 rounded-md opacity-0 group-hover:opacity-100 transition-opacity duration-200" />
      
      {/* Container da equação */}
      <span className="relative inline-flex items-baseline">
        <span 
          ref={mathRef}
          className={`inline-block mx-1 transition-all duration-200 ${
            isLoaded ? 'opacity-100' : 'opacity-0'
          }`}
          style={{
            color: '#93c5fd', // blue-300
            fontSize: 'inherit',
          }}
        />
        
        {/* Indicador de carregamento inline */}
        {!isLoaded && !error && (
          <span className="inline-block w-12 h-4 mx-1 bg-gray-700/50 rounded animate-pulse" />
        )}
      </span>
      
      {/* Tooltip com a equação LaTeX ao passar o mouse */}
      <span className="absolute bottom-full left-1/2 -translate-x-1/2 mb-2 px-2 py-1 text-xs bg-gray-900 text-gray-300 rounded-md whitespace-nowrap opacity-0 group-hover:opacity-100 transition-opacity duration-200 pointer-events-none font-mono">
        ${value}$
        <span className="absolute top-full left-1/2 -translate-x-1/2 -mt-1 w-2 h-2 bg-gray-900 rotate-45" />
      </span>
    </span>
  );
}