import React, { useRef, useState, useMemo } from "react";
import Prism from "prismjs";
import "prismjs/components/prism-python";
import "prismjs/components/prism-javascript";
import "prismjs/components/prism-typescript";
import "prismjs/components/prism-bash";
import "prismjs/components/prism-sql";
import "prismjs/components/prism-r";
import "prismjs/components/prism-yaml";
import "prismjs/components/prism-json";
import "prismjs/components/prism-markup";
import "prismjs/components/prism-css";
import { Copy, Check } from "lucide-react";
import "prismjs/themes/prism-tomorrow.css";
import "./prism-syntropy.css";

const LANG_LABELS: Record<string, string> = {
  python: "Python",
  javascript: "JavaScript",
  typescript: "TypeScript",
  bash: "Bash",
  shell: "Shell",
  sql: "SQL",
  r: "R",
  yaml: "YAML",
  json: "JSON",
  html: "HTML",
  css: "CSS",
  markdown: "Markdown",
  text: "Texto",
};

const LANGUAGE_COLORS: Record<string, string> = {
  python: "#3776ab",
  javascript: "#f7df1e",
  typescript: "#3178c6",
  bash: "#4eaa25",
  shell: "#4eaa25",
  sql: "#336791",
  css: "#1572b6",
  html: "#e34f26",
  json: "#000000",
  yaml: "#cb171e",
  r: "#276dc3",
};

interface CodeBlockProps {
  children?: string;
  mystDirective?: string;
  language?: string;
  showLineNumbers?: boolean;
  title?: string;
  copyable?: boolean;
  className?: string;
}

function parseMystCodeBlock(content: string) {
  const regex = /:::\s*\{?code-block\}?\s*(\w+)?\s*\n([\s\S]*?):::/i;
  const match = content.match(regex);
  return {
    language: match?.[1]?.toLowerCase() || "text",
    code: match?.[2]?.trim() || content,
  };
}

const CodeBlock: React.FC<CodeBlockProps> = ({
  children,
  mystDirective,
  language: propLanguage,
  showLineNumbers = false,
  title,
  copyable = true,
  className = "",
}) => {
  const { code, language } = useMemo(() => {
    if (mystDirective) return parseMystCodeBlock(mystDirective);
    return {
      code: children || "",
      language: propLanguage || "text",
    };
  }, [mystDirective, children, propLanguage]);

  const [copied, setCopied] = useState(false);
  const codeRef = useRef<HTMLPreElement>(null);
  const lines = typeof code === 'string' ? code.split("\n") : [];

  const html = useMemo(
    () => Prism.highlight(code, Prism.languages[language] || Prism.languages.text, language),
    [code, language]
  );

  const handleCopy = () => {
    if (!copyable) return;
    navigator.clipboard.writeText(code);
    setCopied(true);
    setTimeout(() => setCopied(false), 2000);
  };

  return (
    <div
      className={`code-container relative my-6 rounded-xl bg-[#1e293b]/95 border border-[#334155] shadow-xl overflow-x-auto backdrop-blur-md transition-all duration-200 ease-in-out hover:scale-[1.01] ${className}`}
      tabIndex={0}
      aria-label={`Bloco de código em ${LANG_LABELS[language] || language}`}
    >
      {title && (
        <div className="px-6 pt-5 pb-1 text-[15px] font-semibold text-[var(--text-primary)] opacity-80">
          {title}
        </div>
      )}
      <div className="flex items-center justify-between px-6 pt-5 pb-1">
        <span
          className="z-10 px-3 py-1 rounded-full text-xs font-medium text-white bg-gradient-to-r from-indigo-500 to-pink-500 shadow-md select-none border border-white/10"
          style={{
            background: LANGUAGE_COLORS[language]
              ? `linear-gradient(90deg, ${LANGUAGE_COLORS[language]}, #ec4899)`
              : undefined,
          }}
          aria-label={`Linguagem: ${LANG_LABELS[language] || language}`}
        >
          {LANG_LABELS[language] || language}
        </span>
        {copyable && (
          <button
            className="p-2 rounded-full bg-white/10 hover:bg-white/20 transition-all duration-200 focus:outline-none focus:ring-2 focus:ring-indigo-400"
            onClick={handleCopy}
            aria-label="Copiar código"
            type="button"
          >
            {copied ? <Check className="w-4 h-4 text-green-400" /> : <Copy className="w-4 h-4 text-white" />}
          </button>
        )}
      </div>
      <pre
        ref={codeRef}
        className="code-content scrollbar-thin scrollbar-thumb-[#334155] scrollbar-track-transparent text-sm font-mono px-6 pt-4 pb-6 min-h-[56px]"
        tabIndex={0}
        aria-label="Código fonte"
      >
        <code className={`language-${language} whitespace-pre`} dangerouslySetInnerHTML={{ __html: html }} />
      </pre>
    </div>
  );
};

export default CodeBlock; 