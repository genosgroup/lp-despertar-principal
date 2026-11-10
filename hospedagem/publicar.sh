#!/bin/sh
# Envia a home exportada (out/, gerada por `npm run build`) para a hospedagem.
#
# Uso: sh hospedagem/publicar.sh <alvo> <raiz> <aux>
#   alvo: "destino" na publicacao pelo GitHub (servidor do ~/.ssh/config) ou
#         "local" para testar numa pasta do proprio computador
#   raiz: pasta raiz do site no servidor (ex.: public_html, relativa a pasta do
#         usuario) ou, em "local", o caminho da pasta de teste
#   aux:  pasta FORA da raiz para o script do .htaccess e os backups dele
#         (ex.: despertar-lp-publicacao)
#
# A home divide a raiz com o WordPress. Por isso:
# - so as pastas que sao dela (_next, imagens, api/lead) sao espelhadas, com os
#   arquivos antigos apagados; na raiz, os arquivos dela sao enviados por cima,
#   sem apagar nada;
# - trava de seguranca: se alguma dessas pastas ja existir sem ter sido criada
#   por esta publicacao (sem o arquivo-marca), nada e enviado;
# - o .htaccess do WordPress so ganha o bloco de hospedagem/htaccess-raiz.conf,
#   por ultimo, depois de todos os arquivos estarem no lugar (o "/" so passa a
#   abrir a home nova quando ela ja esta inteira la).
set -eu

ALVO="$1"
RAIZ="$2"
AUX="$3"
MARCA=".publicado-pela-despertar-lp"

if [ "$ALVO" = "local" ]; then
  no_alvo() { sh -c "$1"; }
  DESTINO="$RAIZ"
  DESTINO_AUX="$AUX"
else
  no_alvo() { ssh "$ALVO" "$1"; }
  DESTINO="$ALVO:$RAIZ"
  DESTINO_AUX="$ALVO:$AUX"
fi

[ -f out/index.html ] || { echo "out/ nao existe: rode npm run build antes" >&2; exit 1; }

no_alvo "cd '$RAIZ' && for d in _next imagens api/lead; do if [ -d \"\$d\" ] && [ ! -f \"\$d/$MARCA\" ]; then echo \"A pasta \$d ja existe na raiz do site e nao foi criada por esta publicacao. Nada foi enviado.\" >&2; exit 1; fi; done"

for d in _next imagens api/lead; do touch "out/$d/$MARCA"; done
cp hospedagem/htaccess-next.conf out/_next/.htaccess

rsync -rlptz --delete out/_next/ "$DESTINO/_next/"
rsync -rlptz --delete out/imagens/ "$DESTINO/imagens/"
rsync -rlptz out/api/ "$DESTINO/api/"
rsync -rlptz --delete out/api/lead/ "$DESTINO/api/lead/"
rsync -rlptz --exclude=/_next/ --exclude=/imagens/ --exclude=/api/ out/ "$DESTINO/"

no_alvo "mkdir -p '$AUX'"
rsync -rlptz hospedagem/aplicar-htaccess.sh hospedagem/htaccess-raiz.conf "$DESTINO_AUX/"
no_alvo "sh '$AUX/aplicar-htaccess.sh' '$RAIZ' '$AUX/htaccess-raiz.conf' '$AUX/backup-htaccess'"
echo "Home publicada na raiz de $RAIZ"
