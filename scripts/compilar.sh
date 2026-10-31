#!/usr/bin/env bash
# Compila o SmartTube Sala (variante estável) a partir do código preparado por preparar.sh.
#
# Uso: scripts/compilar.sh [--instalar]
#   --instalar  instala o APK de 32 bits na box por ADB
#
# Assinatura: SALA_KEYSTORE (caminho absoluto), SALA_KEYSTORE_PASSWORD e SALA_KEY_ALIAS.
# Neste portátil vêm de ~/.local/share/smarttube-sala/chave.env; no GitHub Actions, dos segredos.
# Os APKs ficam em $SALA_SAIDA (por omissão /opt/dev/smarttube-saida), com versao.env ao lado.
set -euo pipefail
RAIZ="$(cd "$(dirname "$0")/.." && pwd)"
SRC="${SMARTTUBE_SRC:-/opt/dev/smarttube-src}"
SAIDA="${SALA_SAIDA:-/opt/dev/smarttube-saida}"
REVISAO="$(tr -d '[:space:]' < "$RAIZ/REVISAO")"
BOX="${BOX:-192.168.1.78:5555}"

[ -f "$HOME/.local/opt/android-env.sh" ] && . "$HOME/.local/opt/android-env.sh"
[ -f "$HOME/.local/share/smarttube-sala/chave.env" ] && . "$HOME/.local/share/smarttube-sala/chave.env"
: "${SALA_KEYSTORE:?falta a chave de assinatura}" "${SALA_KEYSTORE_PASSWORD:?}" "${SALA_KEY_ALIAS:?}"

GRADLE="$SRC/smarttubetv/build.gradle"
cp "$GRADLE" "$GRADLE.orig"
trap 'mv "$GRADLE.orig" "$GRADLE"; rm -f "$SRC/keystore.properties"' EXIT

cat > "$SRC/keystore.properties" <<EOF
storeFile=$SALA_KEYSTORE
storePassword=$SALA_KEYSTORE_PASSWORD
keyAlias=$SALA_KEY_ALIAS
keyPassword=$SALA_KEYSTORE_PASSWORD
EOF
[ -n "${ANDROID_HOME:-}" ] && echo "sdk.dir=$ANDROID_HOME" > "$SRC/local.properties"

# Versão: código do SmartTube x 100 + revisão da Sala, para subir sempre que um dos dois muda.
CODIGO=$(sed -n 's/^ *versionCode \([0-9]*\).*/\1/p' "$GRADLE" | head -1)
NOME=$(sed -n 's/^ *versionName "\(.*\)".*/\1/p' "$GRADLE" | head -1)
VCODIGO=$((CODIGO * 100 + REVISAO))
VNOME="$NOME-sala$REVISAO"
sed -i "s/^\( *\)versionCode $CODIGO\b/\1versionCode $VCODIGO/; s/^\( *\)versionName \"$NOME\"/\1versionName \"$VNOME\"/" "$GRADLE"
echo "SmartTube Sala $VNOME ($VCODIGO)"

(cd "$SRC" && ./gradlew --no-daemon -q :smarttubetv:assembleStstableRelease)

mkdir -p "$SAIDA"
rm -f "$SAIDA"/*.apk
OUT="$SRC/smarttubetv/build/outputs/apk/ststable/release"
for abi in armeabi-v7a arm64-v8a; do
  cp "$(ls "$OUT"/*_"$abi".apk | head -1)" "$SAIDA/smarttube_sala_$abi.apk"
done
cat > "$SAIDA/versao.env" <<EOF
VERSAO_NOME=$VNOME
VERSAO_CODIGO=$VCODIGO
SMARTTUBE_TAG=$(cat "$SRC/.sala-tag" 2>/dev/null || echo desconhecida)
EOF
ls -la "$SAIDA"

if [ "${1:-}" = "--instalar" ]; then
  adb connect "$BOX" >/dev/null
  adb -s "$BOX" install -r "$SAIDA/smarttube_sala_armeabi-v7a.apk"
fi
