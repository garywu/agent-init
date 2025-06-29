# Makefile Patterns for Modern Development

## Overview

This guide captures advanced Makefile patterns that enhance developer experience, automate workflows, and provide intelligent project management. These patterns come from production usage and solve real development challenges.

## Core Principles

1. **Self-Documenting**: Every target should have a help description
2. **Intelligent Detection**: Detect project type and available tools
3. **Fail Gracefully**: Check for dependencies before running
4. **Composable**: Targets should work together
5. **Developer-Friendly**: Common tasks should be simple

## Essential Patterns

### 1. Self-Documenting Help System

Make your Makefile discoverable with automatic help generation:

```makefile
.PHONY: help
help: ## Show this help message
	@echo 'Usage: make [target]'
	@echo ''
	@echo 'Targets:'
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "  %-15s %s\n", $$1, $$2}' $(MAKEFILE_LIST)

.DEFAULT_GOAL := help
```

Usage:
```bash
$ make
Usage: make [target]

Targets:
  help            Show this help message
  dev             Start development server
  test            Run tests
  build           Build for production
```

### 2. Session Management Pattern

Track development sessions for better context and history:

```makefile
# Session Management
.PHONY: session-start
session-start: ## Start tracked development session
	@echo "Starting development session..."
	@mkdir -p .session
	@echo "{\"start\": \"$$(date -u +%Y-%m-%dT%H:%M:%SZ)\", \"id\": \"session-$$(date +%s)\"}" > .session/current.json
	@echo "Session started. ID: session-$$(date +%s)"

.PHONY: session-end
session-end: ## End current session with summary
	@if [ -f .session/current.json ]; then \
		echo "Ending session..."; \
		echo "Duration: $$(node -p "Math.round((Date.now() - new Date(JSON.parse(require('fs').readFileSync('.session/current.json')).start).getTime()) / 60000) + ' minutes'")"; \
		git log --oneline --since="$$(jq -r .start .session/current.json)" | head -10; \
		rm -f .session/current.json; \
	else \
		echo "No active session"; \
	fi

.PHONY: session-status
session-status: ## Show current session status
	@if [ -f .session/current.json ]; then \
		cat .session/current.json | jq .; \
	else \
		echo "No active session"; \
	fi

.PHONY: session-log
session-log: ## Log activity (usage: make session-log MSG="message")
	@if [ -z "$(MSG)" ]; then \
		echo "Usage: make session-log MSG=\"your message\""; \
		exit 1; \
	fi
	@if [ -f .session/current.json ]; then \
		echo "$$(date +%Y-%m-%d\ %H:%M:%S) - $(MSG)" >> .session/log.txt; \
		echo "Logged: $(MSG)"; \
	else \
		echo "No active session. Start one with 'make session-start'"; \
	fi
```

### 3. GitHub Integration Pattern

Integrate with GitHub for seamless workflow:

```makefile
# GitHub Integration
.PHONY: issue
issue: ## Create a new GitHub issue
	@gh issue create

.PHONY: pr
pr: ## Create a pull request
	@gh pr create

.PHONY: pr-gen
pr-gen: ## Generate PR description from session
	@if [ -f .session/current.json ]; then \
		echo "## Changes in this PR\n"; \
		echo "### Commits"; \
		git log --oneline --since="$$(jq -r .start .session/current.json)"; \
		echo "\n### Session Log"; \
		if [ -f .session/log.txt ]; then cat .session/log.txt; fi; \
	else \
		echo "No session data available"; \
	fi | gh pr create --body-file -

.PHONY: issues-link
issues-link: ## Link commits to issues
	@echo "Recent commits and their issues:"
	@git log --oneline -10 | grep -oE '#[0-9]+' | sort -u | while read issue; do \
		echo "$$issue: $$(gh issue view $$issue --json title -q .title 2>/dev/null || echo 'Not found')"; \
	done
```

### 4. Multi-Language Detection Pattern

Intelligently detect and run appropriate commands:

