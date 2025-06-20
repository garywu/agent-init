# Makefile for professional development workflow

.PHONY: help
help: ## Show this help message
	@echo 'Usage: make [target]'
	@echo ''
	@echo 'Targets:'
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "  %-15s %s\n", $$1, $$2}' $(MAKEFILE_LIST)

# Enhanced Session Management
.PHONY: session-start
session-start: ## Start tracked development session with project analysis
	@./scripts/session/session-start.sh

.PHONY: session-end
session-end: ## End session with comprehensive summary
	@./scripts/session/session-end.sh

.PHONY: session-status
session-status: ## Show current session status and recent activities
	@./scripts/session/session-status.sh

.PHONY: session-log
session-log: ## Log activity to current session (usage: make session-log MSG="message")
	@if [ -z "$(MSG)" ]; then echo "Usage: make session-log MSG=\"your message\""; exit 1; fi
	@./scripts/session/session-log.sh "$(MSG)"

.PHONY: session-health
session-health: ## Run project health check and update session
	@./scripts/project-detector.sh . human && \
	./scripts/session/session-log.sh "Ran project health check" "analysis"

# GitHub Integration
.PHONY: github-link
github-link: ## Link current session to GitHub issues
	@./scripts/github-integration.sh link-issues

.PHONY: github-sync
github-sync: ## Sync session with recent commits
	@./scripts/github-integration.sh link-commits

.PHONY: pr-gen
pr-gen: ## Generate PR description from session
	@./scripts/github-integration.sh pr-description

.PHONY: init
init: ## Initialize project dependencies
	@echo "Initializing project..."
	@if [ -f requirements.txt ]; then pip install -r requirements.txt; fi
	@if [ -f package.json ]; then npm install; fi
	@pre-commit install
	@echo "Project initialized!"

.PHONY: lint
lint: ## Run all linters
	@echo "Running linters..."
	@pre-commit run --all-files

.PHONY: format
format: ## Format all code
	@echo "Formatting code..."
	@if command -v black >/dev/null 2>&1; then black .; fi
	@if command -v isort >/dev/null 2>&1; then isort .; fi
	@if command -v prettier >/dev/null 2>&1; then prettier --write .; fi

.PHONY: test
test: ## Run tests
	@echo "Running tests..."
	@if [ -f pytest.ini ] || [ -f setup.cfg ] || [ -f tox.ini ]; then pytest; \
	elif [ -f package.json ]; then npm test; \
	elif [ -f Cargo.toml ]; then cargo test; \
	elif [ -f go.mod ]; then go test ./...; \
	else echo "No test configuration found"; fi

.PHONY: test-coverage
test-coverage: ## Run tests with coverage
	@echo "Running tests with coverage..."
	@if command -v pytest >/dev/null 2>&1; then pytest --cov=. --cov-report=html --cov-report=term; \
	elif [ -f package.json ]; then npm run test:coverage; \
	else echo "Coverage not configured"; fi

.PHONY: build
build: ## Build the project
	@echo "Building project..."
	@if [ -f setup.py ]; then python setup.py build; \
	elif [ -f package.json ]; then npm run build; \
	elif [ -f Cargo.toml ]; then cargo build --release; \
	elif [ -f go.mod ]; then go build ./...; \
	else echo "No build configuration found"; fi

.PHONY: clean
clean: ## Clean build artifacts
	@echo "Cleaning build artifacts..."
	@find . -type d -name "__pycache__" -exec rm -rf {} + 2>/dev/null || true
	@find . -type f -name "*.pyc" -delete 2>/dev/null || true
	@find . -type d -name "*.egg-info" -exec rm -rf {} + 2>/dev/null || true
	@find . -type d -name ".pytest_cache" -exec rm -rf {} + 2>/dev/null || true
	@find . -type d -name ".coverage" -exec rm -rf {} + 2>/dev/null || true
	@find . -type d -name "htmlcov" -exec rm -rf {} + 2>/dev/null || true
	@find . -type d -name "node_modules" -exec rm -rf {} + 2>/dev/null || true
	@find . -type d -name "dist" -exec rm -rf {} + 2>/dev/null || true
	@find . -type d -name "build" -exec rm -rf {} + 2>/dev/null || true
	@find . -type d -name "target" -exec rm -rf {} + 2>/dev/null || true
	@echo "Clean complete!"

