import React from "react";

const Attention: React.FC<{ title?: string; children: React.ReactNode }> = ({ title = "Atenção", children }) => (
  <aside
    className="admonition-attention relative my-6 rounded-xl bg-purple-50/80 dark:bg-purple-950/40 border-l-4 border-purple-500 shadow-xl overflow-x-auto backdrop-blur-md transition-all duration-200 ease-in-out px-6 pt-5 pb-4"
    role="alert"
    aria-label="Atenção"
    tabIndex={0}
  >
    <div className="flex items-center gap-2 mb-2">
      <span className="text-purple-500 text-lg" aria-hidden>🔔</span>
      <span className="font-semibold uppercase tracking-wide text-purple-700 dark:text-purple-200 text-sm">{title}</span>
    </div>
    <div className="not-prose text-purple-900 dark:text-purple-100 text-sm leading-relaxed">{children}</div>
  </aside>
);

export default Attention; 