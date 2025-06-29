# Package Manager Patterns for Modern Development

## Overview

Modern JavaScript/TypeScript development has evolved beyond npm. This guide covers patterns for using various package managers effectively, including newer alternatives like Bun, pnpm, and Yarn Berry. It also covers patterns for other language ecosystems and TypeScript execution tools.

## JavaScript/TypeScript Package Managers

### Package Manager Comparison

| Feature | npm | Yarn Classic | Yarn Berry | pnpm | Bun |
|---------|-----|--------------|------------|------|-----|
| Speed | ⭐⭐ | ⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ |
| Disk Space | ⭐⭐ | ⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ |
| Monorepo | ⭐⭐ | ⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ |
| Compatibility | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐⭐ |
| Built-in Features | ⭐⭐ | ⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐⭐⭐⭐ |

### 1. Bun - The All-in-One Toolkit

Bun is a fast JavaScript runtime, package manager, bundler, and test runner.

#### Installation
```bash
# macOS/Linux
curl -fsSL https://bun.sh/install | bash

# With npm
npm install -g bun
```

#### Key Features
- **Lightning Fast**: Up to 30x faster than npm
- **Built-in TypeScript**: No compilation step needed
- **Native bundler**: Replace webpack/esbuild
- **Built-in test runner**: Replace Jest/Vitest

#### Usage Patterns
```bash
# Install dependencies (reads package.json)
bun install

# Add a dependency
bun add express

# Add dev dependency
bun add -d @types/express

# Run scripts
bun run dev
bun run build

# Execute TypeScript directly
bun run index.ts

# Run tests
bun test

# Bundle for production
bun build ./src/index.ts --outdir ./dist
```

#### When to Use Bun
- New projects that can adopt cutting-edge tools
- Projects that need maximum performance
- When you want an all-in-one solution
- TypeScript-heavy projects

### 2. pnpm - Efficient Disk Space Usage

pnpm uses a content-addressable storage system to save disk space.

#### Installation
```bash
# With npm
npm install -g pnpm

# Standalone
curl -fsSL https://get.pnpm.io/install.sh | sh
```

#### Key Features
- **Disk efficient**: Shared storage for packages
- **Faster than npm**: Parallel installation
- **Strict mode**: Prevents phantom dependencies
- **Excellent monorepo support**: Built-in workspace features

#### Usage Patterns
```bash
# Install dependencies
pnpm install

# Add dependency
pnpm add lodash

# Workspace commands
pnpm -r build  # Run build in all packages
pnpm --filter @myorg/package-a build

# Update dependencies interactively
pnpm update -i
```

#### Configuration
```yaml
# .npmrc
strict-peer-dependencies=true
auto-install-peers=true
shamefully-hoist=true  # For compatibility with tools expecting hoisted deps
```

### 3. Yarn Berry (v2+) - Modern Package Management

Yarn Berry introduces Plug'n'Play (PnP) for zero-installs.

#### Migration from Yarn Classic
```bash
# Set Yarn version
yarn set version berry

# Or specific version
yarn set version 4.0.0
```

#### Key Features
- **Zero-installs**: Commit dependencies to git
- **PnP**: No node_modules folder
- **Workspace protocols**: Better monorepo support
- **Constraints**: Enforce rules across workspaces

#### Usage Patterns
```bash
# Enable PnP
yarn config set nodeLinker pnp

# Or use node_modules (compatibility mode)
yarn config set nodeLinker node-modules

# Workspace focus
yarn workspaces focus @myorg/package-a

# Interactive upgrade
yarn upgrade-interactive
```

### 4. Package Manager Detection

Detect which package manager to use:

```javascript
// detect-pm.js
const fs = require('fs');

function detectPackageManager() {
  if (fs.existsSync('bun.lockb')) return 'bun';
  if (fs.existsSync('pnpm-lock.yaml')) return 'pnpm';
  if (fs.existsSync('yarn.lock')) {
    const yarnVersion = require('child_process')
      .execSync('yarn --version', { encoding: 'utf8' })
      .trim();
    return yarnVersion.startsWith('1.') ? 'yarn-classic' : 'yarn-berry';
  }
  if (fs.existsSync('package-lock.json')) return 'npm';
  return 'npm'; // default
}
```

## TypeScript Execution Patterns

### 1. tsx - Modern TypeScript Execute

tsx is a modern TypeScript execution engine with watch mode.

#### Installation
```bash
npm install -g tsx
# or
pnpm add -g tsx
# or
bun add -g tsx
```

#### Usage
```bash
# Execute TypeScript
tsx script.ts

# Watch mode
tsx watch script.ts

# As Node.js loader
node --loader tsx script.ts

# In package.json
{
  "scripts": {
    "dev": "tsx watch src/index.ts",
    "build": "tsx src/build.ts"
  }
}
```

### 2. ts-node vs tsx

| Feature | ts-node | tsx |
|---------|---------|-----|
| Speed | ⭐⭐ | ⭐⭐⭐⭐⭐ |
| ESM Support | ⭐⭐ | ⭐⭐⭐⭐⭐ |
| Watch Mode | ❌ | ✅ |
| Config Required | Yes | No |

### 3. Direct Execution Patterns

```json
{
  "scripts": {
    // Using tsx
    "seed": "tsx scripts/seed-database.ts",
    "migrate": "tsx scripts/run-migrations.ts",
    
    // Using Bun
    "seed:bun": "bun scripts/seed-database.ts",
    
    // Using ts-node
    "seed:tsnode": "ts-node scripts/seed-database.ts"
  }
}
```

## Cross-Language Package Management

### Universal Patterns

