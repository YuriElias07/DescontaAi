SHELL := /bin/bash

.PHONY: help lint lint-fix lint-errors hooks setup

help: ## Lista os alvos disponíveis
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-12s\033[0m %s\n", $$1, $$2}'

lint: ## Roda o SwiftLint (erros + avisos)
	@./scripts/lint.sh check

lint-fix: ## Corrige automaticamente o que o SwiftLint sabe corrigir
	@./scripts/lint.sh fix

lint-errors: ## Mostra apenas os erros (bloqueiam o commit)
	@./scripts/lint.sh errors

hooks: ## Instala o hook de pre-commit (git config core.hooksPath)
	@git config core.hooksPath .githooks
	@echo "✅ Hooks instalados. Agora todo commit roda o SwiftLint automaticamente."

setup: hooks ## Instala hooks e roda a primeira limpeza
	@./scripts/lint.sh fix || true
