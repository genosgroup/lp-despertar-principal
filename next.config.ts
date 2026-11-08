import type { NextConfig } from "next";

const nextConfig: NextConfig = {
  cacheComponents: true,
  partialPrefetching: true,
  poweredByHeader: false,
  turbopack: {
    rules: {
      // O HTML do pacote aprovado (conteudo/*.html) entra no build como texto.
      // Ele e lido em tempo de build e vira componentes React em
      // src/components/PaginaDoPacote.tsx; nenhum arquivo e lido no servidor.
      "*.html": { type: "text" },
    },
  },
};

export default nextConfig;