```makefile
# Language Detection
.PHONY: test
test: ## Run tests (auto-detects test framework)
	@echo "Running tests..."
	@if [ -f pytest.ini ] || [ -f setup.cfg ] || [ -f tox.ini ]; then \
		pytest; \
	elif [ -f package.json ] && grep -q '"test"' package.json; then \
		npm test; \
	elif [ -f Cargo.toml ]; then \
		cargo test; \
	elif [ -f go.mod ]; then \
		go test ./...; \
	elif [ -f composer.json ]; then \
		./vendor/bin/phpunit; \
	elif [ -f Gemfile ] && grep -q 'rspec' Gemfile; then \
		bundle exec rspec; \
	else \
		echo "No test configuration found"; \
		exit 1; \
	fi

.PHONY: lint
lint: ## Run linters (auto-detects available linters)
	@echo "Running linters..."
	@if [ -f .pre-commit-config.yaml ]; then \
		pre-commit run --all-files; \
	else \
		if command -v ruff >/dev/null 2>&1 && [ -f pyproject.toml ]; then ruff check .; fi; \
		if command -v eslint >/dev/null 2>&1 && [ -f .eslintrc* ]; then eslint .; fi; \
		if command -v golangci-lint >/dev/null 2>&1 && [ -f go.mod ]; then golangci-lint run; fi; \
	fi

.PHONY: format
format: ## Format code (auto-detects formatters)
	@echo "Formatting code..."
	@if command -v black >/dev/null 2>&1; then black . 2>/dev/null || true; fi
	@if command -v isort >/dev/null 2>&1; then isort . 2>/dev/null || true; fi
	@if command -v prettier >/dev/null 2>&1; then prettier --write . 2>/dev/null || true; fi
	@if command -v gofmt >/dev/null 2>&1 && [ -f go.mod ]; then gofmt -w . 2>/dev/null || true; fi
	@if command -v rustfmt >/dev/null 2>&1 && [ -f Cargo.toml ]; then cargo fmt 2>/dev/null || true; fi
```

### 5. Database Management Pattern

Modern database operations for ORMs:

```makefile
# Database Operations
.PHONY: db-init
db-init: ## Initialize database
	@echo "Initializing database..."
	@if [ -f drizzle.config.ts ]; then \
		bunx drizzle-kit push:sqlite; \
	elif [ -f prisma/schema.prisma ]; then \
		npx prisma db push; \
	elif [ -f alembic.ini ]; then \
		alembic upgrade head; \
	elif [ -f knexfile.js ]; then \
		npx knex migrate:latest; \
	else \
		echo "No database configuration found"; \
	fi

.PHONY: db-migrate
db-migrate: ## Create new migration
	@echo "Creating migration..."
	@if [ -f drizzle.config.ts ]; then \
		bunx drizzle-kit generate:sqlite; \
	elif [ -f prisma/schema.prisma ]; then \
		npx prisma migrate dev; \
	elif [ -f alembic.ini ]; then \
		read -p "Migration name: " name; \
		alembic revision --autogenerate -m "$$name"; \
	fi

.PHONY: db-studio
db-studio: ## Open database GUI
	@echo "Opening database studio..."
	@if [ -f drizzle.config.ts ]; then \
		bunx drizzle-kit studio; \
	elif [ -f prisma/schema.prisma ]; then \
		npx prisma studio; \
	else \
		echo "No studio available for current ORM"; \
	fi
```

### 6. Development Server Pattern

Smart development server that detects the framework:

```makefile
# Development Server
.PHONY: dev
dev: ## Start development server
	@echo "Starting development server..."
	@if [ -f next.config.js ] || [ -f next.config.ts ]; then \
		npm run dev || yarn dev || pnpm dev || bun dev; \
	elif [ -f vite.config.js ] || [ -f vite.config.ts ]; then \
		npm run dev || yarn dev || pnpm dev || bun dev; \
	elif [ -f webpack.config.js ]; then \
		npm run dev || yarn dev; \
	elif [ -f manage.py ]; then \
		python manage.py runserver; \
	elif [ -f main.go ]; then \
		go run main.go; \
	elif [ -f Cargo.toml ]; then \
		cargo run; \
	elif [ -f app.py ]; then \
		python app.py; \
	else \
		echo "No development server configuration found"; \
	fi
```

### 7. Dependency Management Pattern

Handle dependencies across package managers:

