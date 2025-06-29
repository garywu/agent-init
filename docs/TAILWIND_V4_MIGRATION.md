# Tailwind CSS v4 Alpha Migration Guide

## Overview

This guide captures lessons learned from using Tailwind CSS v4 alpha in production. Version 4 represents a significant shift in how Tailwind works, moving away from configuration files to a more modern, CSS-first approach.

## Key Changes in v4

### 1. No Configuration File
Tailwind v4 eliminates the `tailwind.config.js` file. All configuration is done through CSS.

```css
/* Old way - tailwind.config.js */
module.exports = {
  theme: {
    extend: {
      colors: {
        brand: '#1a73e8'
      }
    }
  }
}

/* New way - in your CSS */
@theme {
  --color-brand: #1a73e8;
}
```

### 2. CSS-First Configuration
Everything is configured using CSS custom properties and at-rules.

```css
/* app.css */
@import "tailwindcss";

@theme {
  /* Colors */
  --color-primary: #3b82f6;
  --color-secondary: #10b981;
  
  /* Spacing */
  --spacing-18: 4.5rem;
  
  /* Typography */
  --font-family-display: "Cal Sans", sans-serif;
}
```

### 3. Native CSS Features
v4 leverages modern CSS features instead of JavaScript processing.

```css
/* Container queries now work natively */
@container (min-width: 400px) {
  .card {
    grid-template-columns: 1fr 1fr;
  }
}

/* CSS nesting is supported */
.card {
  @apply rounded-lg p-4;
  
  .card-title {
    @apply text-xl font-bold;
  }
}
```

## Common Migration Issues

### Issue 1: Missing Config File
**Problem**: Build fails looking for `tailwind.config.js`
**Solution**: Remove all references to config file and migrate settings to CSS

```json
// package.json - Remove
"tailwindcss": "tailwindcss -c ./tailwind.config.js"

// package.json - Add
"tailwindcss": "tailwindcss"
```

### Issue 2: Theme Extension
**Problem**: `theme.extend` doesn't work anymore
**Solution**: Use CSS custom properties in `@theme`

```css
/* Before */
// tailwind.config.js
extend: {
  spacing: {
    '18': '4.5rem',
    '88': '22rem'
  }
}

/* After */
@theme {
  --spacing-18: 4.5rem;
  --spacing-88: 22rem;
}
```

### Issue 3: Plugins Not Working
**Problem**: v3 plugins are incompatible with v4
**Solution**: Wait for v4-compatible versions or implement features using CSS

```css
/* Replace @tailwindcss/forms with native CSS */
input[type="text"],
input[type="email"],
textarea {
  @apply border-gray-300 focus:border-blue-500 focus:ring-2 focus:ring-blue-500;
}
```

### Issue 4: PostCSS Configuration
**Problem**: PostCSS config needs updating for v4
**Solution**: Simplify PostCSS setup

```javascript
// postcss.config.js
module.exports = {
  plugins: {
    'tailwindcss': {},
    'autoprefixer': {},
  }
}
```

### Issue 5: JIT Mode Differences
**Problem**: JIT behavior has changed
**Solution**: v4 is always JIT, but scanning is different

```json
// Ensure your content paths are correct
{
  "tailwindcss": {
    "content": [
      "./src/**/*.{js,ts,jsx,tsx}",
      "./app/**/*.{js,ts,jsx,tsx}"
    ]
  }
}
```

## Migration Strategy

### Step 1: Update Dependencies
```bash
npm install tailwindcss@4.0.0-alpha.30
```

### Step 2: Create New CSS Structure
```css
/* app.css */
@import "tailwindcss";

/* Your theme customizations */
@theme {
  /* Migrate your color palette */
  --color-primary-50: #eff6ff;
  --color-primary-100: #dbeafe;
  --color-primary-200: #bfdbfe;
  /* ... etc */
  
  /* Migrate custom spacing */
  --spacing-18: 4.5rem;
  
  /* Migrate typography */
  --font-family-sans: Inter, system-ui, sans-serif;
  --font-size-xxs: 0.625rem;
}

/* Your custom utilities */
@layer utilities {
  .text-balance {
    text-wrap: balance;
  }
}
```

