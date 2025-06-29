# Routing Architecture Patterns

## Overview

This document captures routing architecture patterns and lessons learned from production applications. It covers both file-based routing (Next.js App Router style) and programmatic routing (TanStack Router, React Router), as well as hybrid approaches.

## Route Organization Patterns

### 1. Route Groups for Access Control

Organize routes by access level using route groups (folder names in parentheses):

```
app/
├── (auth)/          # Authentication routes
│   ├── login/
│   ├── register/
│   └── forgot-password/
├── (app)/           # Protected application routes
│   ├── dashboard/
│   ├── settings/
│   └── profile/
├── (public)/        # Public marketing routes
│   ├── about/
│   ├── pricing/
│   └── features/
└── (dev)/           # Development/debug routes
    ├── debug/
    └── test/
```

**Benefits:**
- Clear access control boundaries
- Easy to apply middleware per group
- Optimized layouts and loading per group
- Development routes easily excluded from production

### 2. Feature-Based Organization

Within route groups, organize by feature rather than file type:

```
(app)/
├── analytics/
│   ├── page.tsx
│   ├── components/
│   └── hooks/
├── assessment/
│   ├── page.tsx
│   ├── [id]/page.tsx
│   └── components/
└── learning/
    ├── page.tsx
    ├── [subject]/
    │   └── [lesson]/
    │       └── page.tsx
    └── components/
```

### 3. Hub Pages Pattern

When you have multiple related features, create hub pages:

```
(app)/
└── music/
    ├── page.tsx           # Music hub
    ├── piano/
    ├── theory/
    ├── artists/
    └── library/
```

This prevents navigation sprawl and provides logical groupings.

## File-Based vs Programmatic Routing

### When to Use File-Based Routing

**Best for:**
- Content-heavy sites
- SEO-critical pages
- Simple navigation flows
- Static or mostly-static content

**Example (Next.js App Router):**
```typescript
// app/blog/[slug]/page.tsx
export default function BlogPost({ params }: { params: { slug: string } }) {
  return <Article slug={params.slug} />;
}
```

### When to Use Programmatic Routing

**Best for:**
- Complex state-dependent navigation
- Multi-step forms/wizards
- Dynamic route generation
- Fine-grained route guards

**Example (TanStack Router):**
```typescript
const router = createRouter({
  routes: [
    {
      path: '/wizard',
      component: WizardLayout,
      children: [
        {
          path: 'step-1',
          component: Step1,
          beforeEnter: ({ context }) => {
            if (!context.hasData) {
              throw redirect('/wizard');
            }
          }
        }
      ]
    }
  ]
});
```

## Hybrid Approach: Best of Both Worlds

### Pattern: File-Based Structure with Programmatic Enhancement

Use file-based routing for structure but enhance with programmatic navigation:

```typescript
// app/(app)/workbench/page.tsx
'use client';

import { useSearchParams, useRouter } from 'next/navigation';
import { useEffect } from 'react';

const VALID_TABS = ['vocabulary', 'assessment', 'analytics'] as const;

export default function Workbench() {
  const searchParams = useSearchParams();
  const router = useRouter();
  const tab = searchParams.get('tab');

  useEffect(() => {
    // Validate and redirect to default if needed
    if (!tab || !VALID_TABS.includes(tab as any)) {
      router.replace('/workbench?tab=vocabulary');
    }
  }, [tab, router]);

  return <WorkbenchContent activeTab={tab} />;
}
```

### Pattern: Centralized Navigation Logic

Create a navigation service for complex routing logic:

```typescript
// lib/navigation.ts
export const navigation = {
  toAssessment: (type: string, level?: string) => {
    const params = new URLSearchParams({ type });
    if (level) params.set('level', level);
    return `/assessment?${params}`;
  },
  
  toLesson: (subject: string, lesson: string, section?: number) => {
    let path = `/learn/${subject}/${lesson}`;
    if (section) path += `#section-${section}`;
    return path;
  },
  
  toProfile: (userId?: string) => {
    return userId ? `/profile/${userId}` : '/profile';
  }
};

// Usage
<Link href={navigation.toAssessment('vocabulary', 'hsk1')}>
  Start Assessment
</Link>
```

## URL State Management

### Pattern: URL as State Store

Use URL parameters for UI state that should be shareable:

```typescript
// Good: State in URL
/dashboard?view=grid&sort=date&filter=active

// Bad: State only in React
const [view, setView] = useState('grid');
const [sort, setSort] = useState('date');
```

### Implementation with Type Safety

```typescript
// lib/url-state.ts
import { z } from 'zod';

