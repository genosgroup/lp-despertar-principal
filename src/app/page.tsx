import type { Metadata } from "next";
import PaginaDoPacote from "@/components/PaginaDoPacote";

const TITULO = "Clínica Despertar · Saúde integrada na Pituba, Salvador";
const DESCRICAO =
  "Clínica interdisciplinar na Pituba, Salvador, da criança ao idoso. Fono, terapia ocupacional, psicologia e mais, com escuta antes de qualquer rótulo.";

export const metadata: Metadata = {
  title: TITULO,
  description: DESCRICAO,
  alternates: { canonical: "/" },
  openGraph: {
    type: "website",
    locale: "pt_BR",
    url: "/",
    siteName: "Clínica Despertar",
    title: TITULO,
    description: DESCRICAO,
    images: [
      {
        url: "/og-despertar.jpg",
        width: 1200,
        height: 630,
        alt: "Clínica Despertar, saúde integrada na Pituba, Salvador",
      },
    ],
  },
  twitter: {
    card: "summary_large_image",
    title: TITULO,
    description: DESCRICAO,
    images: ["/og-despertar.jpg"],
  },
};

/** Dados da clinica para a busca local (os mesmos do rodape da pagina). */
const DADOS_DA_CLINICA = {
  "@context": "https://schema.org",
  "@type": "MedicalClinic",
  name: "Clínica Despertar · Espaço de Saúde Integrada",
  url: "https://despertaresi.com.br/",
  image: "https://despertaresi.com.br/og-despertar.jpg",
  logo: "https://despertaresi.com.br/imagens/dsp-lp-logo.webp",
  telephone: "+55 71 99399-6613",
  address: {
    "@type": "PostalAddress",
    streetAddress: "Alameda Benevento, 72, sala 401, Pituba",
    addressLocality: "Salvador",
    addressRegion: "BA",
    addressCountry: "BR",
  },
  sameAs: ["https://www.instagram.com/clinica.despertaresi/"],
};

export default function Home() {
  return (
    <>
      <script
        type="application/ld+json"
        dangerouslySetInnerHTML={{
          __html: JSON.stringify(DADOS_DA_CLINICA).replace(/</g, "\\u003c"),
        }}
      />
      <PaginaDoPacote />
    </>
  );
}
