#!/bin/sh
# Coloca (ou atualiza) o bloco "Despertar LP principal" no topo do .htaccess da
# raiz do site, sem mexer no resto do arquivo, que e do WordPress.
#
# Uso: sh aplicar-htaccess.sh <pasta-raiz-do-site> <arquivo-do-bloco> <pasta-de-backup>
#
# - So grava se o resultado for diferente do atual.
# - Antes de gravar, guarda uma copia do .htaccess atual na pasta de backup
#   (fora da pasta publica) e mantem as 10 mais recentes.
# - Grava num arquivo temporario e troca de uma vez, para o site nunca ler um
#   .htaccess pela metade.
set -eu

RAIZ="$1"
BLOCO="$2"
BACKUP="$3"
INICIO="# BEGIN Despertar LP principal"
FIM="# END Despertar LP principal"

[ -d "$RAIZ" ] || { echo "pasta raiz nao encontrada: $RAIZ" >&2; exit 1; }
[ -f "$BLOCO" ] || { echo "bloco nao encontrado: $BLOCO" >&2; exit 1; }
grep -qx "$INICIO" "$BLOCO" && grep -qx "$FIM" "$BLOCO" || { echo "bloco sem as marcas de inicio e fim" >&2; exit 1; }

ATUAL="$RAIZ/.htaccess"
NOVO="$RAIZ/.htaccess.despertar-novo"
[ -f "$ATUAL" ] || : > "$ATUAL"

# Se ja existir um inicio sem fim, alguem mexeu no bloco a mao: para tudo.
if grep -qx "$INICIO" "$ATUAL" && ! grep -qx "$FIM" "$ATUAL"; then
  echo ".htaccess tem o inicio do bloco sem o fim; nada foi alterado" >&2
  exit 1
fi

{
  cat "$BLOCO"
  echo
  awk -v ini="$INICIO" -v fim="$FIM" '
    $0 == ini { pula = 1; next }
    $0 == fim { pula = 0; tirou = 1; next }
    pula { next }
    tirou && !mostrou && $0 == "" { next }  # tira a linha em branco que vinha depois do bloco antigo
    { mostrou = 1; print }
  ' "$ATUAL"
} > "$NOVO"

if cmp -s "$ATUAL" "$NOVO"; then
  rm -f "$NOVO"
  echo ".htaccess da raiz ja estava atualizado"
  exit 0
fi

mkdir -p "$BACKUP"
cp "$ATUAL" "$BACKUP/htaccess-$(date +%Y%m%d-%H%M%S)"
ls -1t "$BACKUP"/htaccess-* 2>/dev/null | tail -n +11 | while read -r velho; do rm -f "$velho"; done
mv "$NOVO" "$ATUAL"
echo ".htaccess da raiz atualizado (copia anterior em $BACKUP)"
