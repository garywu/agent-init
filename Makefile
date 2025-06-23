# claude-init Makefile

.PHONY: help fix-shell lint lint-shell format check

# Default target
help:
	@echo "Available targets:"
	@echo "  make fix-shell    - Fix common shell script issues automatically"
	@echo "  make lint         - Run all linters"
	@echo "  make lint-shell   - Run shellcheck on shell scripts"
	@echo "  make format       - Run all formatters"
	@echo "  make check        - Run all checks (lint + format)"

# Fix shell script issues automatically
fix-shell:
	@echo "🔧 Fixing shell script issues..."
	@./scripts/fix-shell-issues.sh || true

# Linting targets
lint: lint-shell

lint-shell:
	@echo "🔍 Linting shell scripts..."
	@find . -type f -name "*.sh" -not -path "./.git/*" -exec shellcheck {} \; || true

# Formatting targets
format:
	@echo "📝 Formatting shell scripts..."
	@find . -type f -name "*.sh" -not -path "./.git/*" -exec shfmt -w {} \; || true

# Combined check
check: lint format
	@echo "✅ All checks complete!"