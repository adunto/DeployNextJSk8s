import type { NextConfig } from "next";

const nextConfig: NextConfig = {  
  /* config options here */
  async redirects() {
    return [
      {
        source: '/',
        destination: '/bookmarks',
        permanent: true
      }
    ]
  }, //redirects()
  async rewrites() {
    const API_BASE_URL = process.env.NEXT_PUBLIC_SERVER_API_BASE_URL
    return [
        {
            source: '/api/:path*',
            destination: `${API_BASE_URL}/api/:path*`
            //'http://bookmarker-api-svc:8080/:path*/' // Proxy to Backend
        }
    ]
}, //rewrites  
};

export default nextConfig;
