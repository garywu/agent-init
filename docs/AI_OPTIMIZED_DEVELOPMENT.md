# AI-Optimized Development Guide

## Overview

This guide captures patterns and practices for optimizing codebases for AI assistant collaboration. Based on extensive experience with Claude and similar AI coding assistants, these patterns maximize productivity and minimize friction in AI-assisted development.

## Core Principles

### 1. Context is Everything
AI assistants work within context windows. Structure your project to minimize context switching and maximize relevant information availability.

### 2. Explicit Over Implicit
AI assistants cannot read your mind. Make intentions, patterns, and decisions explicit in code and documentation.

### 3. Self-Documenting Systems
The codebase should explain itself through clear naming, structure, and inline documentation.

## Project Structure Patterns

### 1. The CLAUDE.md Pattern

Every project should have a `CLAUDE.md` file at the root that serves as the AI assistant's guide:

```markdown
# Project Name - AI Assistant Guide

## Quick Start
- Primary language: TypeScript
- Framework: Next.js 15
- Key directories: /src, /app, /lib
- Run: `npm run dev`
- Test: `npm test`

## Current Task
Working on: User authentication system
Branch: feat/auth
Related issues: #23, #24

## Key Decisions
- Using Zustand for state management (not Redux)
- PostgreSQL with Drizzle ORM (not Prisma)
- Tailwind CSS v4 (see migration guide)

## Common Patterns
[Document your project's specific patterns]

## Gotchas
[List known issues and workarounds]
```

### 2. Session Tracking

Maintain context across AI sessions:

```markdown
## Session History

### 2024-01-24 - Feature: Authentication
- Implemented JWT auth
- Added password reset flow
- TODO: Add 2FA support

### 2024-01-23 - Bug Fix: Memory Leak
- Fixed closure issue in useEffect
- Refactored event listeners
- See: components/Dashboard.tsx
```

### 3. Decision Documentation

Document why, not just what:

```typescript
// We use refs here instead of state because this value
// changes during animation loops and would cause stale
// closures with useState. See issue #45.
const countRef = useRef(0);

// NOT just:
// const countRef = useRef(0);
```

## Code Organization for AI

### 1. Modular File Structure

Keep files focused and under 300 lines:

```
src/
├── features/
│   ├── auth/
│   │   ├── components/     # UI components
│   │   ├── hooks/          # Business logic
│   │   ├── services/       # API calls
│   │   ├── types.ts        # TypeScript types
│   │   └── index.ts        # Public API
│   └── user/
│       └── ...same structure
```

### 2. Clear Dependencies

Make dependencies explicit:

```typescript
// hooks/useAuth.ts
import { authService } from '../services/auth';
import { userStore } from '@/stores/user';
import type { User, LoginCredentials } from '../types';

// Clear about what this module depends on
export function useAuth() {
  // ...
}
```

### 3. Type-First Development

Define types before implementation:

```typescript
// types/api.ts
export interface ApiResponse<T> {
  data: T;
  error: string | null;
  timestamp: number;
}

export interface PaginatedResponse<T> extends ApiResponse<T[]> {
  page: number;
  totalPages: number;
  hasMore: boolean;
}

// Now AI knows exactly what shape data should have
```

## Documentation Patterns

### 1. Function Documentation

Document complex functions with examples:

```typescript
/**
 * Calculates the optimal grid layout for items within viewport constraints.
 * Uses dynamic programming to minimize wasted space.
 *
 * @param viewport - Available width and height
 * @param itemConstraints - Min/max dimensions for items
 * @param gaps - Spacing configuration
 * @returns Optimal rows, columns, and item dimensions
 *
 * @example
 * const layout = calculateOptimalGrid(
 *   { width: 1200, height: 800 },
 *   { minWidth: 100, minHeight: 100 },
 *   { gridGap: 16 }
 * );
 * // Returns: { rows: 4, columns: 6, itemWidth: 180, itemHeight: 180 }
 */
export function calculateOptimalGrid(
  viewport: Dimensions,
  itemConstraints: ItemConstraints,
  gaps: GapConfig
): GridLayout {
  // Implementation
}
```

### 2. Component Documentation

Document component contracts:

```typescript
interface DashboardProps {
  /**
   * User data to display. If null, shows loading state.
   */
  user: User | null;

  /**
   * Called when user requests refresh.
   * Should update the user prop asynchronously.
   */
  onRefresh: () => void;

  /**
   * Optional custom styling classes.
   * @default ""
   */
  className?: string;
}

/**
 * Main dashboard component showing user statistics and recent activity.
 * Automatically polls for updates every 30 seconds when visible.
 *
 * @example
 * <Dashboard
 *   user={currentUser}
 *   onRefresh={handleRefresh}
 *   className="max-w-7xl mx-auto"
 * />
 */
export function Dashboard({ user, onRefresh, className = "" }: DashboardProps) {
  // Implementation
}
```

### 3. Error Documentation

Document error handling patterns:

```typescript
// services/api.ts

/**
 * API client with automatic retry and error handling.
 *
 * Error scenarios:
 * - Network errors: Retries up to 3 times with exponential backoff
 * - 401: Redirects to login
 * - 403: Shows permission denied message
 * - 404: Returns null (not found is not an error)
 * - 500+: Logs to error tracking and shows user message
 */
export const apiClient = {
  async get<T>(url: string): Promise<T | null> {
    try {
      // Implementation
    } catch (error) {
      // Detailed error handling
    }
  }
};
```

## Testing Patterns for AI

### 1. Descriptive Test Names

