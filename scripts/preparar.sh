#!/usr/bin/env bash
# Descarrega uma versão estável do SmartTube e aplica as alterações da Sala (patches/sala.patch).
#
# Uso: scripts/preparar.sh [tag] [pasta]
#   tag    versão estável do SmartTube (por omissão, a mais recente)
#   pasta  onde pôr o código (por omissão, $SMARTTUBE_SRC ou /opt/dev/smarttube-src)
#
# Recusa apagar uma pasta com alterações por guardar; usar FORCAR=1 para apagar mesmo assim.
set -euo pipefail
RAIZ="$(cd "$(dirname "$0")/.." && pwd)"
TAG="${1:-$("$RAIZ/scripts/ultima_estavel.sh")}"
DEST="${2:-${SMARTTUBE_SRC:-/opt/dev/smarttube-src}}"
PATCH="$RAIZ/patches/sala.patch"

if [ -d "$DEST/.git" ] && [ "${FORCAR:-0}" != 1 ] && [ -n "$(git -C "$DEST" status --porcelain)" ]; then
  echo "Erro: $DEST tem alterações. Guarda-as com scripts/guardar_patch.sh ou usa FORCAR=1." >&2
  exit 1
fi

echo "SmartTube $TAG -> $DEST"
rm -rf "$DEST"
git clone -q --depth 1 --branch "$TAG" --recurse-submodules --shallow-submodules \
  https://github.com/yuliskov/SmartTube.git "$DEST"
chmod +x "$DEST/gradlew"
git -C "$DEST" config core.fileMode false
printf '%s\n' local.properties keystore.properties .sala-tag >> "$DEST/.git/info/exclude"

if [ -s "$PATCH" ]; then
  git -C "$DEST" apply --whitespace=nowarn "$PATCH"
  echo "Patch aplicado."
fi
echo "$TAG" > "$DEST/.sala-tag"
