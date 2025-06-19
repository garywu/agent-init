# GitHub Pages + Astro: Quick Reference

## TL;DR - Common Fixes

### 🔧 Quick Fixes for Broken Links

1. **Homepage Action Buttons** (in `astro.config.mjs`)
   ```diff
   - link: '/guides/getting-started/'
   + link: './guides/getting-started/'
   ```

2. **Cross-Reference Links** (in `.md` files)
   ```diff
   - [Setup Guide](/guides/setup/)
   + [Setup Guide](../guides/setup/)
   ```

3. **Sidebar Configuration**
   ```diff
   - sidebar: [{ label: 'Guides', items: [{ label: 'Setup', link: '/guides/setup/' }] }]
   + sidebar: [{ label: 'Guides', autogenerate: { directory: 'guides' } }]
   ```

### ⚙️ Required Configuration

```javascript
// astro.config.mjs
export default defineConfig({
  site: 'https://username.github.io',
  base: '/repository-name',  // Must match GitHub repo name exactly
});
```

### 🧪 Quick Test Commands

```bash
# Test locally with base path
cd docs && npm run dev
# Visit: http://localhost:4321/repository-name/

# Test production links
curl -I "https://username.github.io/repository-name/guides/getting-started/"

# Find broken absolute links
rg "\[.*\]\(/.*\)" docs/src/content/ --type md
```

## Link Pattern Cheat Sheet

| Context | ❌ Broken | ✅ Working |
|---------|-----------|------------|
| Homepage to section | `/guides/` | `./guides/` |
| Cross-directory | `/reference/api/` | `../reference/api/` |
| Same directory | `/guides/setup/` | `./setup/` |
| Action buttons | `link: '/guides/'` | `link: './guides/'` |

## Emergency Recovery

If links are broken in production:

```bash
# 1. Verify config
grep "base:" docs/astro.config.mjs

# 2. Fix homepage actions (add './')
# 3. Fix content links (use '../' or './')
# 4. Deploy
git add . && git commit -m "fix: documentation links" && git push
```

## Prevention

- ✅ Use relative paths (`./`, `../`) for internal links
- ✅ Set `base: '/repository-name'` in astro.config.mjs
- ✅ Use `autogenerate` for sidebar when possible
- ✅ Always run `astro sync && astro build`
- ❌ Never use absolute paths (`/section/`) for internal links

For detailed explanation, see: [github-pages-astro-troubleshooting.md](./github-pages-astro-troubleshooting.md)