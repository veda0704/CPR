import { defineConfig } from 'vite';
import react from '@vitejs/plugin-react';
import os from 'os';

// Get the local IP address (fallback to localhost)
function getLocalIp() {
  const interfaces = os.networkInterfaces();
  for (const name of Object.keys(interfaces)) {
    for (const iface of interfaces[name]) {
      if (iface.family === 'IPv4' && !iface.internal && iface.address.startsWith('10.')) {
        return iface.address;
      }
    }
  }
  return 'localhost';
}

const localIp = getLocalIp();

// https://vitejs.dev/config/
export default defineConfig({
  plugins: [react()],
  server: {
    host: '0.0.0.0', // Listen on all interfaces
    port: 3000,
    hmr: {
      overlay: false
    },
    proxy: {
      '/api': {
        target: 'http://localhost:8002',
        changeOrigin: true,
      },
      '/static': {
        target: 'http://localhost:8002',
        changeOrigin: true,
      },
      '/media': {
        target: 'http://localhost:8002',
        changeOrigin: true,
      },
    },
  },
});
