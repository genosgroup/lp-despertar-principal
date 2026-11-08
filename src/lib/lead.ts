/**
 * O lead do formulario: campos, opcoes e validacao. Usado pelo formulario
 * (no navegador) e pela rota /api/lead (no servidor), para os dois validarem
 * igual.
 */

/** Opcoes do pacote aprovado (LEIA-ME, item 5 da montagem). */
export const OPCOES_PARA_QUEM = [
  "Criança até 2 anos",
  "Criança de 2 a 4",
  "Criança de 5 a 7",
  "Criança de 8 a 12",
  "Adolescente",
  "Adulto",
  "Idoso",
] as const;

export const OPCOES_QUEM_INDICOU = [
  "Escola",
  "Pediatra ou neuropediatra",
  "Dentista ou outro profissional de saúde",
  "Google",
  "Instagram",
  "Amigo ou família",
  "Outro",
] as const;

/** Parametros de rastreio lidos da URL de chegada (os mesmos campos de rastreio do Kommo). */
export const PARAMETROS_DE_RASTREIO = [
  "utm_source",
  "utm_medium",
  "utm_campaign",
  "utm_content",
  "utm_term",
  "gclid",
  "fbclid",
] as const;

export type ParametroDeRastreio = (typeof PARAMETROS_DE_RASTREIO)[number];

export type Rastreio = Partial<Record<ParametroDeRastreio, string>> & {
  /** De onde a pessoa veio (document.referrer na chegada). */
  referrer?: string;
  /** URL completa da chegada, com a query string. */
  pagina_de_entrada?: string;
};

/** O que o formulario manda para /api/lead. */
export type LeadEnviado = {
  nome: string;
  whatsapp: string;
  para_quem: string;
  quem_indicou: string;
  /** Campo-isca: gente nao preenche, robo preenche. */
  empresa?: string;
  rastreio?: Rastreio;
};

export type Campo = "nome" | "whatsapp" | "para_quem" | "quem_indicou";
export type ErrosDoLead = Partial<Record<Campo, string>>;

/** So os digitos do telefone. */
export function digitos(valor: string) {
  return valor.replace(/\D/g, "");
}

/**
 * Telefone no formato que o Kommo e a Meta casam: com o 55 na frente.
 * Aceita "(71) 99399-6613", "71993996613" e "+55 71 99399-6613".
 */
export function whatsappComDdi(valor: string) {
  const d = digitos(valor);
  if ((d.length === 12 || d.length === 13) && d.startsWith("55")) return d;
  return `55${d}`;
}

export function validarLead(lead: Partial<LeadEnviado>): ErrosDoLead {
  const erros: ErrosDoLead = {};
  const nome = (lead.nome ?? "").trim();
  if (nome.length < 2) erros.nome = "Escreva seu nome.";

  const tel = digitos(lead.whatsapp ?? "");
  const local = tel.startsWith("55") && tel.length >= 12 ? tel.slice(2) : tel;
  if (local.length < 10 || local.length > 11) {
    erros.whatsapp = "Confira o WhatsApp, com DDD. Ex.: (71) 9 0000-0000";
  }

  if (!OPCOES_PARA_QUEM.includes(lead.para_quem as (typeof OPCOES_PARA_QUEM)[number])) {
    erros.para_quem = "Escolha para quem é o atendimento.";
  }

  const indicou = lead.quem_indicou ?? "";
  if (indicou && !OPCOES_QUEM_INDICOU.includes(indicou as (typeof OPCOES_QUEM_INDICOU)[number])) {
    erros.quem_indicou = "Escolha uma das opções.";
  }
  return erros;
}
