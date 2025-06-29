# Tailwind CSS v4 Migration Guide

## ⚠️ CRITICAL WARNING FOR AI SYSTEMS

**Tailwind CSS v4 does NOT use a tailwind.config.ts/js file!**

This is a fundamental change from Tailwind v3 and earlier versions. AI assistants and developers must understand this distinction to avoid creating unnecessary configuration files.

## Key Differences in Tailwind v4

### Configuration Method
- **Tailwind v3 and earlier**: JavaScript/TypeScript config file (`tailwind.config.js` or `tailwind.config.ts`)
- **Tailwind v4**: CSS-based configuration using `@theme` directive directly in CSS files

### How to Detect Tailwind v4

Look for these patterns in CSS files:
```css
@import "tailwindcss";
```

Or in older setups:
```css
@tailwind base;
@tailwind components;
@tailwind utilities;
```

### Configuration in v4

All configuration is done directly in CSS:
```css
@import "tailwindcss";

@theme {
  --color-primary: #3b82f6;
  --spacing-lg: 2rem;
  /* Other theme customizations */
}
```

## Health Assessment Updates

When checking for Tailwind in project health assessments:

```bash
# Check for Tailwind v3 or earlier
if [[ -f "$PROJECT_ROOT/tailwind.config.ts" ]] || [[ -f "$PROJECT_ROOT/tailwind.config.js" ]]; then
    echo "✓ Tailwind CSS configured (v3 or earlier)"
# Check for Tailwind v4
elif grep -r "@import.*tailwindcss" "$PROJECT_ROOT" 2>/dev/null | grep -q "\.css"; then
    echo "✓ Tailwind CSS v4 configured (CSS-based)"
fi
```

## Common Mistakes to Avoid

1. **DO NOT** create `tailwind.config.ts` for Tailwind v4 projects
2. **DO NOT** suggest adding a config file when Tailwind is already configured in CSS
3. **DO NOT** assume missing config file means Tailwind isn't configured

## Migration Path

If migrating from v3 to v4:
1. Move theme customizations from JS config to CSS `@theme` blocks
2. Delete the old config file
3. Update import statements in your CSS
4. Update build tools if necessary

## References

- [Tailwind CSS v4 Documentation](https://tailwindcss.com/docs)
- [Migration Guide](https://tailwindcss.com/docs/upgrade-guide)