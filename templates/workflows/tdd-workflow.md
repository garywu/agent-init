# Test-Driven Development (TDD) Workflow

A disciplined approach to writing reliable code by writing tests first.

## Overview

TDD ensures code correctness, improves design, and provides living documentation through tests.

## Workflow Steps

### 1. 🔴 Red Phase - Write Failing Tests

**Goal:** Define expected behavior through tests

```javascript
// Example: User validation tests
describe('User Validation', () => {
  test('should reject empty email', () => {
    const result = validateUser({ email: '', password: 'test123' });
    expect(result.isValid).toBe(false);
    expect(result.errors).toContain('Email is required');
  });

  test('should reject invalid email format', () => {
    const result = validateUser({ email: 'notanemail', password: 'test123' });
    expect(result.isValid).toBe(false);
    expect(result.errors).toContain('Invalid email format');
  });

  test('should accept valid user', () => {
    const result = validateUser({ email: 'user@example.com', password: 'test123' });
    expect(result.isValid).toBe(true);
    expect(result.errors).toHaveLength(0);
  });
});
```

**Commands:**
```bash
# Have Claude write tests
"Write comprehensive tests for user authentication"
"Create test cases for the shopping cart calculations"
"Add edge case tests for date parsing"
```

### 2. 🟢 Green Phase - Write Minimal Code

**Goal:** Make tests pass with simplest implementation

```javascript
// Example: Minimal implementation
function validateUser(userData) {
  const errors = [];
  
  if (!userData.email) {
    errors.push('Email is required');
  } else if (!userData.email.includes('@')) {
    errors.push('Invalid email format');
  }
  
  return {
    isValid: errors.length === 0,
    errors
  };
}
```

**Best practices:**
- Write only enough code to pass tests
- Don't add features not covered by tests
- Keep implementation simple
- Run tests frequently

### 3. 🔵 Refactor Phase - Improve Code Quality

**Goal:** Optimize and clean up while keeping tests green

```javascript
// Example: Refactored implementation
const EMAIL_REGEX = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;

class UserValidator {
  constructor() {
    this.rules = [
      { field: 'email', validator: this.validateEmail },
      { field: 'password', validator: this.validatePassword }
    ];
  }

  validateEmail(email) {
    if (!email) return 'Email is required';
    if (!EMAIL_REGEX.test(email)) return 'Invalid email format';
    return null;
  }

  validate(userData) {
    const errors = this.rules
      .map(rule => rule.validator(userData[rule.field]))
      .filter(error => error !== null);
    
    return {
      isValid: errors.length === 0,
      errors
    };
  }
}
```

**Refactoring checklist:**
- [ ] Extract constants
- [ ] Remove duplication
- [ ] Improve naming
- [ ] Simplify logic
- [ ] Add type safety

### 4. 🔄 Repeat Cycle

Continue adding tests and features incrementally.

## Example TDD Session

```bash
# Step 1: Request tests
User: "Create a price calculator for our e-commerce cart with discount support"

# Claude writes failing tests
Claude: "I'll start by writing comprehensive tests for the price calculator:"
```

```javascript
describe('PriceCalculator', () => {
  let calculator;
  
  beforeEach(() => {
    calculator = new PriceCalculator();
  });

  test('calculates subtotal correctly', () => {
    const items = [
      { price: 10, quantity: 2 },
      { price: 5, quantity: 3 }
    ];
    expect(calculator.getSubtotal(items)).toBe(35);
  });

  test('applies percentage discount', () => {
    const subtotal = 100;
    expect(calculator.applyDiscount(subtotal, { type: 'percentage', value: 10 })).toBe(90);
  });

  test('applies fixed discount', () => {
    const subtotal = 100;
    expect(calculator.applyDiscount(subtotal, { type: 'fixed', value: 15 })).toBe(85);
  });

  test('handles invalid discount gracefully', () => {
    const subtotal = 100;
    expect(calculator.applyDiscount(subtotal, { type: 'invalid', value: 10 })).toBe(100);
  });
});
```

```bash
# Step 2: Run tests (should fail)
User: "Run the tests"
Claude: "Running tests... All tests fail as expected since PriceCalculator doesn't exist yet."

# Step 3: Implement minimal code
User: "Now implement the PriceCalculator to pass these tests"

# Claude implements
Claude: "I'll implement the minimal code to pass all tests:"
```

```javascript
class PriceCalculator {
  getSubtotal(items) {
    return items.reduce((total, item) => total + (item.price * item.quantity), 0);
  }

  applyDiscount(subtotal, discount) {
    if (!discount || !discount.type) return subtotal;
    
    switch (discount.type) {
      case 'percentage':
        return subtotal * (1 - discount.value / 100);
      case 'fixed':
        return subtotal - discount.value;
      default:
        return subtotal;
    }
  }
}
```

```bash
# Step 4: Verify tests pass
User: "Run the tests again"
Claude: "All tests are now passing! ✅"

# Step 5: Refactor if needed
User: "Can we improve this implementation?"
Claude: "Let me refactor for better maintainability:"
```

## Advanced TDD Patterns

### 1. Parameterized Tests

```javascript
test.each([
  ['', false, 'Email is required'],
  ['invalid', false, 'Invalid email format'],
  ['test@example.com', true, null],
])('validates email "%s"', (email, isValid, expectedError) => {
  const result = validateEmail(email);
  expect(result.isValid).toBe(isValid);
  if (expectedError) {
    expect(result.error).toBe(expectedError);
  }
});
```

### 2. Test Doubles (Mocks/Stubs)

```javascript
test('sends welcome email on user creation', async () => {
  const mockEmailService = jest.fn();
  const userService = new UserService(mockEmailService);
  
  await userService.createUser({ email: 'test@example.com' });
  
  expect(mockEmailService).toHaveBeenCalledWith(
    'test@example.com',
    'Welcome!',
    expect.any(String)
  );
});
```

### 3. Integration Tests

```javascript
test('complete checkout flow', async () => {
  const { cart, payment, order } = await setupTestData();
  
  const result = await checkoutService.process({
    cartId: cart.id,
    paymentMethod: payment,
    shippingAddress: testAddress
  });
  
  expect(result.success).toBe(true);
  expect(result.orderId).toBeDefined();
  expect(await getOrder(result.orderId)).toMatchObject({
    status: 'confirmed',
    total: cart.total
  });
});
```

## Tips for Success

1. **Write tests from user perspective**
   - Test behavior, not implementation
   - Use descriptive test names
   - Cover edge cases

2. **Keep tests fast**
   - Mock external dependencies
   - Use test databases
   - Parallelize when possible

3. **Maintain test quality**
   - Avoid test duplication
   - Keep tests simple
   - Update tests with code changes

4. **Use TDD for:**
   - ✅ Business logic
   - ✅ Algorithms
   - ✅ Data transformations
   - ✅ API contracts
   - ❌ UI styling
   - ❌ External integrations (use integration tests)

## Common Pitfalls

1. **Writing implementation-aware tests**
   ```javascript
   // ❌ Bad: Tests internal implementation
   expect(calculator._internalMethod()).toBe(5);
   
   // ✅ Good: Tests public behavior
   expect(calculator.calculate()).toBe(5);
   ```

2. **Not refactoring**
   - TDD includes refactoring!
   - Clean code is part of the process

3. **Writing too many tests at once**
   - One test at a time
   - Stay focused on current feature

## Customization

Adapt TDD workflow for:
- Different testing frameworks
- Various programming languages
- Team-specific conventions
- Project requirements