```makefile
# Smart dependency installation
install: ## Install all dependencies
	@echo "Installing dependencies..."
	@# JavaScript/TypeScript
	@if [ -f bun.lockb ]; then bun install; \
	elif [ -f pnpm-lock.yaml ]; then pnpm install; \
	elif [ -f yarn.lock ]; then yarn install; \
	elif [ -f package-lock.json ]; then npm ci; \
	elif [ -f package.json ]; then npm install; fi
	@# Python
	@if [ -f requirements.txt ]; then pip install -r requirements.txt; fi
	@if [ -f Pipfile ]; then pipenv install; fi
	@if [ -f poetry.lock ]; then poetry install; fi
	@# Ruby
	@if [ -f Gemfile ]; then bundle install; fi
	@# Rust
	@if [ -f Cargo.toml ]; then cargo fetch; fi
	@# Go
	@if [ -f go.mod ]; then go mod download; fi
```

## Modern Tool Integrations

### 1. Drizzle ORM with Bun

```json
{
  "scripts": {
    "db:push": "bunx drizzle-kit push:sqlite",
    "db:studio": "bunx drizzle-kit studio",
    "db:generate": "bunx drizzle-kit generate:sqlite"
  }
}
```

### 2. Ultracite - Modern Linting/Formatting

```json
{
  "scripts": {
    "format": "ultracite format",
    "lint": "ultracite lint",
    "check": "ultracite check"
  }
}
```

### 3. Modern Build Tools

```json
{
  "scripts": {
    // Using Bun's built-in bundler
    "build:bun": "bun build src/index.ts --outdir dist --minify",
    
    // Using esbuild via package manager
    "build:esbuild": "bunx esbuild src/index.ts --bundle --outfile=dist/index.js",
    
    // Using Vite
    "build:vite": "vite build"
  }
}
```

## Lockfile Management

### Lockfile Patterns

```bash
# .gitignore patterns
# Commit only one lockfile
package-lock.json
yarn.lock
pnpm-lock.yaml
bun.lockb
# Then explicitly un-ignore the one you use
!bun.lockb
```

### Lockfile Conversion

```bash
# Convert between lockfiles
npx @pnpm/lockfile-converter

# Sync lockfiles in CI
bunx syncpack
```

## CI/CD Considerations

### GitHub Actions Setup

```yaml
# .github/workflows/ci.yml
name: CI
on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      # Detect and setup package manager
      - name: Detect package manager
        id: detect-package-manager
        run: |
          if [ -f bun.lockb ]; then
            echo "manager=bun" >> $GITHUB_OUTPUT
          elif [ -f pnpm-lock.yaml ]; then
            echo "manager=pnpm" >> $GITHUB_OUTPUT
          elif [ -f yarn.lock ]; then
            echo "manager=yarn" >> $GITHUB_OUTPUT
          else
            echo "manager=npm" >> $GITHUB_OUTPUT
          fi
      
      # Setup Bun
      - uses: oven-sh/setup-bun@v1
        if: steps.detect-package-manager.outputs.manager == 'bun'
      
      # Setup pnpm
      - uses: pnpm/action-setup@v2
        if: steps.detect-package-manager.outputs.manager == 'pnpm'
        with:
          version: 8
      
      # Install and test
      - run: ${{ steps.detect-package-manager.outputs.manager }} install
      - run: ${{ steps.detect-package-manager.outputs.manager }} test
```

## Performance Benchmarks

### Installation Speed (1000 packages)
- Bun: ~3s
- pnpm: ~15s
- Yarn Berry (PnP): ~10s
- Yarn Classic: ~45s
- npm: ~60s

### Disk Usage (1000 packages)
- pnpm: ~500MB (shared storage)
- Yarn Berry (PnP): ~300MB (zip files)
- Bun: ~800MB
- Yarn Classic: ~1.2GB
- npm: ~1.2GB

## Migration Guides

### npm → Bun
```bash
# Install Bun
curl -fsSL https://bun.sh/install | bash

# Remove npm lockfile
rm package-lock.json

# Install with Bun
bun install

# Update scripts to use bun
sed -i 's/npm run/bun run/g' package.json
```

### npm → pnpm
```bash
# Install pnpm
npm install -g pnpm

# Import from npm lockfile
pnpm import

# Remove npm lockfile
rm package-lock.json

# Configure
echo "strict-peer-dependencies=false" > .npmrc
```

## Best Practices

1. **Commit One Lockfile**: Choose one package manager per project
2. **Document Choice**: Add to README which package manager to use
3. **Use `bunx`/`pnpx`/`npx`**: For one-off executions
4. **CI Caching**: Cache package manager stores in CI
5. **Audit Regularly**: All package managers support `audit`
6. **Use Workspaces**: For monorepos, use built-in workspace features
7. **Stay Updated**: Package managers evolve rapidly

## Tool Recommendations

### For Maximum Performance
- **Bun**: All-in-one toolkit with incredible speed
- **tsx**: For TypeScript execution
- **esbuild**: For bundling (or Bun's built-in bundler)

### For Disk Efficiency
- **pnpm**: Content-addressable storage
- **Yarn Berry**: With PnP enabled

### For Compatibility
- **npm**: Maximum ecosystem compatibility
- **Yarn Classic**: Well-established, widely supported

### For Modern ORMs
- **Drizzle**: Type-safe, performant, great DX
- **Prisma**: Popular, mature, good tooling

## Conclusion

The JavaScript ecosystem offers multiple excellent package managers, each with unique strengths. Bun represents the cutting edge with its all-in-one approach and blazing speed. pnpm excels at disk efficiency and monorepo management. Yarn Berry pioneers new approaches with PnP. Choose based on your project's specific needs, team familiarity, and performance requirements.