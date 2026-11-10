import type { NextConfig } from "next";

const nextConfig: NextConfig = {
  // A pagina e publicada como arquivos estaticos na Turbo Cloud (cPanel +
  // LiteSpeed), sem Node, na raiz do dominio, ao lado do WordPress.
  // `npm run build` gera tudo em out/. O envio do lead e feito por
  // public/api/lead/index.php. Cache Components (PPR) nao funciona em
  // exportacao estatica, por isso nao esta ligado.
  output: "export",
  poweredByHeader: false,
  turbopack: {
    rules: {
      // O HTML do pacote aprovado (conteudo/*.html) entra no build como texto.
      // Ele e lido em tempo de build e vira componentes React em
      // src/components/PaginaDoPacote.tsx.
      "*.html": { type: "text" },
    },
  },
};

export default nextConfig;
