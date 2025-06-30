# Project Scaffolding Patterns

Patterns for initializing new projects with language-specific best practices, tooling, and structure. These are suggestions, not requirements.

## Overview

Project scaffolding helps:
- Start with consistent structure
- Include common tooling from the beginning
- Follow language-specific conventions
- Save setup time

## Language-Specific Templates

### Python Project

```bash
# Basic Python project structure
create_python_project() {
    local project_name="$1"

    mkdir -p "$project_name"/{src,tests,docs}
    cd "$project_name"

    # Python-specific files
    cat > pyproject.toml << 'EOF'
[build-system]
requires = ["setuptools>=61.0", "wheel"]
build-backend = "setuptools.build_meta"

[project]
name = "project-name"
version = "0.1.0"
description = "A brief description"
requires-python = ">=3.8"
dependencies = []

[project.optional-dependencies]
dev = [
    "pytest>=7.0",
    "pytest-cov",
    "black",
    "ruff",
    "mypy",
    "pre-commit"
]

[tool.black]
line-length = 88
target-version = ['py38']

[tool.ruff]
line-length = 88
select = ["E", "F", "I", "N", "W"]

[tool.mypy]
python_version = "3.8"
warn_return_any = true
warn_unused_configs = true

[tool.pytest.ini_options]
testpaths = ["tests"]
addopts = "-v --cov=src --cov-report=html --cov-report=term"
EOF

    # Source structure
    touch "src/__init__.py"
    cat > "src/main.py" << 'EOF'
"""Main module for the project."""

def main():
    """Entry point for the application."""
    print("Hello, World!")

if __name__ == "__main__":
    main()
EOF

    # Test structure
    touch "tests/__init__.py"
    cat > "tests/test_main.py" << 'EOF'
"""Tests for main module."""
import pytest
from src.main import main

def test_main(capsys):
    """Test main function."""
    main()
    captured = capsys.readouterr()
    assert "Hello, World!" in captured.out
EOF

    # Development files
    cat > .gitignore << 'EOF'
# Python
__pycache__/
*.py[cod]
*$py.class
*.so
.Python
build/
develop-eggs/
dist/
downloads/
eggs/
.eggs/
lib/
lib64/
parts/
sdist/
var/
wheels/
*.egg-info/
.installed.cfg
*.egg
PIPFILE.lock

# Virtual Environment
venv/
ENV/
env/
.venv/

# Testing
.tox/
.coverage
.coverage.*
.cache
.pytest_cache/
htmlcov/

# IDE
.idea/
.vscode/
*.swp
*.swo
*~

# OS
.DS_Store
Thumbs.db
EOF

    # Virtual environment setup
    python -m venv venv
    source venv/bin/activate 2>/dev/null || . venv/Scripts/activate
    pip install -e ".[dev]"

    echo "✅ Python project '$project_name' created"
    echo "📝 Activate virtual environment: source venv/bin/activate"
}
```

### Node.js/TypeScript Project