Write tests that serve as documentation:

```typescript
describe('Shopping Cart', () => {
  describe('when adding items', () => {
    it('should add new item to empty cart', async () => {
      // Test implementation
    });

    it('should increment quantity for existing item', async () => {
      // Test implementation
    });

    it('should respect maximum quantity limit of 99', async () => {
      // Test implementation
    });

    it('should maintain cart state across page refreshes', async () => {
      // Test implementation
    });
  });
});
```

### 2. Test Utilities

Create test utilities that make intentions clear:

```typescript
// test-utils/builders.ts

export const buildUser = (overrides?: Partial<User>): User => ({
  id: 'test-user-id',
  email: 'test@example.com',
  name: 'Test User',
  role: 'member',
  createdAt: new Date('2024-01-01'),
  ...overrides
});

export const buildAuthContext = (user?: User): AuthContextValue => ({
  user: user ?? buildUser(),
  login: jest.fn(),
  logout: jest.fn(),
  isLoading: false
});
```

## Common Patterns

### 1. Configuration Objects

Group related constants:

```typescript
// Bad: Scattered magic numbers
const padding = 16;
const margin = 24;
const borderRadius = 8;

// Good: Centralized configuration
const SPACING = {
  page: {
    padding: 16,
    margin: 24
  },
  card: {
    padding: 12,
    gap: 8,
    borderRadius: 8
  },
  grid: {
    gap: 16,
    minItemWidth: 200
  }
} as const;
```

### 2. Error Boundaries

Implement graceful error handling:

```typescript
// components/ErrorBoundary.tsx
interface ErrorBoundaryState {
  hasError: boolean;
  error: Error | null;
}

export class ErrorBoundary extends Component<PropsWithChildren, ErrorBoundaryState> {
  constructor(props: PropsWithChildren) {
    super(props);
    this.state = { hasError: false, error: null };
  }

  static getDerivedStateFromError(error: Error): ErrorBoundaryState {
    // Log to error tracking service
    errorTracker.logError(error);
    return { hasError: true, error };
  }

  render() {
    if (this.state.hasError) {
      return (
        <ErrorFallback
          error={this.state.error}
          resetError={() => this.setState({ hasError: false, error: null })}
        />
      );
    }

    return this.props.children;
  }
}
```

### 3. Feature Flags

Make features toggleable:

```typescript
// lib/features.ts
export const features = {
  newDashboard: process.env.NEXT_PUBLIC_FEATURE_NEW_DASHBOARD === 'true',
  aiAssistant: process.env.NEXT_PUBLIC_FEATURE_AI_ASSISTANT === 'true',
  betaFeatures: process.env.NEXT_PUBLIC_FEATURE_BETA === 'true'
} as const;

// Usage
if (features.newDashboard) {
  return <NewDashboard />;
}
return <LegacyDashboard />;
```

## Anti-Patterns to Avoid

### 1. Implicit Knowledge
```typescript
// Bad: AI can't know why 7
if (items.length > 7) {
  setShowPagination(true);
}

// Good: Explicit constant
const MAX_ITEMS_BEFORE_PAGINATION = 7;
if (items.length > MAX_ITEMS_BEFORE_PAGINATION) {
  setShowPagination(true);
}
```

### 2. Scattered Configuration
```typescript
// Bad: Hardcoded values throughout
<div className="p-4 m-2 rounded-lg">

// Good: Centralized
<div className={cn(
  "p-4 m-2 rounded-lg",
  styles.card
)}>
```

### 3. Missing Context
```typescript
// Bad: No explanation
const delay = index * 50;

// Good: Clear purpose
// Stagger animations by 50ms per item for cascade effect
const animationDelay = index * 50;
```

## Prompt Engineering for Development

### 1. Be Specific
```
Bad: "Fix the bug in the dashboard"
Good: "Fix the memory leak in Dashboard.tsx where event listeners aren't cleaned up in useEffect"
```

### 2. Provide Context
```
Bad: "Add authentication"
Good: "Add JWT authentication using our existing auth service pattern (see services/api.ts). Follow the pattern in features/user for module structure."
```

### 3. Reference Examples
```
Bad: "Make it responsive"
Good: "Make the grid responsive using our Zero-Out Spacing methodology (see ZERO_OUT_SPACING_METHODOLOGY.md)"
```

## Maintenance Patterns

### 1. TODO Comments
Use standardized TODO format:

```typescript
// TODO: [2024-01-24] Implement retry logic for failed uploads
// See issue #456 for requirements
// Current behavior: Single attempt, fails silently
```

### 2. Deprecation Notices
Mark deprecated code clearly:

```typescript
/**
 * @deprecated Since version 2.0. Use `useAuthContext` instead.
 * Will be removed in version 3.0.
 * Migration guide: docs/migration/auth-v2.md
 */
export function useOldAuth() {
  console.warn('useOldAuth is deprecated. Use useAuthContext instead.');
  // ...
}
```

### 3. Version Comments
Document version-specific code:

```typescript
// Added in v1.5: Support for batch operations
// Note: Requires backend v2.3 or higher
export async function batchUpdate(items: Item[]): Promise<void> {
  if (!features.batchOperations) {
    // Fallback for older backends
    return updateSequentially(items);
  }
  // Batch implementation
}
```

## Conclusion

AI-optimized development is about creating a codebase that serves as its own documentation. By following these patterns, you create a project where AI assistants can quickly understand context, make appropriate decisions, and provide valuable contributions. The investment in clear structure and documentation pays dividends in development velocity and code quality.