```makefile
# Dependencies
.PHONY: install
install: ## Install dependencies
	@echo "Installing dependencies..."
	@if [ -f bun.lockb ]; then \
		bun install; \
	elif [ -f pnpm-lock.yaml ]; then \
		pnpm install; \
	elif [ -f yarn.lock ]; then \
		yarn install; \
	elif [ -f package-lock.json ]; then \
		npm ci; \
	elif [ -f package.json ]; then \
		npm install; \
	fi
	@if [ -f requirements.txt ]; then pip install -r requirements.txt; fi
	@if [ -f Gemfile ]; then bundle install; fi
	@if [ -f go.mod ]; then go mod download; fi
	@if [ -f Cargo.toml ]; then cargo fetch; fi

.PHONY: update-deps
update-deps: ## Update dependencies
	@echo "Updating dependencies..."
	@if [ -f package.json ]; then \
		if command -v ncu >/dev/null 2>&1; then \
			ncu -u && npm install; \
		else \
			npm update; \
		fi; \
	fi
	@if [ -f requirements.txt ]; then pip install --upgrade -r requirements.txt; fi
	@if [ -f Cargo.toml ]; then cargo update; fi
	@if [ -f go.mod ]; then go get -u ./...; fi
```

### 8. Clean Build Pattern

Comprehensive cleanup across project types:

```makefile
# Cleanup
.PHONY: clean
clean: ## Clean build artifacts
	@echo "Cleaning build artifacts..."
	# JavaScript/TypeScript
	@find . -name "node_modules" -type d -prune -exec rm -rf {} + 2>/dev/null || true
	@find . -name ".next" -type d -prune -exec rm -rf {} + 2>/dev/null || true
	@find . -name "dist" -type d -prune -exec rm -rf {} + 2>/dev/null || true
	@find . -name "build" -type d -prune -exec rm -rf {} + 2>/dev/null || true
	@find . -name ".turbo" -type d -prune -exec rm -rf {} + 2>/dev/null || true
	# Python
	@find . -type d -name "__pycache__" -exec rm -rf {} + 2>/dev/null || true
	@find . -type f -name "*.pyc" -delete 2>/dev/null || true
	@find . -type d -name "*.egg-info" -exec rm -rf {} + 2>/dev/null || true
	@find . -type d -name ".pytest_cache" -exec rm -rf {} + 2>/dev/null || true
	@find . -type d -name ".ruff_cache" -exec rm -rf {} + 2>/dev/null || true
	# Rust
	@find . -name "target" -type d -prune -exec rm -rf {} + 2>/dev/null || true
	# General
	@find . -name ".coverage" -type f -delete 2>/dev/null || true
	@find . -name "coverage.xml" -type f -delete 2>/dev/null || true
	@echo "Clean complete!"
```

### 9. Documentation Pattern

Handle various documentation systems:

```makefile
# Documentation
.PHONY: docs
docs: ## Build documentation
	@echo "Building documentation..."
	@if [ -f mkdocs.yml ]; then \
		mkdocs build; \
	elif [ -f docs/conf.py ]; then \
		cd docs && make html; \
	elif [ -f docs/docusaurus.config.js ]; then \
		cd docs && npm run build; \
	elif [ -f astro.config.mjs ] && [ -d docs ]; then \
		cd docs && npm run build; \
	elif [ -f package.json ] && grep -q '"docs"' package.json; then \
		npm run docs; \
	else \
		echo "No documentation configuration found"; \
	fi

.PHONY: docs-serve
docs-serve: ## Serve documentation locally
	@echo "Serving documentation..."
	@if [ -f mkdocs.yml ]; then \
		mkdocs serve; \
	elif [ -f docs/conf.py ]; then \
		cd docs && make livehtml; \
	elif [ -f astro.config.mjs ] && [ -d docs ]; then \
		cd docs && npm run dev; \
	else \
		echo "No documentation server configuration found"; \
	fi
```

### 10. Advanced Patterns

#### Check Target
Run all quality checks:

```makefile
.PHONY: check
check: lint test security ## Run all checks (lint, test, security)
	@echo "All checks passed!"
```

#### Watch Pattern
Auto-run commands on file changes:

