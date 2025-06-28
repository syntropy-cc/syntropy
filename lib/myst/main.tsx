import { mystParse } from 'myst-parser';
import React from 'react';
import CodeBlock from '@/components/myst/code/code';
import Note from '@/components/myst/admonitions/note';
import Tip from '@/components/myst/admonitions/tip';
import Warning from '@/components/myst/admonitions/warning';

// Componentes de admonition básicos (implementação funcional)
const AdmonitionBase: React.FC<{ type: string; title?: string; children: React.ReactNode }> = ({ 
  type, 
  title, 
  children 
}) => {
  const typeConfig = {
    note: { 
      icon: '📝', 
      bg: 'bg-blue-50 dark:bg-blue-950/30', 
      border: 'border-l-blue-500',
      title: 'Nota'
    },
    tip: { 
      icon: '💡', 
      bg: 'bg-green-50 dark:bg-green-950/30', 
      border: 'border-l-green-500',
      title: 'Dica'
    },
    warning: { 
      icon: '⚠️', 
      bg: 'bg-yellow-50 dark:bg-yellow-950/30', 
      border: 'border-l-yellow-500',
      title: 'Aviso'
    },
    important: { 
      icon: '❗', 
      bg: 'bg-red-50 dark:bg-red-950/30', 
      border: 'border-l-red-500',
      title: 'Importante'
    },
    caution: { 
      icon: '🔺', 
      bg: 'bg-orange-50 dark:bg-orange-950/30', 
      border: 'border-l-orange-500',
      title: 'Cuidado'
    },
    attention: { 
      icon: '🔔', 
      bg: 'bg-purple-50 dark:bg-purple-950/30', 
      border: 'border-l-purple-500',
      title: 'Atenção'
    },
  };

  const config = typeConfig[type as keyof typeof typeConfig] || typeConfig.note;
  
  return (
    <div className={`my-6 rounded-lg p-4 shadow-sm border-l-4 ${config.bg} ${config.border}`}>
      <div className="flex items-center gap-2 font-semibold mb-2 text-sm">
        <span>{config.icon}</span>
        <span className="uppercase tracking-wide">{title || config.title}</span>
      </div>
      <div className="text-sm leading-relaxed">{children}</div>
    </div>
  );
};

// Mapear diretivas para componentes
const DIRECTIVE_COMPONENTS: Record<string, React.FC<any>> = {
  code: CodeBlock,
  'code-block': CodeBlock,
  note: (props: any) => <AdmonitionBase type="note" {...props} />,
  tip: (props: any) => <AdmonitionBase type="tip" {...props} />,
  warning: (props: any) => <AdmonitionBase type="warning" {...props} />,
  important: (props: any) => <AdmonitionBase type="important" {...props} />,
  caution: (props: any) => <AdmonitionBase type="caution" {...props} />,
  attention: (props: any) => <AdmonitionBase type="attention" {...props} />,
  admonition: (props: any) => <AdmonitionBase type="note" {...props} />,
};