.PHONY: docs
docs: ## Build documentation
	@echo "Building documentation..."
	@if [ -f mkdocs.yml ]; then mkdocs build; \
	elif [ -f docs/conf.py ]; then cd docs && make html; \
	elif [ -f package.json ]; then npm run docs; \
	else echo "No documentation configuration found"; fi

.PHONY: docs-serve
docs-serve: ## Serve documentation locally
	@echo "Serving documentation..."
	@if [ -f mkdocs.yml ]; then mkdocs serve; \
	elif [ -f docs/conf.py ]; then cd docs && make livehtml; \
	else echo "No documentation configuration found"; fi

.PHONY: security
security: ## Run security checks
	@echo "Running security checks..."
	@if command -v bandit >/dev/null 2>&1; then bandit -r . -f json -o bandit-report.json; fi
	@if command -v safety >/dev/null 2>&1; then safety check; fi
	@if command -v npm >/dev/null 2>&1 && [ -f package.json ]; then npm audit; fi
	@if command -v cargo >/dev/null 2>&1 && [ -f Cargo.toml ]; then cargo audit; fi
	@echo "Security checks complete!"

.PHONY: update-deps
update-deps: ## Update dependencies
	@echo "Updating dependencies..."
	@if [ -f requirements.txt ]; then pip install --upgrade -r requirements.txt; fi
	@if [ -f package.json ]; then npm update; fi
	@if [ -f Cargo.toml ]; then cargo update; fi
	@if [ -f go.mod ]; then go get -u ./...; fi
	@echo "Dependencies updated!"

.PHONY: pre-commit
pre-commit: ## Run pre-commit hooks
	@pre-commit run --all-files

.PHONY: install-hooks
install-hooks: ## Install git hooks
	@pre-commit install
	@pre-commit install --hook-type commit-msg
	@echo "Git hooks installed!"

.PHONY: changelog
changelog: ## Generate changelog
	@echo "Generating changelog..."
	@if command -v conventional-changelog >/dev/null 2>&1; then \
		conventional-changelog -p angular -i CHANGELOG.md -s; \
	else \
		echo "conventional-changelog not installed"; \
	fi

.PHONY: release
release: ## Create a new release
	@echo "Creating release..."
	@if command -v semantic-release >/dev/null 2>&1; then \
		semantic-release; \
	else \
		echo "semantic-release not installed"; \
	fi

.PHONY: issue
issue: ## Create a new GitHub issue
	@gh issue create

.PHONY: pr
pr: ## Create a pull request with session context
	@if [ -f .claude/session.json ]; then \
		./scripts/github-integration.sh pr-description > .pr-description.tmp && \
		gh pr create --body-file .pr-description.tmp && \
		rm -f .pr-description.tmp; \
	else \
		gh pr create; \
	fi

.PHONY: todo
todo: ## Show all TODO items in code
	@echo "Finding TODO items..."
	@rg "TODO|FIXME|HACK|BUG" --type-not md || echo "No TODO items found"

.PHONY: stats
stats: ## Show code statistics
	@echo "Code statistics:"
	@if command -v tokei >/dev/null 2>&1; then tokei; \
	elif command -v cloc >/dev/null 2>&1; then cloc .; \
	else echo "No code statistics tool found"; fi

.PHONY: check
check: lint test security ## Run all checks (lint, test, security)
	@echo "All checks passed!"

.PHONY: all
all: clean init format lint test build docs ## Run full pipeline

# Default target
.DEFAULT_GOAL := help