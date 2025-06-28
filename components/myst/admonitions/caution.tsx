import React from "react";

const Caution: React.FC<{ title?: string; children: React.ReactNode }> = ({ title = "Cuidado", children }) => (
  <aside
    className="admonition-caution relative my-6 rounded-xl bg-orange-50/80 dark:bg-orange-950/40 border-l-4 border-orange-500 shadow-xl overflow-x-auto backdrop-blur-md transition-all duration-200 ease-in-out px-6 pt-5 pb-4"
    role="alert"
    aria-label="Cuidado"
    tabIndex={0}
  >
    <div className="flex items-center gap-2 mb-2">
      <span className="text-orange-500 text-lg" aria-hidden>🔺</span>
      <span className="font-semibold uppercase tracking-wide text-orange-700 dark:text-orange-200 text-sm">{title}</span>
    </div>
    <div className="not-prose text-orange-900 dark:text-orange-100 text-sm leading-relaxed">{children}</div>
  </aside>
);

export default Caution; 