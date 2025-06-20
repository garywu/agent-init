# Documentation Site Setup Guide

This guide captures hard-learned lessons from setting up Astro/Starlight documentation sites, including critical build issues and their solutions.

## Critical Knowledge: The Content Collection Sync Issue

**THE MOST IMPORTANT THING TO KNOW**: Astro sites with content collections MUST run `astro sync` before building, or your content pages won't be included in the production build.

### The Problem We Encountered

- Documentation site worked perfectly in development (`npm run dev`)
- Production build succeeded without errors
- But only homepage and 404 page were generated
- All 17 content pages were missing from the build

### The Original Documentation That Saved Us

After hours of debugging, we found the answer in:
- [Astro Content Collections Guide](https://docs.astro.build/en/guides/content-collections/)
- [Starlight Getting Started](https://starlight.astro.build/getting-started/)
- Specifically: [Astro's build command documentation](https://docs.astro.build/en/reference/cli-reference/#astro-sync)

The critical detail: **"The astro sync command generates TypeScript types for all Astro modules. It should be run before building to ensure types are up to date."**

### The Solution

```json
// package.json
{
  "scripts": {
    "dev": "astro dev",
    "start": "astro dev",
    "build": "astro sync && astro check && astro build",
    "preview": "astro preview"
  }
}
```

**Never skip `astro sync` before building!**

## Complete Starlight Setup

### Initial Setup

```bash
# IMPORTANT: When creating docs as part of an existing repository,
# DO NOT include the --git flag to avoid creating a separate repo

# Create docs site in a subdirectory (part of current repo)
npm create astro@latest docs -- --template starlight --typescript relaxed --skip-houston

# Or if you need to create in current directory
npm create astro@latest . -- --template starlight --typescript relaxed --skip-houston

# Or add to existing project
npm install @astrojs/starlight
```

**Note**: Omit the `--git` flag when the documentation should be part of an existing repository, not a separate one.

### Essential Configuration

```js
// astro.config.mjs
import { defineConfig } from 'astro/config';
import starlight from '@astrojs/starlight';

export default defineConfig({
  // CRITICAL for GitHub Pages
  site: 'https://username.github.io',
  base: '/repository-name',
  
  integrations: [
    starlight({
      title: 'My Documentation',
      
      // Use autogenerate for reliability
      sidebar: {
        autogenerate: { directory: 'content/docs' },
      },
      
      // Avoid theme customization complexity initially
      // Default light theme works well
    }),
  ],
});
```

### Directory Structure

```
docs/
├── astro.config.mjs
├── package.json
├── tsconfig.json
├── public/
│   └── favicon.svg
└── src/
    ├── content/
    │   ├── config.ts          # Content collection config
    │   └── docs/              # Your documentation pages
    │       ├── index.mdx      # Homepage
    │       ├── getting-started.md
    │       └── guides/
    │           └── example.md
    └── env.d.ts
```

### Content Collection Configuration

```typescript
// src/content/config.ts
import { defineCollection } from 'astro:content';
import { docsSchema } from '@astrojs/starlight/schema';

export const collections = {
  docs: defineCollection({ schema: docsSchema }),
};
```

## GitHub Actions Deployment

### Working CI/CD Configuration

```yaml
name: Deploy Documentation

on:
  push:
    branches: [main]
  workflow_dispatch:

permissions:
  contents: read
  pages: write
  id-token: write

concurrency:
  group: "pages"
  cancel-in-progress: false

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout
        uses: actions/checkout@v4
        
      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: '18'
          
      - name: Install dependencies
        working-directory: ./docs
        run: |
          # Remove package-lock to avoid cross-platform issues
          rm -f package-lock.json
          npm install
          
      - name: Build documentation
        working-directory: ./docs
        run: |
          # CRITICAL: This must include astro sync!
          npm run build
          
      - name: Upload artifact
        uses: actions/upload-pages-artifact@v2
        with:
          path: ./docs/dist

  deploy:
    environment:
      name: github-pages
      url: ${{ steps.deployment.outputs.page_url }}
    runs-on: ubuntu-latest
    needs: build
    steps:
      - name: Deploy to GitHub Pages
        id: deployment
        uses: actions/deploy-pages@v3
```

## Common Issues and Solutions

### 1. Missing Content Pages in Build

**Symptoms**: Dev server shows all pages, production build missing content

**Solution**:
```bash
# Always run sync before build
astro sync && astro build

# Or add to build script
"build": "astro sync && astro check && astro build"
```

### 2. Cross-Platform Build Failures

**Symptoms**: Works locally (macOS), fails in CI (Linux)

**Causes**:
- package-lock.json platform-specific dependencies
- Different Node.js versions
- Missing system dependencies

**Solutions**:
```yaml
# In CI, regenerate package-lock
- run: |
    rm -f package-lock.json
    npm install

# Or use npm ci with exact versions
# package.json - use exact versions
"dependencies": {
  "@astrojs/starlight": "0.15.0",  # not ^0.15.0
  "astro": "4.0.0"
}
```

### 3. Theme Customization Issues

**Problem**: CSS overrides causing build problems

**Solution**: Start with defaults
```js
// Start simple
starlight({
  title: 'My Docs',
  // Don't customize theme initially
})

// Add customization later if needed
starlight({
  title: 'My Docs',
  customCss: ['./src/styles/custom.css'],
})
```

### 4. Sidebar Configuration Problems

**Problem**: Manual sidebar config missing pages

**Solution**: Use autogenerate
```js
// Avoid manual configuration
sidebar: [
  { label: 'Home', link: '/' },
  { label: 'Guide', link: '/guide' },
  // Easy to miss pages
]

// Use autogenerate instead
sidebar: {
  autogenerate: { directory: 'content/docs' },
}
```

## Testing Documentation Builds

### Local Testing Checklist

```bash
# 1. Clean build
rm -rf dist .astro node_modules/.astro

# 2. Fresh install
rm -f package-lock.json
npm install

# 3. Test sync explicitly
npm run astro sync

# 4. Check for content
find src/content/docs -name "*.md" -o -name "*.mdx" | wc -l

# 5. Build and preview
npm run build
npm run preview

# 6. Verify all pages built
find dist -name "*.html" | wc -l
```

### Automated Testing

```yaml
# .github/workflows/test-docs.yml
name: Test Documentation Build

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Test documentation build
        working-directory: ./docs
        run: |
          npm install
          npm run build
          
          # Verify pages were built
          PAGE_COUNT=$(find dist -name "*.html" | wc -l)
          echo "Built $PAGE_COUNT pages"
          
          if [ "$PAGE_COUNT" -lt 5 ]; then
            echo "Error: Expected at least 5 pages, got $PAGE_COUNT"
            find dist -name "*.html"
            exit 1
          fi
```

## Performance Optimization

### Build Performance

```json
// package.json
{
  "scripts": {
    // Parallel checking and building
    "build": "astro sync && concurrently \"astro check\" \"astro build\"",
    
    // Skip type checking for faster builds
    "build:fast": "astro sync && astro build"
  }
}
```

### Caching in CI

```yaml
- name: Cache Astro
  uses: actions/cache@v3
  with:
    path: |
      docs/node_modules
      docs/.astro
    key: ${{ runner.os }}-astro-${{ hashFiles('docs/package-lock.json') }}
```

## Debugging Build Issues

### Enable Verbose Logging

```bash
# Debug mode
DEBUG=* npm run build

# Astro specific debug
ASTRO_TELEMETRY_DISABLED=1 npm run build -- --verbose
```

### Check Content Collections

```js
// Debug script: check-content.js
import { getCollection } from 'astro:content';

const docs = await getCollection('docs');
console.log(`Found ${docs.length} documentation pages:`);
docs.forEach(doc => {
  console.log(`  - ${doc.id}: ${doc.data.title}`);
});
```

### Common Debug Commands

```bash
# List all content files
find src/content -type f -name "*.md*"

# Check if .astro directory exists
ls -la .astro/

# Verify content types are generated
cat .astro/types.d.ts | grep "content"

# Check for syntax errors in MDX
npm run astro check
```

## Best Practices

1. **Always test production builds locally**
   ```bash
   npm run build && npm run preview
   ```

2. **Version control strategy**
   - Commit package.json with exact versions
   - Consider not committing package-lock.json for libraries
   - Document Node.js version requirement

3. **Content organization**
   ```
   src/content/docs/
   ├── index.mdx          # Homepage
   ├── getting-started/   # Group related content
   │   ├── index.md
   │   ├── installation.md
   │   └── configuration.md
   └── guides/
       └── index.md
   ```

4. **Frontmatter standards**
   ```yaml
   ---
   title: Page Title
   description: SEO description
   sidebar:
     order: 1
     label: Custom Sidebar Label  # Optional
   ---
   ```

5. **Error prevention**
   - Run `astro sync` in git pre-commit hook
   - Add build verification to PR checks
   - Monitor build output size
   - Test on fresh clone regularly

## Migration from Other Platforms

### From VitePress/VuePress

```js
// Key differences:
// 1. Content in src/content/docs not docs/
// 2. Use .mdx for components
// 3. Different frontmatter schema

// Migration script example
import glob from 'glob';
import fs from 'fs-extra';

const files = glob.sync('docs/**/*.md');
files.forEach(file => {
  let content = fs.readFileSync(file, 'utf-8');
  
  // Update frontmatter
  content = content.replace(/^---\n([\s\S]*?)\n---/, (match, fm) => {
    // Transform frontmatter
    return `---\n${transformFrontmatter(fm)}\n---`;
  });
  
  // Update paths
  const newPath = file.replace('docs/', 'src/content/docs/');
  fs.outputFileSync(newPath, content);
});
```

Remember: **The astro sync command is not optional for content collections!**

## Subdirectory Documentation Sites

When setting up documentation as a subdirectory of an existing repository:

### 1. Repository Structure
```bash
your-project/
├── .github/
│   └── workflows/
│       └── deploy-docs.yml    # Workflow MUST be here, not in docs/.github/
├── src/                       # Your main project code
├── docs/                      # Documentation site subdirectory
│   ├── package.json
│   ├── astro.config.mjs
│   └── src/
│       └── content/
└── README.md
```

### 2. GitHub Actions Configuration
```yaml
# .github/workflows/deploy-docs.yml
env:
  BUILD_PATH: "./docs"  # Point to subdirectory

jobs:
  build:
    steps:
      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          cache-dependency-path: docs/package-lock.json
          
      - name: Install dependencies
        working-directory: ${{ env.BUILD_PATH }}
        run: npm install
        
      - name: Build
        working-directory: ${{ env.BUILD_PATH }}
        run: npm run build
```

### 3. Common Pitfalls
- ❌ Don't put workflows in `docs/.github/workflows/` - GitHub won't find them
- ❌ Don't use `--git` flag when creating in subdirectory
- ✅ Do configure `working-directory` in all workflow steps
- ✅ Do set `cache-dependency-path` for Node.js setup

## Additional Resources

### Official Documentation
- [Astro Documentation](https://docs.astro.build/)
- [Starlight Documentation](https://starlight.astro.build/)
- [Astro Content Collections](https://docs.astro.build/en/guides/content-collections/)
- [GitHub Pages Documentation](https://docs.github.com/en/pages)

### Community Resources
- [Astro Discord](https://astro.build/chat)
- [Starlight GitHub Discussions](https://github.com/withastro/starlight/discussions)

### Related Guides
- [Astro Deployment Guides](https://docs.astro.build/en/guides/deploy/)
- [GitHub Actions for GitHub Pages](https://github.com/actions/deploy-pages)