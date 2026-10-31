#!/usr/bin/env bash
# Publica uma compilação no GitHub.
#   - uma release com o nome da versão (histórico);
#   - a release "latest", com os APKs e o smarttube_sala.json que o atualizador da app lê.
#
# Uso: scripts/publicar.sh <pasta_saida> <tag_release>
set -euo pipefail
SAIDA="$1"; TAG_REL="$2"
REPO="${GITHUB_REPOSITORY:-danifstech/smarttube-sala}"
. "$SAIDA/versao.env"
BASE="https://github.com/$REPO/releases/download/latest"

# Formato lido pelo appupdatechecker2 do SmartTube: compara o versionCode e mostra o nome.
python3 - "$BASE" "$VERSAO_NOME" "$VERSAO_CODIGO" "$SMARTTUBE_TAG" > "$SAIDA/smarttube_sala.json" <<'EOF'
import json, sys
base, nome, codigo, tag = sys.argv[1:]
print(json.dumps({
    "package": {
        "downloadUrlList": [f"{base}/smarttube_sala_armeabi-v7a.apk"],
        "downloadUrlList_arm64-v8a": [f"{base}/smarttube_sala_arm64-v8a.apk"],
    },
    nome: {
        "versionCode": int(codigo),
        "changelog": [f"Atualizado para o SmartTube {tag}, com o estilo da Sala."],
    },
}, indent=2, ensure_ascii=False))
EOF

gh release create "$TAG_REL" --repo "$REPO" --title "SmartTube Sala $VERSAO_NOME" \
  --notes "Baseado no SmartTube $SMARTTUBE_TAG." --latest=false "$SAIDA"/*.apk

if ! gh release view latest --repo "$REPO" >/dev/null 2>&1; then
  gh release create latest --repo "$REPO" --title "Versão atual (usada pelo atualizador)" \
    --notes "Não apagar: o SmartTube Sala procura atualizações nesta release." --latest
fi
# APKs primeiro e o manifesto no fim, para a app nunca ver uma versão sem o APK correspondente.
gh release upload latest --repo "$REPO" --clobber "$SAIDA"/*.apk
gh release upload latest --repo "$REPO" --clobber "$SAIDA/smarttube_sala.json"
echo "Publicado: $VERSAO_NOME ($VERSAO_CODIGO)"
