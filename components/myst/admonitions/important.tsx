import React from "react";

const Important: React.FC<{ title?: string; children: React.ReactNode }> = ({ title = "Importante", children }) => (
  <aside
    className="admonition-important relative my-6 rounded-xl bg-red-50/80 dark:bg-red-950/40 border-l-4 border-red-500 shadow-xl overflow-x-auto backdrop-blur-md transition-all duration-200 ease-in-out px-6 pt-5 pb-4"
    role="alert"
    aria-label="Importante"
    tabIndex={0}
  >
    <div className="flex items-center gap-2 mb-2">
      <span className="text-red-500 text-lg" aria-hidden>❗</span>
      <span className="font-semibold uppercase tracking-wide text-red-700 dark:text-red-200 text-sm">{title}</span>
    </div>
    <div className="not-prose text-red-900 dark:text-red-100 text-sm leading-relaxed">{children}</div>
  </aside>
);

export default Important; 