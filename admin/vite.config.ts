import { defineConfig, loadEnv } from 'vite'
import react from '@vitejs/plugin-react'
import tailwindcss from '@tailwindcss/vite'
import path from 'path'

export default defineConfig(({ mode }) => {
  const env = loadEnv(mode, process.cwd(), '')
  const supabaseUrl = env.VITE_SUPABASE_URL || 'https://mildsuuygbzgdunwmzuk.supabase.co'

  return {
    plugins: [react(), tailwindcss()],
    server: {
      port: 5174,
      // Avoid browser CORS on Edge Function preflight during local CMS dev.
      proxy: {
        '/__supabase': {
          target: supabaseUrl,
          changeOrigin: true,
          secure: true,
          rewrite: (p) => p.replace(/^\/__supabase/, ''),
        },
      },
    },
    resolve: {
      alias: {
        '@': path.resolve(__dirname, './src'),
      },
    },
  }
})
