import { mystParse } from 'myst-parser';
import React from 'react';
import CodeBlock from '@/components/myst/code/code';
import Note from '@/components/myst/admonitions/note';
import Tip from '@/components/myst/admonitions/tip';
import Warning from '@/components/myst/admonitions/warning';

// Mapear diretivas para componentes
const DIRECTIVE_COMPONENTS: Record<string, React.FC<any>> = {
  code: CodeBlock,
  'code-block': CodeBlock,
  note: Note,
  tip: Tip,
  warning: Warning,
};

const DIRECTIVE_LABELS: Record<string, string> = {
  note: 'Nota',
  warning: 'Aviso',
  tip: 'Dica',
  important: 'Importante',
  caution: 'Cuidado',
  attention: 'Atenção',
  admonition: 'Admonição',
};

function renderNode(node: any): React.ReactNode {
  if (!node) return null;

  // Diretivas (admonitions, code, etc)
  if (node.type === 'directive') {
    const name = node.name?.toLowerCase();
    // Bloco de código
    if (name === 'code' || name === 'code-block') {
      // node.argument pode ser a linguagem
      const language = node.argument || 'text';
      const code = node.value || (node.children && node.children[0]?.value) || '';
      return (
        <CodeBlock language={language} mystDirective={`:::{code-block} ${language}\n${code}\n:::`} />
      );
    }
    // Admonitions
    const Comp = DIRECTIVE_COMPONENTS[name];
    if (Comp) {
      return <Comp>{node.children?.map(renderNode)}</Comp>;
    }
    // Fallback para diretiva desconhecida
    return (
      <div className="my-6 rounded-md p-4 shadow-sm border-l-4 border-gray-400 bg-gray-50 text-gray-900">
        <div className="font-bold mb-2 uppercase tracking-wide text-xs opacity-80">{DIRECTIVE_LABELS[name] || name}</div>
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

  // Códigos inline
  if (node.type === 'inlineCode') {
    return <code className="bg-slate-200 px-1 rounded text-xs">{node.value}</code>;
  }

  // Math (bloco)
  if (node.type === 'math') {
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

  // Headings
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

export type MystRendererProps = {
  content: string;
  theme?: string;
  className?: string;
};

export const MystRenderer: React.FC<MystRendererProps> = ({ content, theme = "syntropy-dark", className = "" }) => {
  const tree = mystParse(content);
  return (
    <div className={`prose prose-slate dark:prose-invert max-w-none ${className}`} data-theme={theme}>
      {renderNode(tree)}
    </div>
  );
}; 