import React from "react";

const Warning: React.FC<{ title?: string; children: React.ReactNode }> = ({ title = "Aviso", children }) => (
  <aside
    className="admonition-warning relative my-6 rounded-xl bg-yellow-50/80 dark:bg-yellow-950/40 border-l-4 border-yellow-500 shadow-xl overflow-x-auto backdrop-blur-md transition-all duration-200 ease-in-out px-6 pt-5 pb-4"
    role="alert"
    aria-label="Aviso"
    tabIndex={0}
  >
    <div className="flex items-center gap-2 mb-2">
      <span className="text-yellow-500 text-lg" aria-hidden>⚠️</span>
      <span className="font-semibold uppercase tracking-wide text-yellow-700 dark:text-yellow-200 text-sm">{title}</span>
    </div>
    <div className="not-prose text-yellow-900 dark:text-yellow-100 text-sm leading-relaxed">{children}</div>
  </aside>
);

export default Warning; 