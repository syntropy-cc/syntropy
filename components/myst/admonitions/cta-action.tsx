import React from "react";

const CtaAction: React.FC<{ title?: string; children: React.ReactNode }> = ({ 
  title = "🚀 Sua Vez de Aplicar", 
  children 
}) => {
  // Remover emoji do título se existir, pois vamos adicionar nosso próprio
  const cleanTitle = title.replace(/🚀\s*/, '').trim();
  
  return (
    <aside
      className="admonition-cta-action relative my-8 rounded-2xl bg-gradient-to-br from-blue-600/20 via-purple-600/20 to-indigo-600/20 dark:from-blue-500/30 dark:via-purple-500/30 dark:to-indigo-500/30 border-l-4 border-blue-500 shadow-2xl overflow-x-auto backdrop-blur-md transition-all duration-300 ease-in-out px-8 pt-6 pb-6 hover:bg-gradient-to-br hover:from-blue-50/80 hover:via-purple-50/80 hover:to-indigo-50/80 dark:hover:from-blue-950/60 dark:hover:via-purple-950/60 dark:hover:to-indigo-950/60 hover:shadow-3xl hover:scale-[1.02] group"
      role="region"
      aria-label="Chamada para Ação"
      tabIndex={0}
      style={{ position: 'relative', zIndex: 1 }}
    >
      {/* Efeito de brilho animado por padrão */}
      <div className="absolute inset-0 rounded-2xl bg-gradient-to-r from-blue-500/10 via-purple-500/10 to-blue-500/10 opacity-100 group-hover:opacity-50 transition-opacity duration-300" 
           style={{
             background: 'linear-gradient(90deg, rgba(59, 130, 246, 0.1), rgba(139, 92, 246, 0.1), rgba(59, 130, 246, 0.1))',
             backgroundSize: '200% 100%',
             animation: 'gradient-shift 3s ease-in-out infinite',
             zIndex: 0
           }}>
      </div>
      
      {/* Ícone animado melhorado */}
      <div className="flex items-center gap-3 mb-4 relative z-20">
        <div className="relative">
          <span 
            className="text-2xl" 
            aria-hidden 
            style={{
              animation: 'rocket-bounce 2s ease-in-out infinite',
              filter: 'drop-shadow(0 0 8px rgba(59, 130, 246, 0.5))',
              display: 'inline-block'
            }}
          >
            🚀
          </span>
        </div>
        <span className="font-bold text-lg text-white group-hover:text-blue-900 dark:group-hover:text-blue-900 transition-colors duration-300">
          {cleanTitle || 'Sua Vez de Aplicar'}
        </span>
      </div>
      
      {/* Conteúdo com destaque especial */}
      <div className="not-prose text-white/90 dark:text-blue-100 text-base leading-relaxed relative z-10 group-hover:text-blue-900 dark:group-hover:text-blue-900 transition-colors duration-300">
        <div className="bg-white/20 dark:bg-black/20 rounded-lg p-4 border border-white/30 dark:border-blue-800/50 group-hover:bg-white/60 dark:group-hover:bg-white/20 group-hover:border-blue-200/50 dark:group-hover:border-blue-800/50 transition-all duration-300">
          {children}
        </div>
      </div>
      
      {/* Elemento decorativo no canto inferior direito */}
      <div className="absolute bottom-2 right-2 opacity-30 group-hover:opacity-60 transition-opacity duration-300">
        <svg width="24" height="24" viewBox="0 0 24 24" fill="none" className="text-blue-400 group-hover:text-blue-600 transition-colors duration-300">
          <path d="M13 2L3 14h9l-1 8 10-12h-9l1-8z" fill="currentColor"/>
        </svg>
      </div>
      
      {/* Borda animada por padrão */}
      <div className="absolute inset-0 rounded-2xl border-2 border-transparent opacity-100 group-hover:opacity-0 transition-opacity duration-300" 
           style={{
             background: 'linear-gradient(90deg, #3b82f6, #8b5cf6, #3b82f6)',
             backgroundSize: '200% 100%',
             animation: 'gradient-shift 3s ease-in-out infinite'
           }}>
      </div>
    </aside>
  );
};

export default CtaAction;
