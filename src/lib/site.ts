/**
 * O que muda de uma pagina da Despertar para outra (principal, fono, TO).
 * Os componentes sao os mesmos nos tres repositorios; a diferenca fica aqui,
 * em src/lib/medicao.ts e no pacote (conteudo/).
 */

/**
 * Caminho em que esta pagina e servida no dominio. A principal e a raiz.
 * Em fono e TO e o caminho da pagina, e tem que bater com o basePath do
 * next.config.ts: todo arquivo servido precisa caber no prefixo da rota (§1.3).
 */
export const BASE_PATH = "";

/** Endereco final da pagina (canonical, og:url). */
export const URL_DA_PAGINA = "https://despertaresi.com.br/";

/** Foto do topo: carrega primeiro e com prioridade, porque e o LCP no celular. */
export const FOTO_PRINCIPAL = "dsp-lp-home-mayara.webp";

/** Para onde o formulario manda o lead. */
export const ROTA_DO_LEAD = `${BASE_PATH}/api/lead`;

/**
 * Webhook do n8n que recebe o lead desta pagina e cria o card no Kommo. Cada
 * pagina tem o seu (despertar-lp-principal, -fono, -to). O repositorio e
 * publico, entao este endereco e visivel: a protecao e o LEAD_WEBHOOK_TOKEN
 * (ver src/app/api/lead/route.ts).
 */
export const WEBHOOK_DO_LEAD =
  "https://webhook.automacaogenosgroup.com.br/webhook/despertar-lp-principal";
