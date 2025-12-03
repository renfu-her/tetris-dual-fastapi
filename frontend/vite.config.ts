import path from 'path';
import { defineConfig, loadEnv } from 'vite';
import react from '@vitejs/plugin-react';

export default defineConfig(({ mode }) => {
    const env = loadEnv(mode, '.', '');
    return {
      server: {
        port: 3000,
        host: '0.0.0.0',
      },
      plugins: [react()],
      define: {
        'process.env.API_KEY': JSON.stringify(env.GEMINI_API_KEY),
        'process.env.GEMINI_API_KEY': JSON.stringify(env.GEMINI_API_KEY),
        'import.meta.env.VITE_API_BASE_URL': JSON.stringify(env.VITE_API_BASE_URL || 'http://localhost:8000/api')
      },
      resolve: {
        alias: {
          '@': path.resolve(__dirname, '.'),
        }
      },
      build: {
        // 输出目录
        outDir: 'dist',
        // 静态资源目录
        assetsDir: 'assets',
        // 启用压缩 (esbuild 更快，terser 压缩率更高但需要额外安装)
        minify: 'esbuild',
        // 目标浏览器
        target: 'es2015',
        // 代码分割策略
        rollupOptions: {
          output: {
            // 手动分割 chunk
            manualChunks: {
              'react-vendor': ['react', 'react-dom'],
            },
            // 文件命名
            chunkFileNames: 'assets/js/[name]-[hash].js',
            entryFileNames: 'assets/js/[name]-[hash].js',
            assetFileNames: 'assets/[ext]/[name]-[hash].[ext]',
          },
        },
        // 生成 source map (生产环境建议关闭)
        sourcemap: false,
        // chunk 大小警告限制（KB）
        chunkSizeWarningLimit: 1000,
        // 启用 CSS 代码分割
        cssCodeSplit: true,
        // 清空输出目录
        emptyOutDir: true,
      },
    };
});
