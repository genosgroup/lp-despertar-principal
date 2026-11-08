import type { MetadataRoute } from "next";

/**
 * Sitemap do dominio inteiro. Esta base e a raiz de despertaresi.com.br, entao
 * as paginas de fono e TO (que moram em outros repositorios) entram aqui.
 * Pagina nova no dominio? Acrescente nesta lista.
 */
const BASE = "https://despertaresi.com.br";

export default function sitemap(): MetadataRoute.Sitemap {
  return [
    { url: `${BASE}/`, changeFrequency: "monthly", priority: 1 },
    { url: `${BASE}/fonoaudiologia-salvador/`, changeFrequency: "monthly", priority: 0.8 },
    { url: `${BASE}/terapia-ocupacional-salvador/`, changeFrequency: "monthly", priority: 0.8 },
  ];
}
