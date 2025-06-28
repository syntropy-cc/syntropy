import React from "react";

const Note: React.FC<{ title?: string; children: React.ReactNode }> = ({ title = "Nota", children }) => (
  <aside
    className="admonition-note relative my-6 rounded-xl bg-blue-50/80 dark:bg-blue-950/40 border-l-4 border-blue-500 shadow-xl overflow-x-auto backdrop-blur-md transition-all duration-200 ease-in-out px-6 pt-5 pb-4"
    role="note"
    aria-label="Nota"
    tabIndex={0}
  >
    <div className="flex items-center gap-2 mb-2">
      <span className="text-blue-500 text-lg" aria-hidden>📝</span>
      <span className="font-semibold uppercase tracking-wide text-blue-700 dark:text-blue-200 text-sm">{title}</span>
    </div>
    <div className="text-blue-900 dark:text-blue-100 text-sm leading-relaxed">{children}</div>
  </aside>
);

export default Note; 