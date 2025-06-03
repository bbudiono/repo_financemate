import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'
import path from 'path'

// https://vitejs.dev/config/
export default defineConfig({
  plugins: [react()],
  root: './copilotkit-ui/client',
  server: {
    port: 3000,
    proxy: {
      '/api': {
        target: 'http://localhost:3001',
        changeOrigin: true
      },
      '/ws': {
        target: 'ws://localhost:3001',
        ws: true
      }
    }
  },
  resolve: {
    alias: {
      '@': path.resolve(__dirname, './copilotkit-ui/client/src'),
      '@/components': path.resolve(__dirname, './copilotkit-ui/client/src/components'),
      '@/hooks': path.resolve(__dirname, './copilotkit-ui/client/src/hooks'),
      '@/services': path.resolve(__dirname, './copilotkit-ui/client/src/services'),
      '@/types': path.resolve(__dirname, './copilotkit-ui/client/src/types'),
      '@/utils': path.resolve(__dirname, './copilotkit-ui/client/src/utils')
    }
  },
  build: {
    outDir: '../../dist',
    emptyOutDir: true,
    rollupOptions: {
      output: {
        manualChunks: {
          'react-vendor': ['react', 'react-dom'],
          'dashboard': [
            './copilotkit-ui/client/src/components/dashboard/AgentCoordinationDashboard.tsx'
          ],
          'workflows': [
            './copilotkit-ui/client/src/components/workflows/LangGraphWorkflowVisualizer.tsx'
          ],
          'optimization': [
            './copilotkit-ui/client/src/components/optimization/AppleSiliconOptimizationPanel.tsx'
          ],
          'communication': [
            './copilotkit-ui/client/src/components/communication/AgentCommunicationFeed.tsx'
          ]
        }
      }
    },
    target: 'esnext',
    minify: 'terser',
    terserOptions: {
      compress: {
        drop_console: true,
        drop_debugger: true
      }
    }
  },
  optimizeDeps: {
    include: ['react', 'react-dom', 'socket.io-client']
  }
})