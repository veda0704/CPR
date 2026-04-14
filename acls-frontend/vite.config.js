import { defineConfig } from 'vite';
import react from '@vitejs/plugin-react';

// https://vitejs.dev/config/
export default defineConfig({
  plugins: [react()],
  server: {
    host: true, // 🌏 Expose to network (allows access via 10.2.1.117)
    port: 3000,
    proxy: {
      '/api': {
        target: 'http://localhost:8002',
        changeOrigin: true,
      },
      '/static': {
        target: 'http://localhost:8002',
        changeOrigin: true,
      },
    },
  },
});
