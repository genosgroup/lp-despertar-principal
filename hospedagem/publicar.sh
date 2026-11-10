#!/bin/sh
# Envia a home exportada (out/, gerada por `npm run build`) para a hospedagem,
# por FTPS, e confere pelo tamanho se cada arquivo chegou inteiro. A conta FTP
# tem a raiz na public_html do site.
#
# Uso: sh hospedagem/publicar.sh   (com FTP_HOST, FTP_USER e FTP_PASSWORD no ambiente)
#
# A home divide a raiz com o WordPress. Por isso:
# - so as pastas que sao dela (_next, imagens, api/lead) sao espelhadas, com os
#   arquivos antigos apagados; na raiz, os arquivos dela sao enviados por cima,
#   sem apagar nada;
# - trava de seguranca: se alguma dessas pastas ja existir sem ter sido criada
#   por esta publicacao (sem o arquivo-marca), nada e enviado;
# - o .htaccess do WordPress so ganha o bloco de hospedagem/htaccess-raiz.conf,
#   por ultimo, depois de todos os arquivos estarem no lugar. O bloco e aplicado
#   aqui (hospedagem/aplicar-htaccess.sh) numa copia baixada; so se mudar, a
#   versao anterior vai para .htaccess.despertar-backup-<data> na raiz (nome
#   comecado por .ht: o servidor nao entrega esses arquivos pela web; ficam as
#   10 mais recentes) e a nova sobe no lugar.
set -eu
. hospedagem/ftp-comum.sh

MARCA=".publicado-pela-despertar-lp"

[ -f out/index.html ] || { echo "out/ nao existe: rode npm run build antes" >&2; exit 1; }

for d in _next imagens api/lead; do
  if ftp_existe "$d" && ! ftp_existe "$d/$MARCA"; then
    echo "A pasta $d ja existe na raiz do site e nao foi criada por esta publicacao. Nada foi enviado." >&2
    exit 1
  fi
done

for d in _next imagens api/lead; do touch "out/$d/$MARCA"; done
cp hospedagem/htaccess-next.conf out/_next/.htaccess

ftp_espelhar out/_next/ _next/ --delete
ftp_espelhar out/imagens/ imagens/ --delete
ftp_lftp "mkdir -p -f api"
ftp_espelhar out/api/lead/ api/lead/ --delete
ftp_espelhar out/ ./ -x ^_next/ -x ^imagens/ -x ^api/
echo "Arquivos da home enviados e conferidos."

# .htaccess da raiz: baixa, aplica o bloco, e so sobe se mudou.
TMP=$(mktemp -d)
mkdir -p "$TMP/raiz" "$TMP/backup"
if ftp_existe ".htaccess"; then
  ftp_lftp "get .htaccess -o $TMP/raiz/.htaccess"
fi
sh hospedagem/aplicar-htaccess.sh "$TMP/raiz" hospedagem/htaccess-raiz.conf "$TMP/backup"
ANTERIOR=$(ls "$TMP/backup" 2>/dev/null | head -1)
if [ -n "$ANTERIOR" ]; then
  NOME_BACKUP=".htaccess.despertar-backup-${ANTERIOR#htaccess-}"
  ftp_lftp "
    put $TMP/backup/$ANTERIOR -o $NOME_BACKUP
    put $TMP/raiz/.htaccess -o .htaccess
  "
  echo ".htaccess da raiz atualizado no servidor (anterior em $NOME_BACKUP)"
  # Mantem so as 10 copias mais recentes.
  ftp_lftp "cls -1 .htaccess.despertar-backup-*" 2>/dev/null | sort -r | tail -n +11 | while read -r velho; do
    ftp_lftp "rm '$velho'"
  done
fi
rm -rf "$TMP"
echo "Home publicada."