function renderNode(node: any, index: number = 0): React.ReactNode {
  if (!node) return null;

  const key = `node-${index}-${node.type || 'unknown'}`;

  // Diretivas (admonitions, code, etc)
  if (node.type === 'directive') {
    const name = node.name?.toLowerCase();
    
    // Bloco de código
    if (name === 'code' || name === 'code-block') {
      const language = node.argument || node.lang || 'text';
      const code = node.value || node.body || '';
      
      return (
        <CodeBlock 
          key={key}
          language={language} 
          children={code}
          copyable={true}
        />
      );
    }
    
    // Admonitions
    const Comp = DIRECTIVE_COMPONENTS[name];
    if (Comp) {
      return (
        <Comp key={key} title={node.argument}>
          {node.children?.map((child: any, i: number) => renderNode(child, i))}
        </Comp>
      );
    }
    
    // Fallback para diretiva desconhecida
    return (
      <AdmonitionBase key={key} type="note" title={name}>
        {node.children?.map((child: any, i: number) => renderNode(child, i))}
      </AdmonitionBase>
    );
  }

  // Blocos de código com fence (```)
  if (node.type === 'code') {
    return (
      <CodeBlock 
        key={key}
        language={node.lang || node.meta || 'text'} 
        children={node.value}
        copyable={true}
      />
    );
  }

  // Tabelas
  if (node.type === 'table') {
    return (
      <div key={key} className="overflow-x-auto my-6">
        <table className="min-w-full border border-gray-200 dark:border-gray-700 text-sm">
          <tbody>{node.children?.map((child: any, i: number) => renderNode(child, i))}</tbody>
        </table>
      </div>
    );
  }
  
  if (node.type === 'tableRow') {
    return (
      <tr key={key} className="border-b border-gray-200 dark:border-gray-700">
        {node.children?.map((child: any, i: number) => renderNode(child, i))}
      </tr>
    );
  }
  
  if (node.type === 'tableCell') {
    return (
      <td key={key} className="border px-3 py-2 border-gray-200 dark:border-gray-700">
        {node.children?.map((child: any, i: number) => renderNode(child, i))}
      </td>
    );
  }

  // Listas
  if (node.type === 'list') {
    const Component = node.ordered ? 'ol' : 'ul';
    const className = node.ordered 
      ? "list-decimal ml-6 my-4 space-y-1" 
      : "list-disc ml-6 my-4 space-y-1";
    
    return React.createElement(
      Component,
      { key, className },
      node.children?.map((child: any, i: number) => renderNode(child, i))
    );
  }
  
  if (node.type === 'listItem') {
    return (
      <li key={key} className="leading-relaxed">
        {node.children?.map((child: any, i: number) => renderNode(child, i))}
      </li>
    );
  }

  // Códigos inline
  if (node.type === 'inlineCode') {
    return (
      <code key={key} className="bg-gray-100 dark:bg-gray-800 px-1.5 py-0.5 rounded text-sm font-mono">
        {node.value}
      </code>
    );
  }

  // Math (bloco)
  if (node.type === 'math') {
    return (
      <div key={key} className="my-6 p-4 bg-gray-50 dark:bg-gray-900 rounded-lg text-center">
        <span className="font-mono text-lg">{node.value}</span>
      </div>
    );
  }
  
  // Math (inline)
  if (node.type === 'inlineMath') {
    return (
      <span key={key} className="font-mono bg-gray-100 dark:bg-gray-800 px-1 py-0.5 rounded">
        {node.value}
      </span>
    );
  }

  // Headings
  if (node.type === 'heading') {
    const headingClasses = {
      1: 'text-3xl font-bold mt-8 mb-4',
      2: 'text-2xl font-bold mt-6 mb-3',
      3: 'text-xl font-semibold mt-5 mb-2',
      4: 'text-lg font-semibold mt-4 mb-2',
      5: 'text-base font-semibold mt-3 mb-2',
      6: 'text-sm font-semibold mt-2 mb-1',
    };
    
    const Tag = `h${Math.min(node.depth || 1, 6)}` as keyof JSX.IntrinsicElements;
    const className = headingClasses[node.depth as keyof typeof headingClasses] || headingClasses[1];
    
    return React.createElement(
      Tag,
      { key, className: `${className} text-gray-900 dark:text-gray-100` },
      node.children?.map((child: any, i: number) => renderNode(child, i))
    );
  }

  // Parágrafo
  if (node.type === 'paragraph') {
    return (
      <p key={key} className="mb-4 leading-relaxed text-gray-700 dark:text-gray-300">
        {node.children?.map((child: any, i: number) => renderNode(child, i))}
      </p>
    );
  }

  // Blockquote
  if (node.type === 'blockquote') {
    return (
      <blockquote key={key} className="border-l-4 border-blue-400 pl-4 italic my-4 text-blue-700 dark:text-blue-300 bg-blue-50 dark:bg-blue-950/30 py-2 rounded-r">
        {node.children?.map((child: any, i: number) => renderNode(child, i))}
      </blockquote>
    );
  }

  // Links
  if (node.type === 'link') {
    return (
      <a 
        key={key}
        href={node.url} 
        className="text-blue-600 dark:text-blue-400 underline hover:text-blue-800 dark:hover:text-blue-300 transition-colors"
        target={node.url?.startsWith('http') ? '_blank' : undefined}
        rel={node.url?.startsWith('http') ? 'noopener noreferrer' : undefined}
      >
        {node.children?.map((child: any, i: number) => renderNode(child, i))}
      </a>
    );
  }

  // Imagens
  if (node.type === 'image') {
    return (
      <img 
        key={key}
        src={node.url} 
        alt={node.alt || ''} 
        className="my-6 rounded-lg shadow-md max-w-full h-auto mx-auto" 
      />
    );
  }

  // Texto simples
  if (node.type === 'text') {
    return node.value;
  }

  // Strong (negrito)
  if (node.type === 'strong') {
    return (
      <strong key={key} className="font-bold">
        {node.children?.map((child: any, i: number) => renderNode(child, i))}
      </strong>
    );
  }

  // Emphasis (itálico)
  if (node.type === 'emphasis') {
    return (
      <em key={key} className="italic">
        {node.children?.map((child: any, i: number) => renderNode(child, i))}
      </em>
    );
  }

  // Break (quebra de linha)
  if (node.type === 'break') {
    return <br key={key} />;
  }

  // Thematic break (linha horizontal)
  if (node.type === 'thematicBreak') {
    return <hr key={key} className="my-8 border-gray-300 dark:border-gray-600" />;
  }

  // Recursão para nós com children
  if (Array.isArray(node.children)) {
    return node.children.map((child: any, i: number) => renderNode(child, i));
  }

  // Fallback para tipos desconhecidos
  console.warn('Tipo de nó MyST não reconhecido:', node.type, node);
  return null;
}

export type MystRendererProps = {
  content: string;
  theme?: string;
  className?: string;
};

export const MystRenderer: React.FC<MystRendererProps> = ({ 
  content, 
  theme = "syntropy-dark", 
  className = "" 
}) => {
  try {
    const tree = mystParse(content);
    console.log('Árvore MyST parseada:', tree); // Debug
    
    return (
      <div 
        className={`prose prose-lg prose-slate dark:prose-invert max-w-none ${className}`} 
        data-theme={theme}
      >
        {Array.isArray(tree.children) 
          ? tree.children.map((child: any, i: number) => renderNode(child, i))
          : renderNode(tree)
        }
      </div>
    );
  } catch (error) {
    console.error('Erro ao parsear conteúdo MyST:', error);
    return (
      <div className="bg-red-50 dark:bg-red-950/30 border border-red-200 dark:border-red-800 rounded-lg p-4">
        <h3 className="text-red-800 dark:text-red-200 font-semibold mb-2">Erro ao renderizar conteúdo</h3>
        <p className="text-red-600 dark:text-red-400 text-sm">
          Não foi possível processar o conteúdo MyST. Verifique a sintaxe do arquivo.
        </p>
        <details className="mt-2">
          <summary className="text-red-700 dark:text-red-300 cursor-pointer text-xs">Ver detalhes do erro</summary>
          <pre className="text-xs mt-2 bg-red-100 dark:bg-red-900/50 p-2 rounded overflow-auto">
            {error instanceof Error ? error.message : String(error)}
          </pre>
        </details>
      </div>
    );
  }
};