#!/usr/bin/env bash
# Mostra a tag da última versão estável do SmartTube (as estáveis acabam em "s", por exemplo 32.68s).
set -euo pipefail
git ls-remote --tags --refs https://github.com/yuliskov/SmartTube.git \
  | sed -n 's|.*refs/tags/\([0-9][0-9.]*s\)$|\1|p' \
  | sort -V | tail -1
