import { defineConfig, loadEnv } from "vite";
import react from "@vitejs/plugin-react";
import tailwindcss from "@tailwindcss/vite";
import { VitePWA } from "vite-plugin-pwa";

// https://vite.dev/config/
export default defineConfig(({ mode }) => {
  const env = loadEnv(mode, process.cwd(), "");
  const backendTarget = (
    env.VITE_BACKEND_TARGET || "http://127.0.0.1:5000"
  ).trim();

  return {
    plugins: [
      react(),
      tailwindcss(),
      VitePWA({
        injectRegister: "auto",
        registerType: "autoUpdate",
        includeAssets: ["favicon.ico", "icon-store.svg", "tokokelontong.jpg"],
        manifest: {
          name: "Toko Kelontong POS",
          short_name: "Toko Kelontong",
          description: "Sistem Point of Sale Toko Kelontong",
          theme_color: "#4c1d95",
          background_color: "#f9fafb",
          id: "/",
          display: "standalone",
          display_override: ["standalone", "minimal-ui"],
          orientation: "any",
          start_url: "/owner/dashboard",
          scope: "/",
          prefer_related_applications: false,
          icons: [
            {
              src: "pwa-64x64.png",
              sizes: "64x64",
              type: "image/png",
              purpose: "any",
            },
            {
              src: "pwa-192x192.png",
              sizes: "192x192",
              type: "image/png",
              purpose: "any",
            },
            {
              src: "pwa-512x512.png",
              sizes: "512x512",
              type: "image/png",
              purpose: "any",
            },
            {
              src: "maskable-icon-512x512.png",
              sizes: "512x512",
              type: "image/png",
              purpose: "any maskable",
            },
          ],
        },
        workbox: {
          globPatterns: ["**/*.{js,css,html,ico,png,svg,woff2}"],
          runtimeCaching: [
            {
              // Cache API responses with NetworkFirst — always try network,
              // fall back to cache if offline.
              urlPattern: /^https?:\/\/.*\/api\//,
              handler: "NetworkFirst",
              options: {
                cacheName: "api-cache",
                networkTimeoutSeconds: 10,
                expiration: {
                  maxEntries: 64,
                  maxAgeSeconds: 60 * 60, // 1 hour
                },
                cacheableResponse: {
                  statuses: [0, 200],
                },
              },
            },
            {
              // Cache generated invoices / PDFs served from /invoices/
              urlPattern: /^https?:\/\/.*\/invoices\//,
              handler: "CacheFirst",
              options: {
                cacheName: "invoices-cache",
                expiration: {
                  maxEntries: 32,
                  maxAgeSeconds: 60 * 60 * 24 * 7, // 7 days
                },
                cacheableResponse: {
                  statuses: [0, 200],
                },
              },
            },
          ],
          // Do NOT cache SSE streams
          navigateFallback: "/index.html",
          navigateFallbackDenylist: [/^\/api\//, /^\/invoices\//],
        },
        devOptions: {
          enabled: true,
        },
      }),
    ],
    server: {
      proxy: {
        "/api": {
          target: backendTarget,
          changeOrigin: true,
          secure: false,
        },
        "/invoices": {
          target: backendTarget,
          changeOrigin: true,
          secure: false,
        },
      },
    },
    build: {
      rollupOptions: {
        output: {
          // Function form is required here: object-form manualChunks only
          // matches a package's exact entry module id, so internal files
          // (e.g. react-dom/cjs/react-dom-client.production.js, scheduler)
          // were leaking into the main entry chunk instead of vendor-react.
          manualChunks(id) {
            if (!id.includes("node_modules")) return;

            if (
              id.includes("react-dom") ||
              id.includes("/react/") ||
              id.includes("scheduler") ||
              id.includes("react-router")
            ) {
              return "vendor-react";
            }
            if (id.includes("recharts") || id.includes("d3-")) {
              return "vendor-charts";
            }
            if (id.includes("firebase")) {
              return "vendor-firebase";
            }
            if (id.includes("sweetalert2") || id.includes("lucide-react")) {
              return "vendor-ui";
            }
          },
        },
      },
    },
  };
});