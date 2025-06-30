---
title: GitHub Pages Astro Troubleshooting
description: GitHub Pages Astro Troubleshooting - Comprehensive guide from agent-init
sidebar:
  order: 20
---

# GitHub Pages + Astro Documentation Site Troubleshooting

## Overview

This guide addresses the complex issue of broken internal links when deploying Astro documentation sites (especially with Starlight) to GitHub Pages. This problem has caused multiple failed attempts and significant debugging time, so this comprehensive guide should prevent future occurrences.

## The Problems

### Problem 1: Missing Styles
**Symptom**: Documentation site loads but without any CSS styling, appears as plain HTML.

**Cause**: Base path in `astro.config.mjs` doesn't match the actual repository name.

**Solution**: Update configuration with exact values:
```javascript
site: 'https://YOUR-GITHUB-USERNAME.github.io',
base: '/YOUR-EXACT-REPO-NAME',  // Case-sensitive!
```

### Problem 2: Broken Internal Links
**Symptom**: Documentation site builds successfully but internal links return 404 errors in production, while working fine locally.

**Example**: Links like `https://username.github.io/repository-name/section/page/` return 404, but `https://username.github.io/section/page/` would work (if it existed).

## Root Cause Analysis

### Technical Foundation

1. **GitHub Pages URL Structure**: `https://username.github.io/repository-name/`
2. **Astro Base Path**: Must be configured as `base: '/repository-name'`
3. **Link Resolution**: Internal links must account for this base path prefix

### Why This Is Complex

The issue involves understanding the interaction between:
- Astro's base path configuration
- GitHub Pages deployment behavior
- Starlight's link resolution
- Different behavior between local dev and production

## Failed Link Patterns ❌

### 1. Absolute Paths
```markdown
<!-- BROKEN: Missing base path -->
[Getting Started](/guides/getting-started/)
[API Reference](/reference/api/)
```
**Resolves to**: `https://username.github.io/guides/getting-started/` (missing `/repository-name`)

### 2. Homepage Action Buttons
```javascript
// astro.config.mjs - BROKEN
hero: {
  actions: [
    {
      text: 'Get Started',
      link: '/guides/getting-started/', // ❌ Absolute path
      icon: 'right-arrow',
    }
  ]
}
```

### 3. Cross-Reference Links
```markdown
<!-- BROKEN: Absolute paths in content -->
- [Setup Guide](/guides/setup/)
- [API Documentation](/reference/api/)
```

## Working Link Patterns ✅

### 1. Relative Paths from Homepage
```markdown
<!-- WORKS: Relative to current location -->
[Getting Started](./guides/getting-started/)
[API Reference](./reference/api/)
```

### 2. Fixed Homepage Action Buttons
```javascript
// astro.config.mjs - FIXED
hero: {
  actions: [
    {
      text: 'Get Started',
      link: './guides/getting-started/', // ✅ Relative path
      icon: 'right-arrow',
    }
  ]
}
```

### 3. Cross-Directory Navigation
```markdown
<!-- WORKS: Relative navigation -->
- [Setup Guide](../guides/setup/)     <!-- From reference/ to guides/ -->
- [API Documentation](../reference/)   <!-- From guides/ to reference/ -->
- [Other Page](./other-page/)         <!-- Same directory -->
```

## Required Configuration

### 1. Astro Configuration
```javascript
// astro.config.mjs
import { defineConfig } from 'astro/config';
import starlight from '@astrojs/starlight';

export default defineConfig({
  site: 'https://username.github.io',
  base: '/repository-name',              // ⚠️ Critical: Must match GitHub repo name
  integrations: [
    starlight({
      title: 'Project Documentation',
      sidebar: [
        {
          label: 'Guides',
          autogenerate: { directory: 'guides' }, // ✅ Prefer autogenerate
        },
        {
          label: 'Reference',
          autogenerate: { directory: 'reference' },
        },
      ],
    }),
  ],
});
```

