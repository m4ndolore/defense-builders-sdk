/** @type {import('next').NextConfig} */
const nextConfig = {
    reactStrictMode: true,
    swcMinify: true,
    transpilePackages: ['@defense-builders/ui'],
    experimental: {
      serverActions: {
        bodySizeLimit: '2mb'
      }
    }
  };
  
  module.exports = nextConfig;