```makefile
.PHONY: watch
watch: ## Watch files and run tests
	@if command -v watchexec >/dev/null 2>&1; then \
		watchexec -e py,js,ts,go,rs make test; \
	elif command -v entr >/dev/null 2>&1; then \
		find . -name "*.py" -o -name "*.js" -o -name "*.ts" | entr make test; \
	else \
		echo "Install watchexec or entr for file watching"; \
	fi
```

#### TODO Finder
Find all TODOs in code:

```makefile
.PHONY: todo
todo: ## Show all TODO items in code
	@echo "Finding TODO items..."
	@if command -v rg >/dev/null 2>&1; then \
		rg "TODO|FIXME|HACK|BUG|XXX" --type-not md || echo "No TODO items found"; \
	else \
		grep -r "TODO\|FIXME\|HACK\|BUG\|XXX" --exclude-dir=node_modules --exclude-dir=.git . || echo "No TODO items found"; \
	fi
```

## Complete Example Makefile

Here's a complete Makefile incorporating these patterns:

```makefile
# Professional Development Workflow Makefile

.PHONY: help
help: ## Show this help message
	@echo 'Usage: make [target]'
	@echo ''
	@echo 'Targets:'
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "  %-15s %s\n", $$1, $$2}' $(MAKEFILE_LIST)

# Session Management
.PHONY: session-start
session-start: ## Start tracked development session
	@./scripts/session/session-start.sh

.PHONY: session-end
session-end: ## End session with summary
	@./scripts/session/session-end.sh

.PHONY: session-status
session-status: ## Show current session status
	@./scripts/session/session-status.sh

# Development
.PHONY: dev
dev: ## Start development server
	@make -s _detect-and-run-dev

.PHONY: test
test: ## Run tests
	@make -s _detect-and-run-tests

.PHONY: lint
lint: ## Run linters
	@make -s _detect-and-run-linters

.PHONY: format
format: ## Format code
	@make -s _detect-and-run-formatters

# Database
.PHONY: db-init
db-init: ## Initialize database
	@make -s _detect-and-init-db

.PHONY: db-migrate
db-migrate: ## Create migration
	@make -s _detect-and-migrate-db

.PHONY: db-studio
db-studio: ## Open database GUI
	@make -s _detect-and-open-studio

# GitHub Integration
.PHONY: issue
issue: ## Create GitHub issue
	@gh issue create

.PHONY: pr
pr: ## Create pull request
	@make -s _pr-with-session || gh pr create

# Utility
.PHONY: clean
clean: ## Clean all build artifacts
	@make -s _comprehensive-clean

.PHONY: check
check: lint test ## Run all checks
	@echo "✅ All checks passed!"

.PHONY: todo
todo: ## Find TODO items
	@make -s _find-todos

# Default target
.DEFAULT_GOAL := help

# Hidden implementation targets
.PHONY: _detect-and-run-dev
_detect-and-run-dev:
	@# Implementation details hidden for brevity

.PHONY: _comprehensive-clean
_comprehensive-clean:
	@# Implementation details hidden for brevity
```

## Best Practices

1. **Always Include Help**: Make discovery easy
2. **Use Descriptive Names**: `db-migrate` not just `migrate`
3. **Check Dependencies**: Verify tools exist before using
4. **Fail Gracefully**: Provide helpful error messages
5. **Keep It Portable**: Use POSIX-compliant commands
6. **Document Complex Logic**: Add comments for tricky parts
7. **Use .PHONY**: Mark all non-file targets as phony
8. **Compose Targets**: Build complex targets from simple ones
9. **Hide Implementation**: Use hidden targets for complex logic
10. **Version Your Makefile**: Track changes in git

## Anti-Patterns to Avoid

1. **Shell-Specific Features**: Avoid bash-specific syntax
2. **Hardcoded Paths**: Use variables or detection
3. **Missing Error Handling**: Always check command success
4. **No Help Documentation**: Every target needs `## description`
5. **Complex One-Liners**: Break into multiple lines for readability

## Conclusion

Modern Makefiles can dramatically improve developer experience by providing intelligent automation, seamless tool integration, and self-documenting workflows. The patterns in this guide transform make from a simple build tool into a comprehensive development command center.