```bash
create_node_project() {
    local project_name="$1"
    local use_typescript="${2:-true}"

    mkdir -p "$project_name"
    cd "$project_name"

    # Initialize package.json
    cat > package.json << EOF
{
  "name": "$project_name",
  "version": "0.1.0",
  "description": "A brief description",
  "main": "dist/index.js",
  "scripts": {
    "build": "tsc",
    "dev": "ts-node-dev --respawn src/index.ts",
    "start": "node dist/index.js",
    "test": "jest",
    "test:watch": "jest --watch",
    "test:coverage": "jest --coverage",
    "lint": "eslint . --ext .ts,.js",
    "format": "prettier --write ."
  },
  "keywords": [],
  "author": "",
  "license": "MIT",
  "devDependencies": {
    "@types/jest": "^29.0.0",
    "@types/node": "^20.0.0",
    "@typescript-eslint/eslint-plugin": "^6.0.0",
    "@typescript-eslint/parser": "^6.0.0",
    "eslint": "^8.0.0",
    "jest": "^29.0.0",
    "prettier": "^3.0.0",
    "ts-jest": "^29.0.0",
    "ts-node-dev": "^2.0.0",
    "typescript": "^5.0.0"
  },
  "dependencies": {}
}
EOF

    # TypeScript config
    if [[ "$use_typescript" == "true" ]]; then
        cat > tsconfig.json << 'EOF'
{
  "compilerOptions": {
    "target": "ES2022",
    "module": "commonjs",
    "lib": ["ES2022"],
    "outDir": "./dist",
    "rootDir": "./src",
    "strict": true,
    "esModuleInterop": true,
    "skipLibCheck": true,
    "forceConsistentCasingInFileNames": true,
    "resolveJsonModule": true,
    "declaration": true,
    "declarationMap": true,
    "sourceMap": true,
    "noUnusedLocals": true,
    "noUnusedParameters": true,
    "noImplicitReturns": true,
    "noFallthroughCasesInSwitch": true
  },
  "include": ["src/**/*"],
  "exclude": ["node_modules", "dist", "**/*.test.ts"]
}
EOF
    fi

    # Jest config
    cat > jest.config.js << 'EOF'
module.exports = {
  preset: 'ts-jest',
  testEnvironment: 'node',
  roots: ['<rootDir>/src'],
  testMatch: ['**/__tests__/**/*.ts', '**/?(*.)+(spec|test).ts'],
  collectCoverageFrom: [
    'src/**/*.ts',
    '!src/**/*.d.ts',
    '!src/**/*.test.ts'
  ]
};
EOF

    # ESLint config
    cat > .eslintrc.json << 'EOF'
{
  "root": true,
  "parser": "@typescript-eslint/parser",
  "plugins": ["@typescript-eslint"],
  "extends": [
    "eslint:recommended",
    "plugin:@typescript-eslint/recommended"
  ],
  "env": {
    "node": true,
    "es2022": true
  },
  "rules": {
    "@typescript-eslint/no-unused-vars": ["error", { "argsIgnorePattern": "^_" }],
    "@typescript-eslint/explicit-function-return-type": "off",
    "@typescript-eslint/no-explicit-any": "warn"
  }
}
EOF

    # Prettier config
    cat > .prettierrc << 'EOF'
{
  "semi": true,
  "trailingComma": "es5",
  "singleQuote": true,
  "printWidth": 100,
  "tabWidth": 2
}
EOF

    # Source structure
    mkdir -p src/__tests__
    cat > src/index.ts << 'EOF'
export function hello(name: string): string {
  return `Hello, ${name}!`;
}

if (require.main === module) {
  console.log(hello('World'));
}
EOF

    cat > src/__tests__/index.test.ts << 'EOF'
import { hello } from '../index';

describe('hello', () => {
  it('should greet the given name', () => {
    expect(hello('World')).toBe('Hello, World!');
    expect(hello('TypeScript')).toBe('Hello, TypeScript!');
  });
});
EOF

    # Install dependencies
    npm install

    echo "✅ Node.js/TypeScript project '$project_name' created"
}
```

### Go Project

```bash
create_go_project() {
    local project_name="$1"
    local module_path="${2:-github.com/username/$project_name}"

    mkdir -p "$project_name"
    cd "$project_name"

    # Initialize Go module
    go mod init "$module_path"

    # Project structure
    mkdir -p {cmd,internal,pkg,test,docs}

    # Main application
    mkdir -p cmd/"$project_name"
    cat > cmd/"$project_name"/main.go << 'EOF'
package main

import (
	"fmt"
	"log"
	"os"
)

func main() {
	if err := run(); err != nil {
		log.Fatal(err)
	}
}

func run() error {
	fmt.Println("Hello, World!")
	return nil
}
EOF

    # Internal package
    mkdir -p internal/config
    cat > internal/config/config.go << 'EOF'
package config

// Config holds application configuration
type Config struct {
	// Add configuration fields here
}

// Load loads configuration from environment
func Load() (*Config, error) {
	return &Config{}, nil
}
EOF

    # Makefile
    cat > Makefile << 'EOF'
.PHONY: build test clean run lint

BINARY_NAME := $(shell basename $(CURDIR))

build:
	go build -o bin/$(BINARY_NAME) cmd/$(BINARY_NAME)/main.go

test:
	go test -v -race -coverprofile=coverage.out ./...
	go tool cover -html=coverage.out -o coverage.html

run:
	go run cmd/$(BINARY_NAME)/main.go

lint:
	golangci-lint run

clean:
	rm -rf bin/ coverage.out coverage.html

tidy:
	go mod tidy

fmt:
	go fmt ./...
EOF

    # golangci-lint config
    cat > .golangci.yml << 'EOF'
linters:
  enable:
    - gofmt
    - golint
    - govet
    - errcheck
    - ineffassign
    - gosimple
    - staticcheck
    - unused
    - misspell
    - gocyclo
    - gocognit

linters-settings:
  gocyclo:
    min-complexity: 15
  gocognit:
    min-complexity: 20

run:
  deadline: 5m
EOF

    echo "✅ Go project '$project_name' created"
    echo "📝 Module path: $module_path"
}
```

