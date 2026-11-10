# Clínica Despertar · página principal

A página inicial do site da Clínica Despertar (`despertaresi.com.br/`), em Next.js,
publicada como site estático na Turbo Cloud. Ela substitui a home do WordPress, que
continua no ar para o resto do site.

- **Conteúdo:** o pacote aprovado `pacote-wordpress-despertar-v2.zip`, anexo da tarefa
  [[Despertar] Subir as 3 páginas novas do site](https://app.clickup.com/t/17tkuw63mv7).
- **Prévia aprovada:** [Principal](https://claude.ai/artifact/DFxizHUCcpNYUvfKUohzWc).
  A página gerada aqui foi comparada pixel a pixel com essa prévia, no celular (390 px)
  e no desktop (1280 px): sem diferença.
- **Padrão Genos:** começou do `template-lp/` de
  [genosgroup/padroes](https://github.com/genosgroup/padroes). Antes de mexer em medição,
  leia o `AGENTS.md`: esta é uma LP de **cliente**, e os IDs são os da Despertar.

Fono (`/fonoaudiologia-salvador/`) e TO (`/terapia-ocupacional-salvador/`) ficam em
repositórios próprios, com os mesmos componentes.

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

`npm run build` gera o site inteiro em `out/`, pronto para publicar.

Em `npm run dev` o formulário não envia: quem recebe o lead é um arquivo PHP
(`public/api/lead/index.php`), e o `next dev` não roda PHP. Assim ninguém cria card de
teste no Kommo sem querer. Para testar o envio de ponta a ponta, depois do build:

```bash
LEAD_WEBHOOK_URL=https://seu-webhook-de-teste php -S 127.0.0.1:8080 -t out
```

## Onde está cada coisa

| Arquivo | O que é |
| --- | --- |
| `conteudo/pagina.html` e `conteudo/dsp-lp.css` | O HTML (o `home.html` do pacote) e o CSS, **idênticos ao aprovado**. Não edite à mão |
| `public/imagens/` | As 11 imagens do pacote que a home usa, com os nomes originais (as de fono e TO ficam nos repositórios delas) |
| `src/components/PaginaDoPacote.tsx` | Transforma o HTML do pacote na página e troca só o que dependia do WordPress |
| `src/components/Formulario.tsx` | O formulário "Primeira conversa", com a marcação da prévia aprovada |
| `src/components/BotaoFixo.tsx` | O botão fixo do celular, que some no topo e no formulário |
| `public/api/lead/index.php` | Recebe o lead, valida e repassa para o webhook do n8n. Igual nas três páginas |
| `public/api/lead/pagina.php` | O nome da página no Kommo ("Home") e o webhook desta página |
| `src/lib/site.ts` | O que muda de uma página da Despertar para outra: caminho, endereço, foto do topo |
| `src/lib/lead.ts` | Campos, opções e validação do formulário (a pergunta de idade muda por página) |
| `src/lib/medicao.ts` | **Todos os IDs de medição**, num lugar só. Vazio = desligado |
| `src/lib/conversao.ts` | Os eventos de Lead e Contato |
| `src/components/Tracking.tsx` | As tags (Google, Meta e Clarity), montadas no layout raiz |
| `src/app/page.tsx` | Title, description, Open Graph e os dados da clínica para a busca local |
| `src/app/sitemap.ts` e `public/robots.txt` | Do domínio inteiro, porque esta é a raiz |
| `src/app/globals.css` | O pouco que o tema do WordPress fazia, mais os estilos de erro do formulário |
| `hospedagem/` | Os scripts da publicação e o bloco do `.htaccess` da raiz (ver abaixo) |
| `.github/workflows/` | As automações de publicação e de teste de conexão |

### Pacote novo

1. Troque `conteudo/pagina.html` (o `home.html` do pacote) e `conteudo/dsp-lp.css` pelos
   novos e as imagens em `public/imagens/`.
2. Confira se os ids `dsp-form-slot`, `dsp-ok` e `dsp-fixo` continuam no HTML. É neles
   que o formulário e o botão fixo se encaixam.
3. `npm run build` e compare com a prévia nova.

## Publicação (Turbo Cloud)

A hospedagem é a **Turbo Cloud** (cPanel, CloudLinux e LiteSpeed), a mesma do WordPress
da Despertar. A página vai como **arquivos estáticos**, sem Node: o LiteSpeed serve os
arquivos direto, e o único pedaço dinâmico, o envio do lead, é um PHP pequeno.

**Como publicar:** em **Actions > Publicar na Turbo Cloud > Run workflow**. A automação
roda `npm run build` e envia o `out/` por SSH com `hospedagem/publicar.sh`. Por enquanto
ela só roda quando alguém dispara; depois da estreia, ela pode passar a rodar a cada push
no `main`.

**Convivência com o WordPress.** A home divide a raiz do site (`public_html`) com ele:

- só as pastas que são dela (`_next`, `imagens`, `api/lead`) são espelhadas, com os
  arquivos antigos apagados. Na raiz, os arquivos dela são enviados por cima, **sem
  apagar nada**;
- **trava de segurança:** se alguma dessas pastas já existir sem ter sido criada por esta
  publicação, nada é enviado;
- o `.htaccess` da raiz, que é do WordPress, só ganha o bloco de
  `hospedagem/htaccess-raiz.conf`, no topo, entre as marcas
  `# BEGIN/END Despertar LP principal`. É ele que faz o `/` abrir a home nova
  (`DirectoryIndex index.html index.php`). O resto do arquivo não é tocado, uma cópia vai
  para `~/despertar-lp-publicacao/backup-htaccess` (fora da pasta pública, 10 mais
  recentes) e o bloco só é aplicado depois de todos os arquivos estarem no lugar;
- todo endereço que não é arquivo nem pasta desta página continua indo para o WordPress:
  /lp1, as páginas antigas, o painel.

Os redirecionamentos da troca de 16/11 (/lp1 e /primeira-visita para fono e TO) entram
nesse mesmo bloco, em `hospedagem/htaccess-raiz.conf`, e vão ao ar com uma publicação.

**Segredos** (em **Settings > Secrets and variables > Actions**, iguais nos três
repositórios da Despertar):

| Segredo | O que é |
| --- | --- |
| `DESPERTAR_SSH_KEY` | Chave privada gerada no cPanel (Acesso SSH > Gerenciar chaves), com as linhas BEGIN/END |
| `DESPERTAR_SSH_PASSPHRASE` | A senha da chave. O cPanel não gera chave sem senha; a automação tira a senha só na máquina temporária do GitHub |
| `DESPERTAR_SSH_HOST` | O servidor (`br.brasil105-9070.com.br`) |
| `DESPERTAR_SSH_USER` | O usuário do cPanel |
| `DESPERTAR_SSH_PORT` | A porta SSH (pode ser variável em vez de segredo; sem ela, 22) |

Se a raiz do site não for `public_html`, crie a variável `DESPERTAR_RAIZ`.

**Testar a conexão:** **Actions > Testar conexão com a Turbo Cloud > Run workflow**
entra no servidor, confere rsync, PHP, a raiz do site e o que já existe nela, e não
publica nada. O log mostra só sim/não, sem listar arquivos, porque o log de um
repositório público é público.

O caminho inteiro (chave com senha, SSH, rsync, `.htaccess`, convivência com um
WordPress, envio do lead pelo PHP) foi testado num servidor local montado como o da
Turbo Cloud antes da primeira publicação.

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

O formulário manda o lead para `/api/lead/` (o `public/api/lead/index.php`), que valida e
repassa para uma **automação no n8n**, que cria o card no Kommo. O webhook desta página
é `https://webhook.automacaogenosgroup.com.br/webhook/despertar-lp-principal`, em
`public/api/lead/pagina.php`. Fono e TO têm o seu, terminando em `despertar-lp-fono` e
`despertar-lp-to`. O JSON:

```json
{
  "pagina": "Home",
  "nome": "Maria",
  "whatsapp": "5571999990000",
  "idade": "Criança de 2 a 4",
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
  "enviado_em": "2026-11-08T20:30:15Z"
}
```

- `pagina` é a nota do card no Kommo ("Home"; em fono é "LP Fono" e em TO, "LP TO").
- `idade` vai para o campo **"Idade da criança"** do Kommo, o mesmo nas três páginas,
  como diz a tarefa. Aqui a pergunta é "Para quem é o atendimento?", porque a principal
  também atende adulto e idoso. Esse campo **ainda não existe** no Kommo e precisa ser
  criado.
- O JSON é o mesmo nas três páginas, então a automação trata as três do mesmo jeito.
- O WhatsApp já vai com o 55 na frente.
- Os nomes das UTMs, do gclid e do fbclid são os dos campos de rastreio que já existem no
  Kommo da Despertar. "Quem indicou?" também já existe.

**Se o envio falhar, o formulário não finge que enviou.** O PHP responde erro, a página
mostra "Não conseguimos enviar agora" com o link do WhatsApp, e nenhuma conversão é
contada.

**Proteção do webhook.** O endereço está escrito no código, e este repositório é
público: quem o encontrar consegue mandar lead falso para o n8n e, de lá, para o Kommo.
Para fechar isso:

1. ligue a autenticação por cabeçalho (Header Auth) no nó de webhook do n8n, com
   `Authorization` e o valor `Bearer <senha>`;
2. no cPanel, crie o arquivo `.despertar-lp.php` na pasta do usuário, **fora** da
   `public_html` (Gerenciador de Arquivos), com:

   ```php
   <?php
   return ['token' => '<senha>'];
   ```

O PHP manda o cabeçalho sempre que esse arquivo existe. A senha não vai para o GitHub
nem fica acessível pela web, e vale para as três páginas.

## Antes de ir ao ar

- [ ] **GA4:** criar a propriedade da Despertar e preencher `GA_ID` em `src/lib/medicao.ts`.
- [ ] **Automação do n8n:** montar os três webhooks (`despertar-lp-principal`, `-fono`,
      `-to`) e protegê-los (ver acima). Criar no Kommo o campo "Idade da criança".
- [ ] **Publicar a home só depois do n8n pronto:** publicar substitui a home do
      WordPress na hora, e sem o webhook todo visitante veria o formulário falhar.
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
- [ ] **PHP do site:** o WordPress roda em PHP 7.4, sem atualização de segurança desde
      2022. O PHP do lead é compatível com ele, mas vale subir a versão.
