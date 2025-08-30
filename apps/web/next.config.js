/** @type {import('next').NextConfig} */
const nextConfig = {
    reactStrictMode: true,
    swcMinify: true,
    // transpilePackages: ['@defense-builders/ui'], // Temporarily disabled until UI package is created
    experimental: {
      serverActions: {
        bodySizeLimit: '2mb'
      }
    }
  };
  
  module.exports = nextConfig;