# XState Patterns for Production Applications

## Overview

This document captures proven XState patterns discovered through production use. XState solves critical state management issues including race conditions, impossible states, and complex async flows.

## When to Use XState

### Use XState When You Have:
- Complex async operations with multiple states
- Race conditions from concurrent API calls
- Multi-step workflows or wizards
- State that depends on sequences of events
- Need for state visualization and debugging
- Complex business logic with many conditions

### Don't Use XState For:
- Simple boolean flags
- Basic form state (use form libraries)
- Static UI state that doesn't change
- One-time data fetching

## Core Patterns

### 1. Async Data Fetching Pattern

Handles loading, success, error, and retry states systematically.

```typescript
import { createMachine, assign } from 'xstate';

const fetchMachine = createMachine({
  id: 'fetch',
  initial: 'idle',
  context: {
    data: null,
    error: null,
    retryCount: 0
  },
  states: {
    idle: {
      on: {
        FETCH: 'loading'
      }
    },
    loading: {
      invoke: {
        id: 'fetchData',
        src: 'fetchData',
        onDone: {
          target: 'success',
          actions: assign({
            data: (_, event) => event.data,
            error: null
          })
        },
        onError: {
          target: 'error',
          actions: assign({
            error: (_, event) => event.data,
            retryCount: (context) => context.retryCount + 1
          })
        }
      }
    },
    success: {
      on: {
        REFRESH: 'loading'
      }
    },
    error: {
      on: {
        RETRY: {
          target: 'loading',
          cond: (context) => context.retryCount < 3
        }
      }
    }
  }
});
```

### 2. Multi-Step Form/Wizard Pattern

Manages complex forms with validation and step navigation.

```typescript
const wizardMachine = createMachine({
  id: 'wizard',
  initial: 'step1',
  context: {
    step1Data: {},
    step2Data: {},
    step3Data: {},
    currentStep: 1,
    canGoBack: false,
    canGoForward: false
  },
  states: {
    step1: {
      entry: assign({
        currentStep: 1,
        canGoBack: false
      }),
      on: {
        NEXT: {
          target: 'step2',
          cond: 'isStep1Valid'
        },
        UPDATE_STEP1: {
          actions: assign({
            step1Data: (_, event) => event.data
          })
        }
      }
    },
    step2: {
      entry: assign({
        currentStep: 2,
        canGoBack: true
      }),
      on: {
        NEXT: {
          target: 'step3',
          cond: 'isStep2Valid'
        },
        BACK: 'step1',
        UPDATE_STEP2: {
          actions: assign({
            step2Data: (_, event) => event.data
          })
        }
      }
    },
    step3: {
      entry: assign({
        currentStep: 3,
        canGoBack: true,
        canGoForward: false
      }),
      on: {
        BACK: 'step2',
        SUBMIT: 'submitting',
        UPDATE_STEP3: {
          actions: assign({
            step3Data: (_, event) => event.data
          })
        }
      }
    },
    submitting: {
      invoke: {
        src: 'submitForm',
        onDone: 'success',
        onError: 'step3'
      }
    },
    success: {
      type: 'final'
    }
  }
});
```

### 3. Debounced Search Pattern

Prevents excessive API calls while providing responsive search.

```typescript
const searchMachine = createMachine({
  id: 'search',
  initial: 'idle',
  context: {
    query: '',
    results: [],
    error: null
  },
  states: {
    idle: {
      on: {
        TYPE: {
          target: 'debouncing',
          actions: assign({
            query: (_, event) => event.query
          })
        }
      }
    },
    debouncing: {
      on: {
        TYPE: {
          target: 'debouncing',
          actions: assign({
            query: (_, event) => event.query
          })
        }
      },
      after: {
        300: [
          {
            target: 'searching',
            cond: (context) => context.query.length > 2
          },
          {
            target: 'idle'
          }
        ]
      }
    },
    searching: {
      invoke: {
        src: 'searchAPI',
        onDone: {
          target: 'idle',
          actions: assign({
            results: (_, event) => event.data,
            error: null
          })
        },
        onError: {
          target: 'idle',
          actions: assign({
            error: (_, event) => event.data,
            results: []
          })
        }
      },
      on: {
        TYPE: {
          target: 'debouncing',
          actions: assign({
            query: (_, event) => event.query
          })
        }
      }
    }
  }
});
```

