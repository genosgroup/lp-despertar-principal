# Clínica Despertar · página principal

A página inicial do site da Clínica Despertar (`despertaresi.com.br/`), em Next.js. Ela
substitui a home do WordPress.

- **Conteúdo:** o pacote aprovado `pacote-wordpress-despertar-v2.zip`, anexo da tarefa
  [[Despertar] Subir as 3 páginas novas do site](https://app.clickup.com/t/17tkuw63mv7).
- **Prévia aprovada:** [Principal](https://claude.ai/artifact/DFxizHUCcpNYUvfKUohzWc).
  A página gerada aqui foi comparada pixel a pixel com essa prévia, no celular (390 px)
  e no desktop (1280 px): sem diferença.
- **Padrão Genos:** começou do `template-lp/` de
  [genosgroup/padroes](https://github.com/genosgroup/padroes). Antes de mexer em medição,
  leia o `AGENTS.md`: esta é uma LP de **cliente**, e os IDs são os da Despertar.

Fono (`/fonoaudiologia-salvador/`) e TO (`/terapia-ocupacional-salvador/`) ficam em
repositórios próprios.

## Rodar

```bash
npm install
```

```bash
npm run dev
```

```bash
npm run build && npm run lint
```

Para testar o envio do formulário localmente, copie `.env.example` para `.env.local` e
preencha `LEAD_WEBHOOK_URL`.

## Onde está cada coisa

| Arquivo | O que é |
| --- | --- |
| `conteudo/home.html` e `conteudo/dsp-lp.css` | O HTML e o CSS do pacote, **idênticos ao aprovado**. Não edite à mão |
| `public/imagens/` | As 11 imagens do pacote que a home usa, com os nomes originais (as de fono e TO ficam nos repositórios delas) |
| `src/components/PaginaDoPacote.tsx` | Transforma o HTML do pacote na página e troca só o que dependia do WordPress |
| `src/components/Formulario.tsx` | O formulário "Primeira conversa", com a marcação da prévia aprovada |
| `src/components/BotaoFixo.tsx` | O botão fixo do celular, que some no topo e no formulário |
| `src/app/api/lead/route.ts` | Recebe o lead, valida e repassa para o destino |
| `src/lib/medicao.ts` | **Todos os IDs de medição**, num lugar só. Vazio = desligado |
| `src/lib/conversao.ts` | Os eventos de Lead e Contato |
| `src/components/Tracking.tsx` | As tags (Google, Meta e Clarity), montadas no layout raiz |
| `src/app/page.tsx` | Title, description, Open Graph e os dados da clínica para a busca local |
| `src/app/sitemap.ts` e `public/robots.txt` | Do domínio inteiro, porque esta é a raiz |
| `src/app/globals.css` | O pouco que o tema do WordPress fazia, mais os estilos de erro do formulário |

### Pacote novo

1. Troque `conteudo/home.html` e `conteudo/dsp-lp.css` pelos novos e as imagens em
   `public/imagens/`.
2. Confira se os ids `dsp-form-slot`, `dsp-ok` e `dsp-fixo` continuam no HTML. É neles
   que o formulário e o botão fixo se encaixam.
3. `npm run build` e compare com a prévia nova.

## Medição

| Momento | Google Ads (`AW-16923338982`) | Meta (Pixel `984879360375130`) | GA4 |
| --- | --- | --- | --- |
| Carregou a página | (tag carregada) | `PageView` | desligado |
| Lead enviado **com sucesso** | conversão `…/1OExCPnL-qsaEObR1oU_` | `Lead` | `generate_lead` (quando ligar) |
| Clique no WhatsApp da confirmação | conversão `…/pPSJCJrC4qsaEObR1oU_` | `Contact` | `whatsapp_clicado` (quando ligar) |

Mais o Microsoft Clarity (`qy00gm1j1s`), que já estava no site antigo.

O que muda em relação ao site antigo, que media tudo pelo `GTM-MDXF8NKB`:

- **Lead na Meta passa a existir.** No GTM antigo o Pixel só recebia PageView e Contact.
- **A conversão de lead do Google Ads só conta envio com sucesso.** No GTM ela disparava
  em qualquer envio de formulário, até nos que falhavam.
- **A conversão do Google Ads que disparava em toda visualização de página
  (`-BduCL3e-6saEObR1oU_`) não foi trazida.** Visita não é conversão.
- **Sem GTM.** As tags estão no código, versionadas (padrão §1.6 e §4.1).

Todos os disparos ficam em `try/catch`: com bloqueador de anúncio o formulário envia
igual. Isso foi testado.

## Formulário e envio do lead

Campos: nome, WhatsApp, "Para quem é o atendimento?" (obrigatório) e "Alguém indicou a
Despertar?" (opcional). As opções são as do LEIA-ME do pacote. Junto vão a origem da
visita (utm_source, utm_medium, utm_campaign, utm_content, utm_term, gclid e fbclid),
o referrer e a URL de chegada. A origem fica guardada na sessão, então quem chega com UTM,
passa pela página de fono e volta não perde a origem.

**O destino do lead ainda não está decidido** (Kommo direto, n8n ou outro). Por isso a
rota `/api/lead` só repassa o lead, num JSON plano, para `LEAD_WEBHOOK_URL`:

```json
{
  "pagina": "Home",
  "nome": "Maria",
  "whatsapp": "5571999990000",
  "para_quem": "Criança de 2 a 4",
  "quem_indicou": "Pediatra ou neuropediatra",
  "utm_source": "google",
  "utm_medium": "cpc",
  "utm_campaign": "...",
  "utm_content": "200634454234",
  "utm_term": "...",
  "gclid": "...",
  "fbclid": "",
  "referrer": "",
  "pagina_de_entrada": "https://despertaresi.com.br/?utm_source=google&...",
  "enviado_em": "2026-11-08T20:30:15.212Z"
}
```

- `pagina` é a nota do card no Kommo ("Home").
- O WhatsApp já vai com o 55 na frente.
- Os nomes das UTMs, do gclid e do fbclid são os dos campos de rastreio que já existem no
  Kommo da Despertar. "Quem indicou?" também já existe. "Para quem é o atendimento?"
  **ainda não existe** no Kommo e precisa ser criado.

**Sem `LEAD_WEBHOOK_URL` o formulário não finge que enviou.** A rota responde erro, a
página mostra "Não conseguimos enviar agora" com o link do WhatsApp, e nenhuma conversão
é contada. Para trocar o destino (chamar a API do Kommo direto, por exemplo), mexa só em
`src/app/api/lead/route.ts`.

| Variável | Para quê |
| --- | --- |
| `LEAD_WEBHOOK_URL` | Para onde o lead vai (POST JSON). Segredo no painel da hospedagem |
| `LEAD_WEBHOOK_TOKEN` | Opcional. Vai como `Authorization: Bearer ...` |

## Antes de ir ao ar

- [ ] **GA4:** criar a propriedade da Despertar e preencher `GA_ID` em `src/lib/medicao.ts`.
- [ ] **Destino do lead:** decidir e configurar `LEAD_WEBHOOK_URL`. Criar no Kommo o campo
      "Para quem é o atendimento?".
- [ ] **Hospedagem e deploy:** ainda não configurados. A home divide o domínio com o
      WordPress (a /lp1 continua lá até a troca), então a rota precisa servir só `/` e os
      arquivos desta base (`/imagens/`, `/_next/`, `/api/lead`, `/robots.txt`,
      `/sitemap.xml`, `/og-despertar.jpg` e os ícones).
- [ ] **Sitemap:** lista fono e TO, que precisam estar no ar junto.
- [ ] **Parte 4 do [checklist](https://github.com/genosgroup/padroes/blob/main/checklist-lp.md):**
      lead de teste real pelo celular (card no Kommo com nota, origem e os campos novos),
      conversão no Google Ads, Lead no Meta Pixel Helper, PageSpeed no celular.
- [ ] **Google Ads:** conferir se a conversão de visualização de página
      (`-BduCL3e-6saEObR1oU_`) está como principal. Se estiver, as campanhas otimizam
      para visita, e a troca para esta página vai mudar o lance.
- [ ] **Inventário:** registrar a página na planilha
      [UTMs e páginas](https://docs.google.com/spreadsheets/d/16Imi0K-b4Vb7sijtPDagR8-5IAbJ4YQ8177BRfNpAzc/edit),
      com o link da bio do Instagram (`utm_source=instagram&utm_medium=social&utm_campaign=bio`).
