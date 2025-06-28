// lib/myst.tsx (note a extensão .tsx)
import { mystParse } from 'myst-parser'
import React from 'react'

// Estilos inspirados no Jupyter Book, adaptados para Tailwind/projeto
const DIRECTIVE_STYLES: Record<string, string> = {
  note: 'border-l-4 border-blue-400 bg-blue-50 text-blue-900',
  warning: 'border-l-4 border-yellow-400 bg-yellow-50 text-yellow-900',
  tip: 'border-l-4 border-green-400 bg-green-50 text-green-900',
  important: 'border-l-4 border-purple-400 bg-purple-50 text-purple-900',
  caution: 'border-l-4 border-orange-400 bg-orange-50 text-orange-900',
  attention: 'border-l-4 border-red-400 bg-red-50 text-red-900',
  admonition: 'border-l-4 border-gray-400 bg-gray-50 text-gray-900',
}

const DIRECTIVE_LABELS: Record<string, string> = {
  note: 'Nota',
  warning: 'Aviso',
  tip: 'Dica',
  important: 'Importante',
  caution: 'Cuidado',
  attention: 'Atenção',
  admonition: 'Admonição',
}

function renderNode(node: any): React.ReactNode {
  if (!node) return null;

  // Diretivas (admonitions)
  if (node.type === 'directive') {
    const style = DIRECTIVE_STYLES[node.name] || DIRECTIVE_STYLES['admonition'];
    const label = node.label || DIRECTIVE_LABELS[node.name] || node.name;
    return (
      <div className={`my-6 rounded-md p-4 shadow-sm ${style}`}>
        <div className="font-bold mb-2 uppercase tracking-wide text-xs opacity-80">{label}</div>
        <div>{node.children?.map(renderNode)}</div>
      </div>
    );
  }

  // Tabelas
  if (node.type === 'table') {
    return (
      <div className="overflow-x-auto my-4">
        <table className="min-w-full border text-sm">
          <tbody>{node.children?.map(renderNode)}</tbody>
        </table>
      </div>
    );
  }
  if (node.type === 'tableRow') {
    return <tr>{node.children?.map(renderNode)}</tr>;
  }
  if (node.type === 'tableCell') {
    return <td className="border px-2 py-1">{node.children?.map(renderNode)}</td>;
  }

  // Listas
  if (node.type === 'list') {
    return node.ordered ? (
      <ol className="list-decimal ml-6 my-2">{node.children?.map(renderNode)}</ol>
    ) : (
      <ul className="list-disc ml-6 my-2">{node.children?.map(renderNode)}</ul>
    );
  }
  if (node.type === 'listItem') {
    return <li>{node.children?.map(renderNode)}</li>;
  }

  // Códigos
  if (node.type === 'code') {
    return (
      <pre className="bg-slate-900 text-white rounded p-3 my-4 overflow-x-auto text-xs">
        <code>{node.value}</code>
      </pre>
    );
  }
  if (node.type === 'inlineCode') {
    return <code className="bg-slate-200 px-1 rounded text-xs">{node.value}</code>;
  }

  // Math (bloco)
  if (node.type === 'math') {
    // Aqui você pode integrar com KaTeX/MathJax se quiser
    return (
      <div className="my-4">
        <span className="font-mono bg-slate-100 px-2 py-1 rounded">{node.value}</span>
      </div>
    );
  }
  // Math (inline)
  if (node.type === 'inlineMath') {
    return <span className="font-mono bg-slate-100 px-1 rounded">{node.value}</span>;
  }

  // Headings (corrigido: React.createElement, sem spread)
  if (node.type === 'heading') {
    const Tag = `h${node.depth}` as keyof JSX.IntrinsicElements;
    return React.createElement(
      Tag,
      { className: 'font-bold mt-6 mb-2 text-slate-100' },
      node.children?.map(renderNode)
    );
  }

  // Parágrafo
  if (node.type === 'paragraph') {
    return <p className="mb-4 leading-relaxed">{node.children?.map(renderNode)}</p>;
  }

  // Blockquote
  if (node.type === 'blockquote') {
    return <blockquote className="border-l-4 border-blue-400 pl-4 italic my-4 text-blue-200">{node.children?.map(renderNode)}</blockquote>;
  }

  // Links
  if (node.type === 'link') {
    return <a href={node.url} className="text-blue-400 underline hover:text-blue-300">{node.children?.map(renderNode)}</a>;
  }

  // Imagens
  if (node.type === 'image') {
    return <img src={node.url} alt={node.alt} className="my-4 rounded shadow max-w-full" />;
  }

  // Texto
  if (node.type === 'text') {
    return node.value;
  }

  // Recursão para outros tipos
  if (Array.isArray(node.children)) {
    return node.children.map(renderNode);
  }

  // Fallback
  return null;
}

export function mystToReactFragment(src: string) {
  const tree = mystParse(src)              // MyST → MDAST
  return <>{renderNode(tree)}</>;
}