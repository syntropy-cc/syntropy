import React from "react";

interface CodeLineProps {
  children: React.ReactNode;
  className?: string;
}

const CodeLine: React.FC<CodeLineProps> = ({ children, className = "" }) => (
  <code
    className={`inline-block bg-[#23272e] dark:bg-[#1e293b] text-[#f8fafc] font-mono text-xs px-2 py-0.5 rounded-md border border-[#334155] shadow-sm align-baseline ${className}`}
    tabIndex={0}
    aria-label="Código inline"
  >
    {children}
  </code>
);

export default CodeLine; 