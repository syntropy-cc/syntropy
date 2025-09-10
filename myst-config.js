/**
 * MyST Configuration for Syntropy Learn Platform
 * 
 * This configuration extends MyST to support custom grid layouts,
 * interactive components, and the Syntropy design system.
 */

import { mystParser } from 'myst-parser';
import { mystToReact } from 'myst-to-react';

// Custom directive definitions for MyST
const customDirectives = {
  // Grid directive: ::::{grid} 1 1 1 1
  grid: {
    required_arguments: 0,
    optional_arguments: 1,
    has_content: true,
    option_spec: {
      columns: {
        validator: (value) => {
          const cols = value.split(' ').map(Number);
          return cols.every(col => col >= 1 && col <= 4);
        },
        default: '1 1'
      }
    }
  },

  // Card directive: :::{card}
  card: {
    required_arguments: 0,
    optional_arguments: 1,
    has_content: true,
    option_spec: {
      header: {
        validator: (value) => typeof value === 'string',
        default: ''
      },
      'class-header': {
        validator: (value) => ['bg-primary', 'bg-success', 'bg-info', 'bg-warning', 'bg-danger'].includes(value),
        default: 'bg-primary'
      }
    }
  },

  // Dropdown directive: ```{dropdown}
  dropdown: {
    required_arguments: 0,
    optional_arguments: 1,
    has_content: true,
    option_spec: {
      color: {
        validator: (value) => ['success', 'info', 'warning', 'danger'].includes(value),
        default: 'info'
      }
    }
  },

  // Admonition directive: ```{admonition}
  admonition: {
    required_arguments: 0,
    optional_arguments: 1,
    has_content: true,
    option_spec: {
      class: {
        validator: (value) => ['tip', 'note', 'warning', 'danger', 'cta-action'].includes(value),
        default: 'note'
      }
    }
  },

  // Figure directive: :::{figure}
  figure: {
    required_arguments: 1,
    optional_arguments: 0,
    has_content: false,
    option_spec: {
      name: { validator: (value) => typeof value === 'string' },
      align: { 
        validator: (value) => ['left', 'center', 'right'].includes(value),
        default: 'center'
      },
      width: { 
        validator: (value) => typeof value === 'string',
        default: '100%'
      }
    }
  }
};

// Custom role definitions
const customRoles = {
  // For inline elements like :name:`content`
  'class-header': {
    validator: (value) => typeof value === 'string'
  }
};

// MyST Parser Configuration
export const mystConfig = {
  // Enable custom directives and roles
  directives: customDirectives,
  roles: customRoles,

  // Parser options
  parser: {
    // Enable all standard MyST features
    enable: [
      'colon_fence',
      'html_image',
      'html_admonition',
      'myst_targets',
      'myst_role',
      'myst_directive',
      'footnotes',
      'deflist',
      'tasklist',
      'strikethrough',
      'smartquotes',
      'substitution'
    ],
    
    // Disable conflicting features
    disable: [
      'html_image', // We'll handle images through our custom figure directive
    ]
  },

  // React renderer configuration
  renderer: {
    // Custom component mappings
    components: {
      // Map MyST nodes to React components
      'myst-grid': 'MystGrid',
      'myst-card': 'MystCard', 
      'myst-dropdown': 'MystDropdown',
      'myst-admonition': 'MystAdmonition',
      'myst-figure': 'MystFigure'
    },

    // Custom styling
    styles: {
      // Import our custom CSS
      imports: ['./styles/myst-grid-components.css']
    }
  },

  // Markdown extensions
  markdown: {
    // Enable GitHub Flavored Markdown
    gfm: true,
    
    // Enable tables
    tables: true,
    
    // Enable task lists
    taskLists: true,
    
    // Enable strikethrough
    strikethrough: true,
    
    // Enable smart quotes
    smartQuotes: true
  }
};

// Export the configured parser
export const parser = mystParser.configure(mystConfig);

// Export the configured renderer
export const renderer = mystToReact.configure(mystConfig);

// Utility function to parse and render MyST content
export function parseAndRender(content, options = {}) {
  const tree = parser.parse(content);
  return renderer.render(tree, options);
}

// Export default configuration
export default mystConfig;
