# Documentation Site

This is an Astro + Starlight documentation site for the project.

## 🚀 Quick Start

```bash
# Install dependencies
npm install

# Start development server
npm run dev

# Build for production
npm run build

# Preview production build
npm run preview
```

## 📁 Project Structure

```
docs/
├── src/
│   ├── content/
│   │   ├── docs/          # Documentation pages
│   │   └── config.ts      # Content collection config
│   └── styles/
│       └── custom.css     # Custom styles
├── astro.config.mjs       # Astro configuration
├── package.json           # Dependencies
└── tsconfig.json          # TypeScript config
```

## 📝 Adding Documentation

1. Create new `.md` or `.mdx` files in `src/content/docs/`
2. Add frontmatter with title and description
3. Write your content in Markdown
4. The sidebar will auto-generate based on file structure

## 🎨 Customization

- Edit `astro.config.mjs` to change site settings
- Modify `src/styles/custom.css` for custom styling
- Update the homepage at `src/content/docs/index.mdx`

## 🚀 Deployment

The site builds to static HTML and can be deployed anywhere:

```bash
npm run build
# Output is in ./dist directory
```

### GitHub Pages

Add this GitHub Action to `.github/workflows/deploy-docs.yml`:

```yaml
name: Deploy Documentation

on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: 20
      - run: npm ci
      - run: npm run build
      - uses: actions/upload-pages-artifact@v3
        with:
          path: ./dist
      - uses: actions/deploy-pages@v4
```

## 📚 Learn More

- [Astro Documentation](https://docs.astro.build)
- [Starlight Documentation](https://starlight.astro.build)