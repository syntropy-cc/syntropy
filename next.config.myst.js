/**
 * Next.js Configuration for MyST Grid Components
 * 
 * This configuration extends Next.js to support MyST parsing
 * and custom component rendering for the Syntropy Learn platform.
 */

const withMyst = require('next-myst')({
  // MyST parser configuration
  myst: {
    // Enable custom directives
    directives: {
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
    },

    // Custom roles
    roles: {
      'class-header': {
        validator: (value) => typeof value === 'string'
      }
    },

    // Parser options
    parser: {
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
      ]
    }
  },

  // React component mappings
  components: {
    'myst-grid': './components/myst-grid-interactive.tsx#MystGrid',
    'myst-card': './components/myst-grid-interactive.tsx#MystCard',
    'myst-dropdown': './components/myst-grid-interactive.tsx#MystDropdown',
    'myst-admonition': './components/myst-grid-interactive.tsx#MystAdmonition',
    'myst-figure': './components/myst-grid-interactive.tsx#MystFigure'
  },

  // CSS imports
  styles: [
    './styles/myst-grid-components.css'
  ]
});

/** @type {import('next').NextConfig} */
const nextConfig = {
  // Existing Next.js configuration
  experimental: {
    // Enable experimental features if needed
  },

  // Webpack configuration for MyST
  webpack: (config, { isServer }) => {
    // Add support for .md files
    config.module.rules.push({
      test: /\.md$/,
      use: [
        {
          loader: 'next-myst/loader',
          options: {
            // MyST-specific options
            myst: {
              // Same configuration as above
            }
          }
        }
      ]
    });

    return config;
  },

  // Image optimization for figures
  images: {
    domains: ['localhost', 'syntropy.cc'],
    formats: ['image/webp', 'image/avif'],
  },

  // Headers for security
  async headers() {
    return [
      {
        source: '/courses/:path*',
        headers: [
          {
            key: 'X-Content-Type-Options',
            value: 'nosniff',
          },
          {
            key: 'X-Frame-Options',
            value: 'DENY',
          },
          {
            key: 'X-XSS-Protection',
            value: '1; mode=block',
          },
        ],
      },
    ];
  },

  // Redirects for course content
  async redirects() {
    return [
      {
        source: '/learn/courses/:courseSlug',
        destination: '/learn/courses/:courseSlug/introducao',
        permanent: false,
      },
    ];
  },
};

module.exports = withMyst(nextConfig);