### 4. Connection/Reconnection Pattern

Handles network connections with automatic retry and backoff.

```typescript
const connectionMachine = createMachine({
  id: 'connection',
  initial: 'disconnected',
  context: {
    retries: 0,
    maxRetries: 5,
    backoffMs: 1000
  },
  states: {
    disconnected: {
      on: {
        CONNECT: 'connecting'
      }
    },
    connecting: {
      invoke: {
        src: 'attemptConnection',
        onDone: {
          target: 'connected',
          actions: assign({ retries: 0 })
        },
        onError: [
          {
            target: 'retrying',
            cond: (context) => context.retries < context.maxRetries
          },
          {
            target: 'failed'
          }
        ]
      }
    },
    connected: {
      on: {
        DISCONNECT: 'disconnected',
        CONNECTION_LOST: 'retrying'
      }
    },
    retrying: {
      entry: assign({
        retries: (context) => context.retries + 1
      }),
      after: {
        BACKOFF_DELAY: 'connecting'
      }
    },
    failed: {
      on: {
        RETRY: {
          target: 'connecting',
          actions: assign({ retries: 0 })
        }
      }
    }
  }
}, {
  delays: {
    BACKOFF_DELAY: (context) => {
      return Math.min(
        context.backoffMs * Math.pow(2, context.retries),
        30000 // Max 30 seconds
      );
    }
  }
});
```

### 5. Polling Pattern

Periodically fetches data with start/stop control.

```typescript
const pollingMachine = createMachine({
  id: 'polling',
  initial: 'stopped',
  context: {
    data: null,
    interval: 5000,
    error: null
  },
  states: {
    stopped: {
      on: {
        START: 'running'
      }
    },
    running: {
      initial: 'fetching',
      states: {
        fetching: {
          invoke: {
            src: 'fetchData',
            onDone: {
              target: 'waiting',
              actions: assign({
                data: (_, event) => event.data,
                error: null
              })
            },
            onError: {
              target: 'waiting',
              actions: assign({
                error: (_, event) => event.data
              })
            }
          }
        },
        waiting: {
          after: {
            POLL_INTERVAL: 'fetching'
          }
        }
      },
      on: {
        STOP: 'stopped',
        UPDATE_INTERVAL: {
          actions: assign({
            interval: (_, event) => event.interval
          })
        }
      }
    }
  }
}, {
  delays: {
    POLL_INTERVAL: (context) => context.interval
  }
});
```

## React Integration Patterns

### Custom Hook Pattern

```typescript
import { useMachine } from '@xstate/react';

function useDataFetcher(url: string) {
  const [state, send] = useMachine(fetchMachine, {
    services: {
      fetchData: async () => {
        const response = await fetch(url);
        if (!response.ok) throw new Error('Fetch failed');
        return response.json();
      }
    }
  });

  return {
    data: state.context.data,
    error: state.context.error,
    isLoading: state.matches('loading'),
    isError: state.matches('error'),
    fetch: () => send('FETCH'),
    retry: () => send('RETRY')
  };
}
```

### Component Organization

```typescript
// ComponentName.machine.ts
export const componentMachine = createMachine({...});

// ComponentName.hooks.ts
export function useComponentMachine() {
  const [state, send] = useMachine(componentMachine);

  // Selectors
  const isLoading = state.matches('loading');
  const hasError = state.matches('error');

  // Actions
  const actions = {
    submit: (data) => send({ type: 'SUBMIT', data }),
    reset: () => send('RESET')
  };

  return {
    state: state.value,
    context: state.context,
    isLoading,
    hasError,
    ...actions
  };
}

// ComponentName.tsx
export function ComponentName() {
  const machine = useComponentMachine();

  return (
    <div>
      {machine.isLoading && <Spinner />}
      {machine.hasError && <Error message={machine.context.error} />}
      {/* Component UI */}
    </div>
  );
}
```