### 2. Package.json Build Process
```json
{
  "scripts": {
    "build": "astro sync && astro build",  // ⚠️ Always sync before build
    "dev": "astro dev",
    "preview": "astro preview"
  }
}
```

### 3. GitHub Actions Workflow
```yaml
# .github/workflows/deploy.yml
name: Deploy to GitHub Pages

on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: '20'
          cache: 'npm'
          cache-dependency-path: docs/package-lock.json

      - name: Install dependencies
        run: |
          cd docs
          npm ci

      - name: Build site
        run: |
          cd docs
          npm run build  # Includes astro sync

      - name: Deploy to GitHub Pages
        uses: actions/deploy-pages@v4
        with:
          path: docs/dist
```

## Testing Strategy

### 1. Local Testing with Base Path
```bash
# Start dev server (includes base path)
cd docs
npm run dev

# Visit: http://localhost:4321/repository-name/
# Test all internal links manually
```

### 2. Automated Link Testing
```bash
#!/bin/bash
# tests/docs/test_links.sh

BASE_URL="${1:-http://localhost:4321}"
SITE_BASE="/repository-name"

test_link() {
    local path="$1"
    local url="${BASE_URL}${SITE_BASE}${path}"
    echo "Testing: $url"

    if curl -sI "$url" | head -1 | grep -q "200"; then
        echo "✅ $path"
        return 0
    else
        echo "❌ $path"
        return 1
    fi
}

# Test critical pages
test_link "/"
test_link "/guides/getting-started/"
test_link "/reference/api/"

echo "Link testing complete"
```

### 3. Production Testing
```bash
#!/bin/bash
# tests/docs/test_production.sh

BASE_URL="https://username.github.io/repository-name"

# Test homepage
curl -sI "$BASE_URL/" | head -1

# Test internal pages
curl -sI "$BASE_URL/guides/getting-started/" | head -1
curl -sI "$BASE_URL/reference/api/" | head -1
```

## Common Failed Attempts

### ❌ Attempt 1: Explicit Sidebar Links
```javascript
// DON'T DO THIS - maintenance nightmare
sidebar: [
  {
    label: 'Guides',
    items: [
      { label: 'Getting Started', link: '/guides/getting-started/' }, // Still broken
      { label: 'Setup', link: '/guides/setup/' },                    // Still broken
    ],
  },
]
```
**Problem**: Manual links still use absolute paths, doesn't solve base path issue.

### ❌ Attempt 2: URL Concatenation
```javascript
// DON'T DO THIS - fragile and error-prone
const baseUrl = '/repository-name';
link: `${baseUrl}/guides/getting-started/`
```
**Problem**: Complex, hard to maintain, Astro should handle this automatically.

### ❌ Attempt 3: File Restructuring
**Problem**: Moving files around doesn't fix the fundamental base path configuration issue.

## The Complete Fix Process

### Step 1: Verify Base Configuration
```javascript
// astro.config.mjs - Ensure base matches repository name
export default defineConfig({
  site: 'https://username.github.io',
  base: '/repository-name',  // ⚠️ Must match exactly
});
```

### Step 2: Fix Homepage Action Links
```javascript
// Change absolute to relative paths
hero: {
  actions: [
    {
      text: 'Get Started',
      link: './guides/getting-started/', // Add './'
      icon: 'right-arrow',
      variant: 'primary'
    },
    {
      text: 'API Reference',
      link: './reference/api/',           // Add './'
      icon: 'document'
    }
  ]
}
```

### Step 3: Fix Content Cross-References
```markdown
<!-- Before (broken) -->
[Setup Guide](/guides/setup/)
[API Docs](/reference/api/)

<!-- After (fixed) -->
[Setup Guide](../guides/setup/)     <!-- From reference/ -->
[API Docs](../reference/api/)       <!-- From guides/ -->
[Other Guide](./other-guide/)       <!-- Same directory -->
```

