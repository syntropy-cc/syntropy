import React from "react";

const Tip: React.FC<{ title?: string; children: React.ReactNode }> = ({ title = "Dica", children }) => (
  <aside
    className="admonition-tip relative my-6 rounded-xl bg-green-50/80 dark:bg-green-950/40 border-l-4 border-green-500 shadow-xl overflow-x-auto backdrop-blur-md transition-all duration-200 ease-in-out px-6 pt-5 pb-4"
    role="note"
    aria-label="Dica"
    tabIndex={0}
  >
    <div className="flex items-center gap-2 mb-2">
      <span className="text-green-500 text-lg" aria-hidden>💡</span>
      <span className="font-semibold uppercase tracking-wide text-green-700 dark:text-green-200 text-sm">{title}</span>
    </div>
    <div className="text-green-900 dark:text-green-100 text-sm leading-relaxed">{children}</div>
  </aside>
);

export default Tip; 