## Testing Patterns

### Testing State Machines

```typescript
import { interpret } from 'xstate';

describe('FetchMachine', () => {
  it('should transition from idle to loading on FETCH', () => {
    const service = interpret(fetchMachine).start();

    service.send('FETCH');
    expect(service.state.value).toBe('loading');
  });

  it('should retry up to 3 times', () => {
    const service = interpret(fetchMachine).start();

    // Simulate failures
    service.send('FETCH');
    service.state.context.retryCount = 2;
    service.send({ type: 'error.platform.fetchData' });

    expect(service.state.value).toBe('error');
    expect(service.state.can('RETRY')).toBe(true);

    // Fourth failure should not allow retry
    service.state.context.retryCount = 3;
    expect(service.state.can('RETRY')).toBe(false);
  });
});
```

### Testing React Components

```typescript
import { render, screen, waitFor } from '@testing-library/react';
import userEvent from '@testing-library/user-event';

it('should show loading state during fetch', async () => {
  render(<DataFetcher />);

  const fetchButton = screen.getByText('Fetch Data');
  userEvent.click(fetchButton);

  expect(screen.getByText('Loading...')).toBeInTheDocument();

  await waitFor(() => {
    expect(screen.queryByText('Loading...')).not.toBeInTheDocument();
  });
});
```

## Common Pitfalls and Solutions

### Pitfall 1: Overusing Context
**Problem**: Putting everything in machine context
**Solution**: Only store what's needed for state logic

```typescript
// Bad - UI state in machine
context: {
  isDropdownOpen: false,
  hoveredItemId: null,
  formData: {...}
}

// Good - only business state
context: {
  formData: {...},
  validationErrors: {...}
}
```

### Pitfall 2: Complex Nested States
**Problem**: Deeply nested parallel states become hard to reason about
**Solution**: Split into multiple machines that communicate

### Pitfall 3: Not Using Guards
**Problem**: Complex logic in actions
**Solution**: Use guards (conditions) for state transition logic

```typescript
// Bad
on: {
  SUBMIT: {
    actions: (context) => {
      if (context.isValid && context.hasPermission) {
        // submit logic
      }
    }
  }
}

// Good
on: {
  SUBMIT: {
    target: 'submitting',
    cond: 'canSubmit'
  }
}
```

## Migration Strategy

### From useState/useReducer to XState

1. **Identify State Complexity**: Look for multiple boolean flags, complex conditions
2. **Map States**: Convert combinations of flags to explicit states
3. **Define Transitions**: Convert conditional logic to state transitions
4. **Add Services**: Convert async operations to invoked services
5. **Test Incrementally**: Migrate one feature at a time

### Example Migration

```typescript
// Before - Multiple flags
const [isLoading, setIsLoading] = useState(false);
const [error, setError] = useState(null);
const [data, setData] = useState(null);

async function fetchData() {
  setIsLoading(true);
  setError(null);
  try {
    const result = await api.fetch();
    setData(result);
  } catch (err) {
    setError(err);
  } finally {
    setIsLoading(false);
  }
}

// After - State machine
const machine = createMachine({
  initial: 'idle',
  states: {
    idle: { on: { FETCH: 'loading' } },
    loading: {
      invoke: {
        src: 'fetchData',
        onDone: { target: 'success', actions: 'setData' },
        onError: { target: 'error', actions: 'setError' }
      }
    },
    success: { on: { REFRESH: 'loading' } },
    error: { on: { RETRY: 'loading' } }
  }
});
```

## Best Practices

1. **Keep Machines Focused**: One machine per feature/concern
2. **Use TypeScript**: Generate types from machines for safety
3. **Visualize States**: Use XState visualizer during development
4. **Name States Clearly**: Use business domain language
5. **Document Transitions**: Add comments for complex logic
6. **Test State Logic**: Test machines independently from UI
7. **Use Actor Model**: Spawn child machines for sub-features

## Conclusion

XState transforms complex state management from a source of bugs into a predictable, testable system. These patterns have been proven in production and solve real-world state management challenges. Start with simple machines and gradually adopt more advanced patterns as needed.