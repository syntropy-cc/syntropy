import React from "react";

const Challenge: React.FC<{ title: string; children: React.ReactNode }> = ({ title, children }) => (
  <aside
    className="admonition-challenge relative my-6 rounded-xl bg-pink-50/80 dark:bg-pink-950/40 border-l-4 border-pink-500 shadow-xl overflow-x-auto backdrop-blur-md transition-all duration-200 ease-in-out px-6 pt-5 pb-4"
    role="region"
    aria-label="Desafio"
    tabIndex={0}
  >
    <div className="flex items-center gap-2 mb-2">
      <span className="text-pink-500 text-lg" aria-hidden>🏆</span>
      <span className="font-semibold uppercase tracking-wide text-pink-700 dark:text-pink-200 text-sm">{title}</span>
    </div>
    <div className="not-prose text-pink-900 dark:text-pink-100 text-sm leading-relaxed">{children}</div>
  </aside>
);

export default Challenge; 