### Rust Project

```bash
create_rust_project() {
    local project_name="$1"
    local project_type="${2:-bin}"  # bin or lib

    # Use cargo for initial setup
    cargo new "$project_name" --$project_type
    cd "$project_name"

    # Enhanced Cargo.toml
    cat >> Cargo.toml << 'EOF'

[profile.release]
opt-level = 3
lto = true
codegen-units = 1
strip = true

[profile.dev]
opt-level = 0

[dev-dependencies]
pretty_assertions = "1"
criterion = "0.5"

[[bench]]
name = "benchmarks"
harness = false
EOF

    # Create benchmark
    mkdir -p benches
    cat > benches/benchmarks.rs << 'EOF'
use criterion::{black_box, criterion_group, criterion_main, Criterion};

fn fibonacci(n: u64) -> u64 {
    match n {
        0 => 1,
        1 => 1,
        n => fibonacci(n-1) + fibonacci(n-2),
    }
}

fn criterion_benchmark(c: &mut Criterion) {
    c.bench_function("fib 20", |b| b.iter(|| fibonacci(black_box(20))));
}

criterion_group!(benches, criterion_benchmark);
criterion_main!(benches);
EOF

    # GitHub Actions
    mkdir -p .github/workflows
    cat > .github/workflows/rust.yml << 'EOF'
name: Rust

on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]

env:
  CARGO_TERM_COLOR: always

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v3
    - uses: dtolnay/rust-toolchain@stable
    - uses: Swatinem/rust-cache@v2
    - name: Build
      run: cargo build --verbose
    - name: Run tests
      run: cargo test --verbose
    - name: Run clippy
      run: cargo clippy -- -D warnings
    - name: Check formatting
      run: cargo fmt -- --check
EOF

    echo "✅ Rust project '$project_name' created"
}
```

## Multi-Language Monorepo

```bash
create_monorepo() {
    local project_name="$1"

    mkdir -p "$project_name"/{packages,services,libs,tools}
    cd "$project_name"

    # Root package.json for workspaces
    cat > package.json << 'EOF'
{
  "name": "monorepo-root",
  "private": true,
  "workspaces": [
    "packages/*",
    "services/*"
  ],
  "scripts": {
    "build": "turbo run build",
    "dev": "turbo run dev --parallel",
    "test": "turbo run test",
    "lint": "turbo run lint",
    "format": "prettier --write ."
  },
  "devDependencies": {
    "turbo": "latest",
    "prettier": "latest"
  }
}
EOF

    # Turbo config
    cat > turbo.json << 'EOF'
{
  "$schema": "https://turbo.build/schema.json",
  "pipeline": {
    "build": {
      "dependsOn": ["^build"],
      "outputs": ["dist/**"]
    },
    "test": {
      "dependsOn": ["build"],
      "outputs": ["coverage/**"]
    },
    "lint": {},
    "dev": {
      "persistent": true
    }
  }
}
EOF

    # Lerna config (optional)
    cat > lerna.json << 'EOF'
{
  "$schema": "node_modules/lerna/schemas/lerna-schema.json",
  "version": "independent",
  "npmClient": "npm",
  "command": {
    "publish": {
      "conventionalCommits": true,
      "message": "chore(release): publish",
      "registry": "https://registry.npmjs.org"
    },
    "version": {
      "allowBranch": ["main", "release/*"],
      "conventionalCommits": true
    }
  }
}
EOF

    echo "✅ Monorepo '$project_name' created"
}
```

## AI/ML Project Template

