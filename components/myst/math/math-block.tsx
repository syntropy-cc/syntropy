import React, { useRef, useEffect } from "react";
import 'katex/dist/katex.min.css';
import { BlockMath } from 'react-katex';

interface MathBlockProps {
  label?: string;
  children: React.ReactNode;
}

// Índice global de equações (resetado a cada montagem do componente root)
let equationCounter = 0;

// Função utilitária para extrair LaTeX puro dos children
function extractLatex(children: React.ReactNode): string {
  if (typeof children === 'string') return children.trim();
  if (Array.isArray(children)) return children.map(extractLatex).join(' ').trim();
  if (typeof children === 'object' && children && 'props' in children) {
    // @ts-ignore
    return extractLatex(children.props.children);
  }
  return '';
}

const MathBlock: React.FC<MathBlockProps> = ({ label, children }) => {
  const eqIndex = useRef<number>(0);
  useEffect(() => {
    equationCounter += 1;
    eqIndex.current = equationCounter;
    return () => {};
  }, []);

  return (
    <div className="my-10 flex flex-col items-center not-prose">
      <div className="relative bg-slate-900/95 dark:bg-slate-800/90 border border-slate-700 rounded-xl px-8 py-7 shadow-2xl w-full max-w-2xl mx-auto flex flex-col items-center">
        {label && (
          <div className="mb-3 text-base font-semibold text-pink-400 text-center tracking-wide select-none">
            {label}
          </div>
        )}
        <div className="w-full flex items-center justify-center">
          <span className="text-center text-2xl font-mono text-slate-100 select-all block">
            <BlockMath>{extractLatex(children)}</BlockMath>
          </span>
          <span className="ml-4 text-slate-400 text-base font-mono select-none" aria-label="Índice da equação">
            {`(${eqIndex.current})`}
          </span>
        </div>
      </div>
    </div>
  );
};

export default MathBlock; 