### Step 4: Use Sidebar Autogeneration
```javascript
sidebar: [
  {
    label: 'Guides',
    autogenerate: { directory: 'guides' }, // Let Starlight handle paths
  },
]
```

### Step 5: Ensure Content Collection Sync
```bash
# Always sync before building
astro sync && astro build
```

## Debugging Commands

### When Links Are Broken

```bash
# 1. Check base configuration
grep -r "base:" docs/astro.config.mjs

# 2. Find absolute link patterns
rg "]\(/[^)]*\)" docs/src/content/

# 3. Test local build with base path
cd docs
npm run build
npm run preview  # Test built version

# 4. Test specific URLs
curl -I "http://localhost:4321/repository-name/guides/getting-started/"

# 5. Check GitHub Pages deployment
curl -I "https://username.github.io/repository-name/"
```

### Link Pattern Analysis
```bash
# Find all markdown links
rg "\[.*\]\(.*\)" docs/src/content/ --type md

# Find problematic absolute paths
rg "\[.*\]\(/.*\)" docs/src/content/ --type md

# Find action button configurations
rg "link:" docs/astro.config.mjs
```

## Prevention Checklist

### For New Projects
- [ ] Set correct `base` path in `astro.config.mjs` (match repository name)
- [ ] Use relative paths for all internal links (`./`, `../`)
- [ ] Prefer `autogenerate` over manual sidebar configuration
- [ ] Include `astro sync` in build process
- [ ] Set up automated link testing
- [ ] Test both local and production environments

### Link Pattern Guidelines
- ✅ Homepage action buttons: `./section/page/`
- ✅ Cross-directory: `../other-section/page/`
- ✅ Same directory: `./other-page/`
- ❌ Absolute paths: `/section/page/`
- ❌ Full URLs unless external: `https://site.com/section/page/`

### Template Updates

If using claude-init templates, ensure:

```javascript
// templates/docs/astro.config.mjs
export default defineConfig({
  site: 'https://{{GITHUB_USERNAME}}.github.io',
  base: '/{{REPOSITORY_NAME}}',  // Template variable for repository
  // ...
});
```

## Recovery Process

If you encounter broken links in production:

1. **Immediate Assessment**
   ```bash
   # Check if homepage loads
   curl -I "https://username.github.io/repository-name/"

   # Test a specific broken link
   curl -I "https://username.github.io/repository-name/guides/getting-started/"
   ```

2. **Configuration Verification**
   ```bash
   # Verify base path matches repository name
   grep "base:" docs/astro.config.mjs
   ```

3. **Systematic Link Fixing**
   ```bash
   # Find and fix homepage action links (in astro.config.mjs)
   # Find and fix content cross-references (in .md files)
   # Convert absolute paths to relative paths
   ```

4. **Testing and Deployment**
   ```bash
   # Test locally
   cd docs && npm run dev

   # Build and test
   npm run build && npm run preview

   # Deploy fix
   git add . && git commit -m "fix: resolve documentation link issues"
   git push origin main
   ```

## Key Insights

1. **GitHub Pages base paths are not optional** - they fundamentally change how links resolve
2. **Astro's base configuration must match exactly** - no trailing slashes, exact repository name
3. **Relative paths are more robust** than absolute paths for internal links
4. **Content collections require syncing** - always run `astro sync` before build
5. **Local testing with base path is critical** - dev server behavior differs from production

## When to Use This Guide

Apply this troubleshooting guide when:

- ✅ Using Astro with Starlight for documentation
- ✅ Deploying to GitHub Pages (username.github.io/repository-name)
- ✅ Internal links work locally but 404 in production
- ✅ Homepage loads but navigation links are broken
- ✅ Site builds successfully but links don't work

This issue has historically required multiple debugging sessions and failed attempts. Following this guide systematically should resolve the problem in a single iteration.