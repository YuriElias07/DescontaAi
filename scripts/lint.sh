#!/usr/bin/env bash
#
# Wrapper de SwiftLint para o projeto DescontaAi.
#
#   ./scripts/lint.sh            -> lint (erros e avisos) sem alterar arquivos
#   ./scripts/lint.sh fix        -> corrige o que o SwiftLint sabe corrigir e re-linta
#   ./scripts/lint.sh errors     -> só erros (o que bloqueia o commit)
#   ./scripts/lint.sh files a.swift ... -> lint apenas nos arquivos informados
#
set -euo pipefail

cd "$(dirname "$0")/.."

if ! command -v swiftlint >/dev/null 2>&1; then
  echo "SwiftLint não encontrado. Instale com: brew install swiftlint" >&2
  exit 127
fi

mode="${1:-check}"
shift || true

run_files=()
if [ "$#" -gt 0 ]; then
  run_files=("$@")
fi

# Arquivos Swift versionados (para "fix" global).
all_swift_files() {
  git ls-files '*.swift'
}

case "$mode" in
  fix)
    if [ "${#run_files[@]}" -gt 0 ]; then
      swiftlint --fix --quiet "${run_files[@]}"
    else
      # --fix só corrige regras autocorretíveis (espaços, newline, etc).
      swiftlint --fix --quiet
    fi
    echo "==> Revalidando..."
    swiftlint lint --quiet "${run_files[@]:-}"
    ;;

  errors)
    # --strict trata avisos como erros; sem ele, só "error" reprova.
    swiftlint lint --quiet "${run_files[@]:-}"
    ;;

  check | "")
    swiftlint lint "${run_files[@]:-}"
    ;;

  *)
    echo "Uso: $0 [check|fix|errors] [arquivos...]" >&2
    exit 2
    ;;
esac
