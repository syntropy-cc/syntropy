'use client';

import { useState, useEffect } from 'react';
import { ChevronDownIcon } from '@heroicons/react/24/outline';

interface DropdownProps {
  children: React.ReactNode;
  title: string;
  color?: 'success' | 'info' | 'warning' | 'danger';
  defaultOpen?: boolean;
}

export function MystDropdown({ 
  children, 
  title, 
  color = 'info', 
  defaultOpen = false 
}: DropdownProps) {
  const [isOpen, setIsOpen] = useState(defaultOpen);

  const toggleDropdown = () => {
    setIsOpen(!isOpen);
  };

  return (
    <div className={`myst-dropdown myst-dropdown--${color}`}>
      <button
        className="myst-dropdown__trigger"
        onClick={toggleDropdown}
        aria-expanded={isOpen}
        aria-controls={`dropdown-content-${title.replace(/\s+/g, '-').toLowerCase()}`}
      >
        <span>{title}</span>
        <ChevronDownIcon className="myst-dropdown__icon" />
      </button>
      {isOpen && (
        <div 
          id={`dropdown-content-${title.replace(/\s+/g, '-').toLowerCase()}`}
          className="myst-dropdown__content"
        >
          {children}
        </div>
      )}
    </div>
  );
}

interface CardProps {
  children: React.ReactNode;
  header?: string;
  headerColor?: 'primary' | 'success' | 'info' | 'warning' | 'danger';
  className?: string;
}

export function MystCard({ 
  children, 
  header, 
  headerColor = 'primary',
  className = '' 
}: CardProps) {
  return (
    <div className={`myst-card ${className}`}>
      {header && (
        <div className={`myst-card__header myst-card__header--${headerColor}`}>
          {header}
        </div>
      )}
      <div className="myst-card__body">
        <div className="myst-card__content">
          {children}
        </div>
      </div>
    </div>
  );
}

interface GridProps {
  children: React.ReactNode;
  columns?: 1 | 2 | 3 | 4;
  className?: string;
  // Suporte para layout responsivo conforme documentação MyST
  responsiveColumns?: string; // ex: "1 1 2 3"
}

export function MystGrid({ 
  children, 
  columns = 2, 
  className = '',
  responsiveColumns
}: GridProps) {
  // Se responsiveColumns for fornecido, usar classes CSS responsivas
  if (responsiveColumns) {
    const columnValues = responsiveColumns.split(' ').map(Number);
    const [mobile, tablet, desktop, large] = columnValues;
    
    // Gerar classes CSS responsivas baseadas nos breakpoints MyST
    const responsiveClasses = [
      `myst-grid--mobile-${mobile || 1}`,
      `myst-grid--tablet-${tablet || mobile || 1}`,
      `myst-grid--desktop-${desktop || tablet || mobile || 1}`,
      `myst-grid--large-${large || desktop || tablet || mobile || 1}`
    ].join(' ');
    
    return (
      <div className={`myst-grid myst-grid--responsive ${responsiveClasses} ${className}`}>
        {children}
      </div>
    );
  }
  
  // Fallback para o comportamento original
  return (
    <div className={`myst-grid myst-grid--${columns} ${className}`}>
      {children}
    </div>
  );
}

interface AdmonitionProps {
  children: React.ReactNode;
  title?: string;
  type?: 'tip' | 'note' | 'warning' | 'danger' | 'cta-action';
  className?: string;
}

export function MystAdmonition({ 
  children, 
  title, 
  type = 'note',
  className = '' 
}: AdmonitionProps) {
  const getIcon = () => {
    switch (type) {
      case 'tip':
        return '💡';
      case 'warning':
        return '⚠️';
      case 'danger':
        return '🚨';
      case 'cta-action':
        return '🚀';
      default:
        return '📝';
    }
  };

  return (
    <div className={`myst-admonition myst-admonition--${type} ${className}`}>
      {title && (
        <div className="myst-admonition__title">
          <span>{getIcon()}</span>
          {title}
        </div>
      )}
      <div className="myst-admonition__content">
        {children}
      </div>
    </div>
  );
}

interface FigureProps {
  src: string;
  alt: string;
  caption?: string;
  width?: string;
  align?: 'left' | 'center' | 'right';
  className?: string;
}

export function MystFigure({ 
  src, 
  alt, 
  caption, 
  width = '100%',
  align = 'center',
  className = '' 
}: FigureProps) {
  return (
    <div className={`myst-figure ${className}`} style={{ textAlign: align }}>
      <img 
        src={src} 
        alt={alt} 
        className="myst-figure__image"
        style={{ width }}
      />
      {caption && (
        <div className="myst-figure__caption">
          {caption}
        </div>
      )}
    </div>
  );
}

// Hook para inicializar dropdowns em conteúdo estático
export function useMystDropdowns() {
  useEffect(() => {
    const dropdownTriggers = document.querySelectorAll('.myst-dropdown__trigger');
    
    const handleClick = (event: Event) => {
      const trigger = event.target as HTMLElement;
      const dropdown = trigger.closest('.myst-dropdown');
      const content = dropdown?.querySelector('.myst-dropdown__content');
      const icon = trigger.querySelector('.myst-dropdown__icon');
      
      if (content && icon) {
        const isOpen = content.getAttribute('aria-hidden') !== 'true';
        
        if (isOpen) {
          content.setAttribute('aria-hidden', 'true');
          content.style.display = 'none';
          trigger.setAttribute('aria-expanded', 'false');
          icon.style.transform = 'rotate(0deg)';
        } else {
          content.setAttribute('aria-hidden', 'false');
          content.style.display = 'block';
          trigger.setAttribute('aria-expanded', 'true');
          icon.style.transform = 'rotate(180deg)';
        }
      }
    };

    dropdownTriggers.forEach(trigger => {
      trigger.addEventListener('click', handleClick);
    });

    return () => {
      dropdownTriggers.forEach(trigger => {
        trigger.removeEventListener('click', handleClick);
      });
    };
  }, []);
}

// Componente para inicializar interatividade em páginas estáticas
export function MystInteractiveProvider({ children }: { children: React.ReactNode }) {
  useMystDropdowns();
  
  return <>{children}</>;
}
