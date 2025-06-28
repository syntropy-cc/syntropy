import React from "react";

const MathLine: React.FC<{ children: React.ReactNode }> = ({ children }) => (
  <span
    className="inline-block bg-[#23272e] dark:bg-[#1e293b] text-[#f8fafc] font-mono text-base px-2 py-0.5 rounded-md border border-[#334155] shadow-sm align-baseline mx-1 select-all"
    tabIndex={0}
    aria-label="Equação inline"
  >
    {children}
  </span>
);

export default MathLine; 