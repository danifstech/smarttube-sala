#!/usr/bin/env bash
# Guarda em patches/sala.patch todas as alterações feitas ao código do SmartTube.
# Uso: scripts/guardar_patch.sh [pasta]   (por omissão, $SMARTTUBE_SRC ou /opt/dev/smarttube-src)
set -euo pipefail
RAIZ="$(cd "$(dirname "$0")/.." && pwd)"
SRC="${1:-${SMARTTUBE_SRC:-/opt/dev/smarttube-src}}"

# Ficheiros novos entram no patch sem ficarem no índice.
# (local.properties, keystore.properties e .sala-tag estão em .git/info/exclude, por isso ficam de fora.)
git -C "$SRC" add --intent-to-add --all
git -C "$SRC" diff --binary HEAD > "$RAIZ/patches/sala.patch"
git -C "$SRC" reset -q

echo "patches/sala.patch: $(grep -c '^diff --git' "$RAIZ/patches/sala.patch") ficheiros alterados"
