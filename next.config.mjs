import path from 'path';

/** @type {import('next').NextConfig} */
const nextConfig = {
  experimental: {
    mdxRs: true,
  },
  eslint: { ignoreDuringBuilds: true },
  typescript: { ignoreBuildErrors: true },
  images: {
    domains: ['images.unsplash.com', 'avatars.githubusercontent.com'],
    unoptimized: true,
  },
  webpack: (config) => {
    config.resolve.extensions.push('.ts', '.tsx');
    return config;
  },
};

export default nextConfig;