const DashboardParams = z.object({
  view: z.enum(['grid', 'list']).default('grid'),
  sort: z.enum(['date', 'name', 'status']).default('date'),
  filter: z.enum(['all', 'active', 'archived']).default('all'),
  page: z.coerce.number().default(1)
});

export function useDashboardParams() {
  const searchParams = useSearchParams();
  const router = useRouter();
  
  const params = DashboardParams.parse(
    Object.fromEntries(searchParams.entries())
  );
  
  const updateParams = (updates: Partial<z.infer<typeof DashboardParams>>) => {
    const newParams = new URLSearchParams(searchParams);
    Object.entries(updates).forEach(([key, value]) => {
      if (value === undefined) {
        newParams.delete(key);
      } else {
        newParams.set(key, String(value));
      }
    });
    router.push(`?${newParams}`);
  };
  
  return { params, updateParams };
}
```

## Route Guards and Middleware

### Pattern: Declarative Route Protection

```typescript
// middleware.ts
import { NextResponse } from 'next/server';
import type { NextRequest } from 'next/server';

export function middleware(request: NextRequest) {
  const token = request.cookies.get('auth-token');
  const isAuthRoute = request.nextUrl.pathname.startsWith('/(auth)');
  const isProtectedRoute = request.nextUrl.pathname.startsWith('/(app)');
  
  // Redirect authenticated users away from auth routes
  if (token && isAuthRoute) {
    return NextResponse.redirect(new URL('/dashboard', request.url));
  }
  
  // Redirect unauthenticated users to login
  if (!token && isProtectedRoute) {
    const redirectUrl = new URL('/login', request.url);
    redirectUrl.searchParams.set('from', request.nextUrl.pathname);
    return NextResponse.redirect(redirectUrl);
  }
  
  return NextResponse.next();
}

export const config = {
  matcher: ['/(auth)/:path*', '/(app)/:path*']
};
```

## Common Pitfalls and Solutions

### Pitfall 1: Over-Nesting Routes
**Problem**: Deep folder structures become hard to navigate
**Solution**: Keep nesting to 3 levels max, use route groups for organization

### Pitfall 2: Inconsistent Parameter Names
**Problem**: `[id]` vs `[userId]` vs `[user_id]` across routes
**Solution**: Establish naming conventions and stick to them

### Pitfall 3: Client-Side Only Navigation
**Problem**: Breaking browser back button and sharing
**Solution**: Always update URL for significant state changes

### Pitfall 4: Route Naming Conflicts
**Problem**: `/user/settings` vs `/settings/user` confusion
**Solution**: Follow resource-first naming: `/resource/action`

## Testing Routing Logic

### Integration Tests
```typescript
describe('Navigation', () => {
  it('redirects to login when unauthenticated', async () => {
    const response = await fetch('/dashboard', {
      redirect: 'manual'
    });
    expect(response.status).toBe(302);
    expect(response.headers.get('location')).toBe('/login?from=/dashboard');
  });
  
  it('preserves query params through navigation', async () => {
    render(<DashboardPage />, {
      initialEntries: ['/dashboard?view=list&sort=name']
    });
    
    fireEvent.click(screen.getByText('Next Page'));
    
    expect(window.location.search).toBe('?view=list&sort=name&page=2');
  });
});
```

## Best Practices

1. **Use Route Groups** for logical organization and access control
2. **Keep URLs Readable** - `/learn/math/algebra` not `/l/m/a`
3. **Preserve State in URLs** for shareable and bookmarkable pages
4. **Handle Loading States** during route transitions
5. **Provide Breadcrumbs** for deep navigation hierarchies
6. **Test Navigation Flows** including edge cases and errors
7. **Document Route Structure** in your README or docs

## Migration Strategy

When migrating from one routing approach to another:

1. **Audit Current Routes** - List all routes and their purposes
2. **Design New Structure** - Plan the organization before moving files
3. **Create Redirects** - Maintain old URLs with redirects
4. **Migrate Incrementally** - Move one feature at a time
5. **Update Tests** - Ensure navigation tests still pass
6. **Monitor 404s** - Track broken links after migration

## Conclusion

The choice between file-based and programmatic routing isn't binary. Modern applications benefit from using both approaches where they excel. File-based routing provides excellent DX and SEO benefits, while programmatic routing offers flexibility for complex interactions. The key is knowing when to use each approach and how to combine them effectively.