### Step 3: Update Build Process
```json
// package.json
{
  "scripts": {
    "build:css": "tailwindcss -i ./src/app.css -o ./dist/app.css"
  }
}
```

### Step 4: Migrate Custom Utilities
```css
/* Old way - in JS config */
utilities: {
  '.scrollbar-hide': {
    '-ms-overflow-style': 'none',
    'scrollbar-width': 'none',
    '&::-webkit-scrollbar': {
      display: 'none'
    }
  }
}

/* New way - in CSS */
@layer utilities {
  .scrollbar-hide {
    -ms-overflow-style: none;
    scrollbar-width: none;
    
    &::-webkit-scrollbar {
      display: none;
    }
  }
}
```

### Step 5: Update Component Styles
```jsx
// Check for deprecated utility classes
// v3: className="flex-center" (custom utility)
// v4: className="flex items-center justify-center"

// Update color references
// v3: className="text-brand"
// v4: className="text-[--color-brand]"
```

## New Features to Leverage

### 1. Improved Performance
v4 is significantly faster due to native CSS processing.

### 2. Better CSS Support
```css
/* Cascade layers work properly */
@layer components {
  .btn {
    @apply px-4 py-2 rounded;
  }
}

/* Container queries */
.card-container {
  container-type: inline-size;
}

@container (min-width: 400px) {
  .card {
    display: grid;
    grid-template-columns: 1fr 2fr;
  }
}
```

### 3. Simplified Variant System
```css
/* Custom variants are easier */
@variant hover-within (&:hover, &:focus-within);

.card {
  @hover-within {
    @apply shadow-lg scale-105;
  }
}
```

## Common Patterns

### Dark Mode
```css
@theme {
  /* Define color schemes */
  --color-background: white;
  --color-text: black;
  
  @media (prefers-color-scheme: dark) {
    --color-background: black;
    --color-text: white;
  }
}

/* Use in utilities */
.bg-background {
  background-color: var(--color-background);
}
```

### Responsive Design
```css
/* Define custom breakpoints */
@theme {
  --breakpoint-xs: 475px;
  --breakpoint-3xl: 1920px;
}

/* Use in media queries */
@media (min-width: var(--breakpoint-xs)) {
  .container {
    max-width: 100%;
  }
}
```

### Custom Properties Integration
```css
/* Define design tokens */
@theme {
  /* Semantic spacing */
  --spacing-section: var(--spacing-16);
  --spacing-card: var(--spacing-6);
  
  /* Semantic colors */
  --color-success: var(--color-green-500);
  --color-danger: var(--color-red-500);
}
```

## Testing Your Migration

### 1. Visual Regression Testing
- Take screenshots before migration
- Compare after migration
- Look for spacing, color, and layout differences

### 2. Class Name Audit
```bash
# Find potentially problematic classes
grep -r "bg-opacity-" src/  # Now use bg-black/50 syntax
grep -r "transform" src/     # No longer needed
grep -r "filter" src/        # No longer needed
```

### 3. Performance Testing
- Measure build times (should be faster)
- Check CSS file size (might be smaller)
- Test runtime performance (should be same or better)

## Rollback Plan

If you need to rollback:

1. Keep your old `tailwind.config.js` file
2. Document all v4-specific changes
3. Use feature flags for new v4 features
4. Maintain a v3 branch until stable

## Common Mistakes to Avoid

1. **Don't mix v3 and v4 syntax** - Pick one version and stick with it
2. **Don't forget to update PostCSS** - v4 has different requirements
3. **Don't ignore deprecation warnings** - They indicate future breaking changes
4. **Don't rush the migration** - v4 is still alpha, expect changes

## Resources

- [Tailwind CSS v4 Alpha Docs](https://tailwindcss.com/docs/v4-alpha)
- [Migration Guide](https://tailwindcss.com/docs/upgrade-guide)
- [Playground](https://play.tailwindcss.com/) - Test v4 features

## Conclusion

Tailwind CSS v4 represents a significant improvement in performance and CSS integration. While the migration requires effort, the benefits of native CSS features and improved performance make it worthwhile for projects that can tolerate alpha software. Plan your migration carefully and test thoroughly.