```bash
create_ml_project() {
    local project_name="$1"

    mkdir -p "$project_name"/{data,notebooks,src,models,configs}
    cd "$project_name"

    # Python ML/AI specific setup
    cat > pyproject.toml << 'EOF'
[build-system]
requires = ["setuptools>=61.0", "wheel"]
build-backend = "setuptools.build_meta"

[project]
name = "ml-project"
version = "0.1.0"
description = "Machine Learning project"
requires-python = ">=3.8"
dependencies = [
    "numpy>=1.21",
    "pandas>=1.3",
    "scikit-learn>=1.0",
    "matplotlib>=3.4",
    "seaborn>=0.11",
    "jupyter>=1.0",
    "torch>=2.0",
    "transformers>=4.0",
    "datasets>=2.0",
    "wandb",
    "mlflow"
]

[project.optional-dependencies]
dev = [
    "pytest>=7.0",
    "black",
    "ruff",
    "mypy",
    "pre-commit"
]
EOF

    # DVC config for data versioning
    cat > .dvc/.gitignore << 'EOF'
/config.local
/tmp
/cache
EOF

    cat > dvc.yaml << 'EOF'
stages:
  prepare:
    cmd: python src/prepare_data.py
    deps:
      - src/prepare_data.py
      - data/raw
    outs:
      - data/processed

  train:
    cmd: python src/train.py
    deps:
      - src/train.py
      - data/processed
    outs:
      - models/model.pkl
    metrics:
      - metrics/scores.json:
          cache: false
EOF

    # MLflow tracking
    cat > MLproject << 'EOF'
name: ml-project

conda_env: environment.yml

entry_points:
  main:
    parameters:
      learning_rate: {type: float, default: 0.001}
      batch_size: {type: int, default: 32}
      epochs: {type: int, default: 10}
    command: "python src/train.py --lr {learning_rate} --batch-size {batch_size} --epochs {epochs}"
EOF

    echo "✅ ML/AI project '$project_name' created"
}
```

## Interactive Project Creation

```bash
# Interactive scaffolding with gum
interactive_scaffold() {
    if ! command -v gum &> /dev/null; then
        echo "Install gum for interactive mode: brew install gum"
        return 1
    fi

    # Project type selection
    PROJECT_TYPE=$(gum choose \
        "Python" \
        "Node.js/TypeScript" \
        "Go" \
        "Rust" \
        "Monorepo" \
        "AI/ML Project")

    # Project name
    PROJECT_NAME=$(gum input --placeholder "Enter project name")

    # Confirmation
    gum confirm "Create $PROJECT_TYPE project '$PROJECT_NAME'?" || return

    # Create based on type
    case "$PROJECT_TYPE" in
        "Python")
            create_python_project "$PROJECT_NAME"
            ;;
        "Node.js/TypeScript")
            USE_TS=$(gum confirm "Use TypeScript?" && echo "true" || echo "false")
            create_node_project "$PROJECT_NAME" "$USE_TS"
            ;;
        "Go")
            MODULE_PATH=$(gum input --placeholder "Module path (e.g., github.com/user/project)")
            create_go_project "$PROJECT_NAME" "$MODULE_PATH"
            ;;
        "Rust")
            PROJECT_TYPE=$(gum choose "bin" "lib")
            create_rust_project "$PROJECT_NAME" "$PROJECT_TYPE"
            ;;
        "Monorepo")
            create_monorepo "$PROJECT_NAME"
            ;;
        "AI/ML Project")
            create_ml_project "$PROJECT_NAME"
            ;;
    esac

    # Post-creation actions
    gum style --foreground 212 --border double \
        "✅ Project created successfully!"

    if gum confirm "Initialize git repository?"; then
        git init
        git add .
        git commit -m "feat: initial project setup"
    fi

    if gum confirm "Open in editor?"; then
        ${EDITOR:-code} .
    fi
}
```

## Best Practices

1. **Keep It Simple**
   - Start with minimal structure
   - Add complexity as needed
   - Don't over-engineer initial setup

2. **Language Conventions**
   - Follow language-specific standards
   - Use official project layouts
   - Include standard tooling

3. **Documentation**
   - Always include README.md
   - Add LICENSE file
   - Document setup steps

4. **Version Control**
   - Include appropriate .gitignore
   - Consider .gitattributes
   - Add pre-commit hooks

## Customization

These templates are starting points. Customize based on:
- Team preferences
- Company standards
- Project requirements
- Tool availability

## External References

- [Python Packaging Guide](https://packaging.python.org/)
- [Node.js Best Practices](https://github.com/goldbergyoni/nodebestpractices)
- [Go Project Layout](https://github.com/golang-standards/project-layout)
- [Rust Book](https://doc.rust-lang.org/book/)
- [Monorepo Tools](https://monorepo.tools/)