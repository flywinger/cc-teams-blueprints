# Team Blueprints Framework — Installer
#
# Usage:
#   make list
#   make install TARGET=../my-project BLUEPRINT=newsletter
#   make install TARGET=../my-project BLUEPRINT="newsletter example-team"
#   make install TARGET=../my-project BLUEPRINT=newsletter FORCE=1
#   make install TARGET=../my-project BLUEPRINT=newsletter NO_CLAUDE_MD=1

.PHONY: install list help

TARGET ?=
BLUEPRINT ?=
FORCE ?=
NO_CLAUDE_MD ?=

help: ## Show available targets
	@echo "Team Blueprints Framework — Installer"
	@echo ""
	@echo "Targets:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  %-12s %s\n", $$1, $$2}'
	@echo ""
	@echo "Variables:"
	@echo "  TARGET       Target project directory (required for install)"
	@echo "  BLUEPRINT    Blueprint name(s) to install, space-separated"
	@echo "  FORCE=1      Overwrite existing files without prompting"
	@echo "  NO_CLAUDE_MD=1  Skip CLAUDE.md setup"
	@echo ""
	@echo "Examples:"
	@echo "  make list"
	@echo "  make install TARGET=../my-project BLUEPRINT=newsletter"
	@echo '  make install TARGET=../my-project BLUEPRINT="newsletter example-team"'

list: ## List available blueprints
	@./install.sh --list

install: ## Install framework + blueprints into TARGET
ifndef TARGET
	$(error TARGET is required. Usage: make install TARGET=../my-project BLUEPRINT=newsletter)
endif
	@args=""; \
	for bp in $(BLUEPRINT); do \
		args="$$args --blueprint=$$bp"; \
	done; \
	if [ "$(FORCE)" = "1" ]; then args="$$args --force"; fi; \
	if [ "$(NO_CLAUDE_MD)" = "1" ]; then args="$$args --no-claude-md"; fi; \
	./install.sh $(TARGET) $$args
