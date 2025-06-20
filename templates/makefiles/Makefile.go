# Makefile for Go Projects
# Optimized for modern Go development with modules

# Colors
BLUE := \033[0;34m
GREEN := \033[0;32m
YELLOW := \033[1;33m
RED := \033[0;31m
NC := \033[0m

# Go parameters
GOCMD := go
GOBUILD := $(GOCMD) build
GOCLEAN := $(GOCMD) clean
GOTEST := $(GOCMD) test
GOGET := $(GOCMD) get
GOMOD := $(GOCMD) mod
GOFMT := gofmt
GOLINT := golangci-lint
GOVET := $(GOCMD) vet

# Build parameters
BINARY_NAME := $(shell basename $(CURDIR))
BINARY_PATH := ./bin/$(BINARY_NAME)
MAIN_PATH := ./cmd/$(BINARY_NAME)/main.go
ifeq ($(wildcard $(MAIN_PATH)),)
    MAIN_PATH := ./main.go
endif

# Version info
VERSION := $(shell git describe --tags --always --dirty 2>/dev/null || echo "dev")
COMMIT := $(shell git rev-parse --short HEAD 2>/dev/null || echo "unknown")
BUILD_TIME := $(shell date -u '+%Y-%m-%d_%H:%M:%S')
LDFLAGS := -ldflags "-X main.Version=$(VERSION) -X main.Commit=$(COMMIT) -X main.BuildTime=$(BUILD_TIME)"

# Architecture
GOARCH := $(shell go env GOARCH)
GOOS := $(shell go env GOOS)

.DEFAULT_GOAL := help

.PHONY: help
help: ## Show this help message
	@echo '$(BLUE)Go Project Makefile$(NC)'
	@echo '=================='
	@echo ''
	@echo '$(GREEN)Build Configuration:$(NC)'
	@echo '  Binary: $(BINARY_NAME)'
	@echo '  Version: $(VERSION)'
	@echo '  Platform: $(GOOS)/$(GOARCH)'
	@echo ''
	@echo '$(YELLOW)Available Commands:$(NC)'
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "  $(BLUE)%-20s$(NC) %s\n", $$1, $$2}' $(MAKEFILE_LIST)

# ========== Development ==========

.PHONY: run
run: ## Run the application
	@echo "$(BLUE)Running application...$(NC)"
	@$(GOCMD) run $(MAIN_PATH)

.PHONY: dev
dev: ## Run with hot reload (requires air)
	@echo "$(BLUE)Starting development server with hot reload...$(NC)"
	@if command -v air >/dev/null 2>&1; then \
		air; \
	else \
		echo "$(YELLOW)Install air for hot reload: go install github.com/air-verse/air@latest$(NC)"; \
		$(GOCMD) run $(MAIN_PATH); \
	fi

.PHONY: build
build: ## Build the application
	@echo "$(BLUE)Building $(BINARY_NAME)...$(NC)"
	@mkdir -p bin
	@$(GOBUILD) $(LDFLAGS) -o $(BINARY_PATH) $(MAIN_PATH)
	@echo "$(GREEN)Build complete: $(BINARY_PATH)$(NC)"

.PHONY: build-all
build-all: ## Build for multiple platforms
	@echo "$(BLUE)Building for multiple platforms...$(NC)"
	@mkdir -p bin
	@for os in darwin linux windows; do \
		for arch in amd64 arm64; do \
			echo "Building for $$os/$$arch..."; \
			GOOS=$$os GOARCH=$$arch $(GOBUILD) $(LDFLAGS) -o bin/$(BINARY_NAME)-$$os-$$arch$(if $(filter windows,$$os),.exe,) $(MAIN_PATH); \
		done; \
	done
	@echo "$(GREEN)Multi-platform build complete!$(NC)"

.PHONY: install
install: ## Install the binary
	@echo "$(BLUE)Installing $(BINARY_NAME)...$(NC)"
	@$(GOCMD) install $(LDFLAGS) $(MAIN_PATH)
	@echo "$(GREEN)Installed to $(GOPATH)/bin/$(BINARY_NAME)$(NC)"

# ========== Testing ==========

.PHONY: test
test: ## Run tests
	@echo "$(BLUE)Running tests...$(NC)"
	@$(GOTEST) -v -race ./...

.PHONY: test-short
test-short: ## Run short tests
	@$(GOTEST) -v -short ./...

.PHONY: test-coverage
test-coverage: ## Run tests with coverage
	@echo "$(BLUE)Running tests with coverage...$(NC)"
	@$(GOTEST) -v -race -coverprofile=coverage.out -covermode=atomic ./...
	@$(GOCMD) tool cover -func=coverage.out
	@echo "$(GREEN)Coverage report: coverage.out$(NC)"

.PHONY: test-coverage-html
test-coverage-html: test-coverage ## Generate HTML coverage report
	@$(GOCMD) tool cover -html=coverage.out -o coverage.html
	@echo "$(GREEN)HTML coverage report: coverage.html$(NC)"

.PHONY: test-integration
test-integration: ## Run integration tests
	@echo "$(BLUE)Running integration tests...$(NC)"
	@$(GOTEST) -v -race -tags=integration ./...

.PHONY: benchmark
benchmark: ## Run benchmarks
	@echo "$(BLUE)Running benchmarks...$(NC)"
	@$(GOTEST) -bench=. -benchmem ./...

.PHONY: fuzz
fuzz: ## Run fuzz tests (Go 1.18+)
	@echo "$(BLUE)Running fuzz tests...$(NC)"
	@$(GOTEST) -fuzz=. -fuzztime=10s ./...

# ========== Code Quality ==========

.PHONY: fmt
fmt: ## Format code
	@echo "$(BLUE)Formatting code...$(NC)"
	@$(GOFMT) -w -s .
	@$(GOCMD) fmt ./...
	@echo "$(GREEN)Code formatted!$(NC)"

.PHONY: fmt-check
fmt-check: ## Check code formatting
	@echo "$(BLUE)Checking code format...$(NC)"
	@if [ -n "$$($(GOFMT) -l .)" ]; then \
		echo "$(RED)The following files need formatting:$(NC)"; \
		$(GOFMT) -l .; \
		exit 1; \
	else \
		echo "$(GREEN)All files are properly formatted!$(NC)"; \
	fi

.PHONY: lint
lint: ## Run linter
	@echo "$(BLUE)Running linter...$(NC)"
	@if command -v $(GOLINT) >/dev/null 2>&1; then \
		$(GOLINT) run ./...; \
	else \
		echo "$(YELLOW)Install golangci-lint: https://golangci-lint.run/usage/install/$(NC)"; \
		$(GOVET) ./...; \
	fi

.PHONY: vet
vet: ## Run go vet
	@echo "$(BLUE)Running go vet...$(NC)"
	@$(GOVET) ./...

.PHONY: staticcheck
staticcheck: ## Run staticcheck
	@echo "$(BLUE)Running staticcheck...$(NC)"
	@if command -v staticcheck >/dev/null 2>&1; then \
		staticcheck ./...; \
	else \
		echo "$(YELLOW)Install staticcheck: go install honnef.co/go/tools/cmd/staticcheck@latest$(NC)"; \
	fi

.PHONY: security
security: ## Run security scan
	@echo "$(BLUE)Running security scan...$(NC)"
	@if command -v gosec >/dev/null 2>&1; then \
		gosec ./...; \
	else \
		echo "$(YELLOW)Install gosec: go install github.com/securego/gosec/v2/cmd/gosec@latest$(NC)"; \
	fi

# ========== Dependencies ==========

.PHONY: deps
deps: ## Download dependencies
	@echo "$(BLUE)Downloading dependencies...$(NC)"
	@$(GOMOD) download
	@echo "$(GREEN)Dependencies downloaded!$(NC)"

.PHONY: deps-update
deps-update: ## Update dependencies
	@echo "$(BLUE)Updating dependencies...$(NC)"
	@$(GOGET) -u ./...
	@$(GOMOD) tidy
	@echo "$(GREEN)Dependencies updated!$(NC)"

.PHONY: deps-check
deps-check: ## Check for outdated dependencies
	@echo "$(BLUE)Checking dependencies...$(NC)"
	@$(GOCMD) list -u -m all

.PHONY: deps-audit
deps-audit: ## Audit dependencies for vulnerabilities
	@echo "$(BLUE)Auditing dependencies...$(NC)"
	@if command -v nancy >/dev/null 2>&1; then \
		$(GOCMD) list -json -m all | nancy sleuth; \
	else \
		echo "$(YELLOW)Install nancy: go install github.com/sonatype-nexus-community/nancy@latest$(NC)"; \
		$(GOCMD) list -m all | grep -E "CVE|vulnerability" || echo "Manual audit required"; \
	fi

.PHONY: mod-verify
mod-verify: ## Verify module dependencies
	@echo "$(BLUE)Verifying dependencies...$(NC)"
	@$(GOMOD) verify

# ========== Tools ==========

.PHONY: tools
tools: ## Install development tools
	@echo "$(BLUE)Installing development tools...$(NC)"
	@$(GOCMD) install github.com/air-verse/air@latest
	@$(GOCMD) install github.com/golangci/golangci-lint/cmd/golangci-lint@latest
	@$(GOCMD) install honnef.co/go/tools/cmd/staticcheck@latest
	@$(GOCMD) install github.com/securego/gosec/v2/cmd/gosec@latest
	@$(GOCMD) install golang.org/x/vuln/cmd/govulncheck@latest
	@echo "$(GREEN)Tools installed!$(NC)"

.PHONY: generate
generate: ## Run go generate
	@echo "$(BLUE)Running go generate...$(NC)"
	@$(GOCMD) generate ./...

.PHONY: mock
mock: ## Generate mocks
	@echo "$(BLUE)Generating mocks...$(NC)"
	@if command -v mockgen >/dev/null 2>&1; then \
		$(GOCMD) generate -run=mockgen ./...; \
	else \
		echo "$(YELLOW)Install mockgen: go install go.uber.org/mock/mockgen@latest$(NC)"; \
	fi

# ========== Docker ==========

.PHONY: docker-build
docker-build: ## Build Docker image
	@echo "$(BLUE)Building Docker image...$(NC)"
	@docker build -t $(BINARY_NAME):$(VERSION) -t $(BINARY_NAME):latest .

.PHONY: docker-run
docker-run: docker-build ## Run in Docker
	@echo "$(BLUE)Running Docker container...$(NC)"
	@docker run --rm -it $(BINARY_NAME):latest

.PHONY: docker-push
docker-push: docker-build ## Push Docker image
	@echo "$(BLUE)Pushing Docker image...$(NC)"
	@docker push $(BINARY_NAME):$(VERSION)
	@docker push $(BINARY_NAME):latest

# ========== Database ==========

.PHONY: migrate-up
migrate-up: ## Run database migrations up
	@echo "$(BLUE)Running migrations up...$(NC)"
	@if command -v migrate >/dev/null 2>&1; then \
		migrate -path ./migrations -database "$${DATABASE_URL}" up; \
	else \
		echo "$(YELLOW)Install migrate: https://github.com/golang-migrate/migrate$(NC)"; \
	fi

.PHONY: migrate-down
migrate-down: ## Run database migrations down
	@echo "$(BLUE)Running migrations down...$(NC)"
	@if command -v migrate >/dev/null 2>&1; then \
		migrate -path ./migrations -database "$${DATABASE_URL}" down; \
	else \
		echo "$(YELLOW)Install migrate: https://github.com/golang-migrate/migrate$(NC)"; \
	fi

.PHONY: migrate-create
migrate-create: ## Create new migration (usage: make migrate-create NAME=create_users_table)
	@if [ -z "$(NAME)" ]; then echo "Usage: make migrate-create NAME=migration_name"; exit 1; fi
	@echo "$(BLUE)Creating migration: $(NAME)...$(NC)"
	@migrate create -ext sql -dir ./migrations -seq $(NAME)

# ========== Maintenance ==========

.PHONY: clean
clean: ## Clean build artifacts
	@echo "$(BLUE)Cleaning build artifacts...$(NC)"
	@$(GOCLEAN)
	@rm -rf bin/ coverage.* *.test *.out
	@echo "$(GREEN)Clean complete!$(NC)"

.PHONY: info
info: ## Show Go environment info
	@echo "$(BLUE)Go Environment:$(NC)"
	@$(GOCMD) version
	@$(GOCMD) env

.PHONY: todo
todo: ## Find TODO/FIXME items
	@echo "$(BLUE)TODO items:$(NC)"
	@grep -rn "TODO\|FIXME" --include="*.go" . || echo "No TODOs found"

.PHONY: loc
loc: ## Count lines of code
	@echo "$(BLUE)Lines of code:$(NC)"
	@if command -v tokei >/dev/null 2>&1; then \
		tokei; \
	else \
		find . -name "*.go" -not -path "./vendor/*" | xargs wc -l; \
	fi

# ========== CI/CD ==========

.PHONY: ci
ci: deps fmt-check vet lint test ## Run all CI checks
	@echo "$(GREEN)All CI checks passed!$(NC)"

.PHONY: pre-commit
pre-commit: fmt lint test ## Run pre-commit checks
	@echo "$(GREEN)Pre-commit checks passed!$(NC)"

.PHONY: release
release: ## Create a new release (usage: make release VERSION=v1.0.0)
	@if [ -z "$(VERSION)" ]; then echo "Usage: make release VERSION=v1.0.0"; exit 1; fi
	@echo "$(BLUE)Creating release $(VERSION)...$(NC)"
	@git tag -a $(VERSION) -m "Release $(VERSION)"
	@git push origin $(VERSION)
	@echo "$(GREEN)Release $(VERSION) created!$(NC)"

# ========== Help Aliases ==========

.PHONY: r
r: run ## Alias for run

.PHONY: b
b: build ## Alias for build

.PHONY: t
t: test ## Alias for test

.PHONY: l
l: lint ## Alias for lint

.PHONY: f
f: fmt ## Alias for fmt