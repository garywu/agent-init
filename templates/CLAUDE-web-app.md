# Claude AI Development Guide - Web Application

This file tracks AI-assisted development for web applications (Next.js, React, Vue, etc.).

## 🚀 Quick Reference Commands

```bash
# Development
npm run dev             # Start dev server
npm run build           # Production build
npm run lint            # Run linter
npm run test            # Run tests
npm run type-check      # TypeScript checking

# Common Tasks
npm install <package>   # Add dependency
npm run analyze         # Bundle analysis
npm run storybook       # Component library

# Git Workflow
gh issue create --title "[FEAT] " --label "enhancement"
gh pr create --title "" --body "Resolves #"
```

## 📋 Current Session

- **Date**: [YYYY-MM-DD]
- **Framework**: [ ] Next.js [ ] React [ ] Vue [ ] Other: ___
- **Primary Focus**: 
- **Active Branch**: 

### Session Checklist
- [ ] Check package vulnerabilities with `npm audit`
- [ ] Run linters before commits
- [ ] Update component documentation
- [ ] Check bundle size impact
- [ ] Test in multiple browsers

## 🏗️ Project Structure

```
├── src/                 # Source code
│   ├── components/     # React/Vue components
│   ├── pages/          # Page components
│   ├── hooks/          # Custom hooks
│   ├── utils/          # Utilities
│   └── styles/         # CSS/SCSS files
├── public/             # Static assets
├── tests/              # Test files
└── docs/               # Documentation
```

## 🎯 Web-Specific Guidelines

### Performance
- [ ] Lazy load heavy components
- [ ] Optimize images (WebP, AVIF)
- [ ] Use code splitting
- [ ] Implement proper caching
- [ ] Monitor Core Web Vitals

### Accessibility
- [ ] ARIA labels on interactive elements
- [ ] Keyboard navigation support
- [ ] Color contrast compliance
- [ ] Screen reader testing
- [ ] Focus management

### SEO
- [ ] Meta tags implementation
- [ ] Structured data
- [ ] Sitemap generation
- [ ] Open Graph tags
- [ ] Canonical URLs

## 🔧 Development Patterns

### Component Structure
```typescript
// Prefer functional components with hooks
export const Component: FC<Props> = ({ prop1, prop2 }) => {
  // Hooks at the top
  const [state, setState] = useState();
  
  // Event handlers
  const handleClick = useCallback(() => {}, []);
  
  // Effects
  useEffect(() => {}, []);
  
  // Render
  return <div>{/* JSX */}</div>;
};
```

### State Management
- Local state: useState/useReducer
- Global state: Context API / Redux / Zustand
- Server state: React Query / SWR

## 📊 Performance Metrics

Track these metrics:
- First Contentful Paint (FCP): < 1.8s
- Time to Interactive (TTI): < 3.8s
- Cumulative Layout Shift (CLS): < 0.1
- Bundle size: Monitor growth

## 🐛 Common Issues & Solutions

| Issue | Solution |
|-------|----------|
| Hydration mismatch | Check server/client rendering differences |
| Memory leaks | Clean up effects and subscriptions |
| Bundle too large | Analyze with webpack-bundle-analyzer |
| SEO not working | Check SSR/SSG implementation |

## 📝 Session Notes

[Add session-specific notes here]

---

Remember: Focus on user experience, performance, and accessibility!