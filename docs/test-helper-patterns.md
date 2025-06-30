# Test Helper Patterns

Reusable patterns and utilities for writing robust tests across different languages and testing frameworks.

## Shell Script Testing

### Basic Test Framework

```bash
#!/usr/bin/env bash
# test-helpers.sh - Reusable test utilities

set -euo pipefail

# Color setup for test output
if [[ -t 1 ]] && [[ -n "${TERM:-}" ]] && command -v tput &>/dev/null; then
    RED=$(tput setaf 1)
    GREEN=$(tput setaf 2)
    YELLOW=$(tput setaf 3)
    BLUE=$(tput setaf 4)
    RESET=$(tput sgr0)
else
    RED=''
    GREEN=''
    YELLOW=''
    BLUE=''
    RESET=''
fi

# Test counters
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0
TESTS_SKIPPED=0

# Test assertion functions
assert_equals() {
    local expected="$1"
    local actual="$2"
    local message="${3:-}"

    TESTS_RUN=$((TESTS_RUN + 1))

    if [[ "$expected" == "$actual" ]]; then
        TESTS_PASSED=$((TESTS_PASSED + 1))
        echo -e "${GREEN}✓${RESET} $message"
        return 0
    else
        TESTS_FAILED=$((TESTS_FAILED + 1))
        echo -e "${RED}✗${RESET} $message"
        echo -e "  Expected: $expected"
        echo -e "  Actual:   $actual"
        return 1
    fi
}

assert_not_equals() {
    local unexpected="$1"
    local actual="$2"
    local message="${3:-}"

    TESTS_RUN=$((TESTS_RUN + 1))

    if [[ "$unexpected" != "$actual" ]]; then
        TESTS_PASSED=$((TESTS_PASSED + 1))
        echo -e "${GREEN}✓${RESET} $message"
        return 0
    else
        TESTS_FAILED=$((TESTS_FAILED + 1))
        echo -e "${RED}✗${RESET} $message"
        echo -e "  Should not equal: $unexpected"
        return 1
    fi
}

assert_true() {
    local condition="$1"
    local message="${2:-}"

    TESTS_RUN=$((TESTS_RUN + 1))

    if eval "$condition"; then
        TESTS_PASSED=$((TESTS_PASSED + 1))
        echo -e "${GREEN}✓${RESET} $message"
        return 0
    else
        TESTS_FAILED=$((TESTS_FAILED + 1))
        echo -e "${RED}✗${RESET} $message"
        echo -e "  Condition failed: $condition"
        return 1
    fi
}

assert_false() {
    local condition="$1"
    local message="${2:-}"

    TESTS_RUN=$((TESTS_RUN + 1))

    if ! eval "$condition"; then
        TESTS_PASSED=$((TESTS_PASSED + 1))
        echo -e "${GREEN}✓${RESET} $message"
        return 0
    else
        TESTS_FAILED=$((TESTS_FAILED + 1))
        echo -e "${RED}✗${RESET} $message"
        echo -e "  Condition should be false: $condition"
        return 1
    fi
}

assert_contains() {
    local haystack="$1"
    local needle="$2"
    local message="${3:-}"

    TESTS_RUN=$((TESTS_RUN + 1))

    if [[ "$haystack" == *"$needle"* ]]; then
        TESTS_PASSED=$((TESTS_PASSED + 1))
        echo -e "${GREEN}✓${RESET} $message"
        return 0
    else
        TESTS_FAILED=$((TESTS_FAILED + 1))
        echo -e "${RED}✗${RESET} $message"
        echo -e "  String: '$haystack'"
        echo -e "  Should contain: '$needle'"
        return 1
    fi
}

assert_file_exists() {
    local file="$1"
    local message="${2:-File should exist: $file}"

    TESTS_RUN=$((TESTS_RUN + 1))

    if [[ -f "$file" ]]; then
        TESTS_PASSED=$((TESTS_PASSED + 1))
        echo -e "${GREEN}✓${RESET} $message"
        return 0
    else
        TESTS_FAILED=$((TESTS_FAILED + 1))
        echo -e "${RED}✗${RESET} $message"
        echo -e "  File not found: $file"
        return 1
    fi
}

assert_command_success() {
    local command="$1"
    local message="${2:-Command should succeed: $command}"

    TESTS_RUN=$((TESTS_RUN + 1))

    if eval "$command" &>/dev/null; then
        TESTS_PASSED=$((TESTS_PASSED + 1))
        echo -e "${GREEN}✓${RESET} $message"
        return 0
    else
        local exit_code=$?
        TESTS_FAILED=$((TESTS_FAILED + 1))
        echo -e "${RED}✗${RESET} $message"
        echo -e "  Exit code: $exit_code"
        return 1
    fi
}

assert_command_failure() {
    local command="$1"
    local message="${2:-Command should fail: $command}"

    TESTS_RUN=$((TESTS_RUN + 1))

    if ! eval "$command" &>/dev/null; then
        TESTS_PASSED=$((TESTS_PASSED + 1))
        echo -e "${GREEN}✓${RESET} $message"
        return 0
    else
        TESTS_FAILED=$((TESTS_FAILED + 1))
        echo -e "${RED}✗${RESET} $message"
        echo -e "  Command succeeded unexpectedly"
        return 1
    fi
}

# Test execution helpers
run_test() {
    local test_name="$1"
    local test_function="$2"

    echo -e "\n${BLUE}Running: $test_name${RESET}"

    # Run in subshell to isolate
    (
        set +e  # Don't exit on test failure
        "$test_function"
    )
}

skip_test() {
    local test_name="$1"
    local reason="${2:-}"

    TESTS_SKIPPED=$((TESTS_SKIPPED + 1))
    echo -e "\n${YELLOW}Skipped: $test_name${RESET}"
    [[ -n "$reason" ]] && echo -e "  Reason: $reason"
}

# Test summary
print_test_summary() {
    echo -e "\n${BLUE}Test Summary:${RESET}"
    echo -e "  Total:   $TESTS_RUN"
    echo -e "  ${GREEN}Passed:  $TESTS_PASSED${RESET}"
    echo -e "  ${RED}Failed:  $TESTS_FAILED${RESET}"
    echo -e "  ${YELLOW}Skipped: $TESTS_SKIPPED${RESET}"

    if [[ $TESTS_FAILED -gt 0 ]]; then
        return 1
    fi
    return 0
}
```

### Platform Detection Helpers

```bash
# Platform and environment detection
is_macos() {
    [[ "$(uname -s)" == "Darwin" ]]
}

is_linux() {
    [[ "$(uname -s)" == "Linux" ]]
}

is_wsl() {
    [[ -f /proc/version ]] && grep -qi microsoft /proc/version
}

is_ci() {
    [[ -n "${CI:-}" ]] || [[ -n "${CONTINUOUS_INTEGRATION:-}" ]]
}

is_root() {
    [[ $EUID -eq 0 ]]
}

has_command() {
    command -v "$1" &>/dev/null
}

has_brew() {
    has_command brew
}

has_apt() {
    has_command apt-get
}

has_yum() {
    has_command yum
}

# Skip tests based on conditions
skip_if_not_macos() {
    is_macos || skip_test "$1" "Not running on macOS"
}

skip_if_not_linux() {
    is_linux || skip_test "$1" "Not running on Linux"
}

skip_if_ci() {
    is_ci && skip_test "$1" "Skipping in CI environment"
}

skip_if_root() {
    is_root && skip_test "$1" "Cannot run as root"
}

skip_if_missing_command() {
    local command="$1"
    local test_name="$2"
    has_command "$command" || skip_test "$test_name" "Missing command: $command"
}
```

### Setup and Teardown

```bash
# Test lifecycle management
TEST_TEMP_DIR=""

setup_test_environment() {
    # Create temporary directory
    TEST_TEMP_DIR=$(mktemp -d)
    export TEST_TEMP_DIR

    # Save current directory
    export TEST_ORIGINAL_DIR=$(pwd)

    # Change to temp directory
    cd "$TEST_TEMP_DIR"

    # Set up any test fixtures
    setup_fixtures
}

teardown_test_environment() {
    # Return to original directory
    cd "$TEST_ORIGINAL_DIR"

    # Clean up temp directory
    if [[ -n "$TEST_TEMP_DIR" ]] && [[ -d "$TEST_TEMP_DIR" ]]; then
        rm -rf "$TEST_TEMP_DIR"
    fi
}

# Run setup before all tests
trap teardown_test_environment EXIT

# Fixture helpers
setup_fixtures() {
    # Create common test files
    mkdir -p "$TEST_TEMP_DIR"/{src,test,config}

    # Create sample files
    echo "test content" > "$TEST_TEMP_DIR/test.txt"
    echo '{"key": "value"}' > "$TEST_TEMP_DIR/test.json"
}

create_test_file() {
    local filename="$1"
    local content="${2:-test content}"
    echo "$content" > "$TEST_TEMP_DIR/$filename"
}

create_test_script() {
    local filename="$1"
    local content="$2"

    cat > "$TEST_TEMP_DIR/$filename" << EOF
#!/usr/bin/env bash
$content
EOF
    chmod +x "$TEST_TEMP_DIR/$filename"
}
```

### Mock Functions

```bash
# Function mocking
declare -A MOCK_OUTPUTS
declare -A MOCK_EXIT_CODES
declare -A MOCK_CALL_COUNTS

mock_command() {
    local command="$1"
    local output="${2:-}"
    local exit_code="${3:-0}"

    MOCK_OUTPUTS["$command"]="$output"
    MOCK_EXIT_CODES["$command"]="$exit_code"
    MOCK_CALL_COUNTS["$command"]=0

    # Create mock function
    eval "
$command() {
    MOCK_CALL_COUNTS['$command']=\$((\${MOCK_CALL_COUNTS['$command']} + 1))
    [[ -n \"\${MOCK_OUTPUTS['$command']}\" ]] && echo \"\${MOCK_OUTPUTS['$command']}\"
    return \${MOCK_EXIT_CODES['$command']}
}
"
}

unmock_command() {
    local command="$1"
    unset -f "$command"
    unset MOCK_OUTPUTS["$command"]
    unset MOCK_EXIT_CODES["$command"]
    unset MOCK_CALL_COUNTS["$command"]
}

assert_mock_called() {
    local command="$1"
    local expected_count="${2:-1}"
    local actual_count="${MOCK_CALL_COUNTS[$command]:-0}"

    assert_equals "$expected_count" "$actual_count" "Mock '$command' should be called $expected_count time(s)"
}

# Example usage
test_with_mocks() {
    # Mock git command
    mock_command "git" "main" 0

    # Test function that uses git
    result=$(git branch --show-current)

    # Assertions
    assert_equals "main" "$result" "Should return mocked git output"
    assert_mock_called "git" 1

    # Clean up
    unmock_command "git"
}
```

## JavaScript/Node.js Test Helpers

### Jest Utilities

```javascript
// test-helpers.js

// Custom matchers
expect.extend({
  toBeWithinRange(received, floor, ceiling) {
    const pass = received >= floor && received <= ceiling;
    if (pass) {
      return {
        message: () => `expected ${received} not to be within range ${floor} - ${ceiling}`,
        pass: true,
      };
    } else {
      return {
        message: () => `expected ${received} to be within range ${floor} - ${ceiling}`,
        pass: false,
      };
    }
  },

  toHaveBeenCalledWithMatch(received, expected) {
    const calls = received.mock.calls;
    const pass = calls.some(call =>
      call.some(arg => JSON.stringify(arg).includes(expected))
    );

    return {
      pass,
      message: () => pass
        ? `expected mock not to have been called with argument matching "${expected}"`
        : `expected mock to have been called with argument matching "${expected}"`,
    };
  },
});

// Test data factories
class TestDataFactory {
  static counter = 0;

  static createUser(overrides = {}) {
    return {
      id: ++this.counter,
      name: `User ${this.counter}`,
      email: `user${this.counter}@example.com`,
      createdAt: new Date(),
      ...overrides,
    };
  }

  static createPost(overrides = {}) {
    return {
      id: ++this.counter,
      title: `Post ${this.counter}`,
      content: 'Lorem ipsum dolor sit amet',
      authorId: 1,
      createdAt: new Date(),
      ...overrides,
    };
  }

  static reset() {
    this.counter = 0;
  }
}

// Async test helpers
const waitFor = async (condition, timeout = 5000, interval = 100) => {
  const startTime = Date.now();

  while (Date.now() - startTime < timeout) {
    if (await condition()) {
      return true;
    }
    await new Promise(resolve => setTimeout(resolve, interval));
  }

  throw new Error('Timeout waiting for condition');
};

const waitForElement = async (selector, timeout = 5000) => {
  return waitFor(
    () => document.querySelector(selector) !== null,
    timeout
  );
};

// Mock timers helper
class TimerHelper {
  constructor() {
    this.useRealTimers();
  }

  useFakeTimers() {
    jest.useFakeTimers();
    this.usingFakeTimers = true;
  }

  useRealTimers() {
    jest.useRealTimers();
    this.usingFakeTimers = false;
  }

  async advance(ms) {
    if (this.usingFakeTimers) {
      jest.advanceTimersByTime(ms);
    } else {
      await new Promise(resolve => setTimeout(resolve, ms));
    }
  }

  async runAllTimers() {
    if (this.usingFakeTimers) {
      jest.runAllTimers();
    }
  }
}

// API mocking
class MockAPI {
  constructor() {
    this.handlers = new Map();
  }

  mockEndpoint(method, path, response, status = 200) {
    const key = `${method.toUpperCase()} ${path}`;
    this.handlers.set(key, { response, status });
  }

  async handleRequest(method, path) {
    const key = `${method.toUpperCase()} ${path}`;
    const handler = this.handlers.get(key);

    if (!handler) {
      throw new Error(`No mock handler for ${key}`);
    }

    return {
      status: handler.status,
      json: async () => handler.response,
    };
  }

  reset() {
    this.handlers.clear();
  }
}

module.exports = {
  TestDataFactory,
  waitFor,
  waitForElement,
  TimerHelper,
  MockAPI,
};
```

### Database Test Helpers

```javascript
// db-test-helpers.js

class DatabaseTestHelper {
  constructor(db) {
    this.db = db;
    this.snapshots = [];
  }

  async snapshot() {
    const tables = await this.getTables();
    const snapshot = {};

    for (const table of tables) {
      snapshot[table] = await this.db.select('*').from(table);
    }

    this.snapshots.push(snapshot);
    return snapshot;
  }

  async restore() {
    if (this.snapshots.length === 0) {
      throw new Error('No snapshots to restore');
    }

    const snapshot = this.snapshots.pop();
    const tables = Object.keys(snapshot);

    // Disable foreign keys temporarily
    await this.db.raw('SET FOREIGN_KEY_CHECKS = 0');

    for (const table of tables) {
      await this.db(table).truncate();
      if (snapshot[table].length > 0) {
        await this.db(table).insert(snapshot[table]);
      }
    }

    await this.db.raw('SET FOREIGN_KEY_CHECKS = 1');
  }

  async clean() {
    const tables = await this.getTables();

    await this.db.raw('SET FOREIGN_KEY_CHECKS = 0');
    for (const table of tables) {
      await this.db(table).truncate();
    }
    await this.db.raw('SET FOREIGN_KEY_CHECKS = 1');
  }

  async getTables() {
    const result = await this.db.raw(
      "SELECT table_name FROM information_schema.tables WHERE table_schema = DATABASE()"
    );
    return result[0].map(row => row.table_name);
  }

  async seed(table, data) {
    if (Array.isArray(data)) {
      await this.db(table).insert(data);
    } else {
      const count = data.count || 10;
      const factory = data.factory;

      const records = [];
      for (let i = 0; i < count; i++) {
        records.push(factory(i));
      }

      await this.db(table).insert(records);
    }
  }
}
```

## Python Test Helpers

### Pytest Fixtures and Utilities

```python
# test_helpers.py
import pytest
import tempfile
import shutil
from contextlib import contextmanager
from unittest.mock import Mock, patch
import time
import asyncio
from pathlib import Path

# Temporary directory fixture
@pytest.fixture
def temp_dir():
    """Create a temporary directory for tests."""
    temp_path = tempfile.mkdtemp()
    yield Path(temp_path)
    shutil.rmtree(temp_path)

# Mock time fixture
@pytest.fixture
def mock_time():
    """Mock time for consistent testing."""
    with patch('time.time') as mock:
        current_time = 1234567890.0
        mock.return_value = current_time

        def advance(seconds):
            nonlocal current_time
            current_time += seconds
            mock.return_value = current_time

        mock.advance = advance
        yield mock

# Async test helpers
@pytest.fixture
def event_loop():
    """Create an instance of the default event loop for the test session."""
    loop = asyncio.new_event_loop()
    yield loop
    loop.close()

class AsyncTestHelper:
    @staticmethod
    async def wait_for(condition, timeout=5.0, interval=0.1):
        """Wait for a condition to become true."""
        start = time.time()
        while time.time() - start < timeout:
            if await condition():
                return True
            await asyncio.sleep(interval)
        raise TimeoutError(f"Condition not met within {timeout} seconds")

    @staticmethod
    async def assert_async_raises(exception_class, coro):
        """Assert that an async function raises an exception."""
        with pytest.raises(exception_class):
            await coro

# Data factories
class TestDataFactory:
    _counter = 0

    @classmethod
    def create_user(cls, **kwargs):
        cls._counter += 1
        defaults = {
            'id': cls._counter,
            'username': f'user{cls._counter}',
            'email': f'user{cls._counter}@example.com',
            'is_active': True,
        }
        return {**defaults, **kwargs}

    @classmethod
    def create_product(cls, **kwargs):
        cls._counter += 1
        defaults = {
            'id': cls._counter,
            'name': f'Product {cls._counter}',
            'price': 99.99,
            'stock': 100,
        }
        return {**defaults, **kwargs}

    @classmethod
    def reset(cls):
        cls._counter = 0

# Custom assertions
class CustomAssertions:
    @staticmethod
    def assert_dict_subset(subset, dictionary):
        """Assert that all items in subset exist in dictionary."""
        for key, value in subset.items():
            assert key in dictionary, f"Key '{key}' not found in dictionary"
            assert dictionary[key] == value, \
                f"Value mismatch for key '{key}': {dictionary[key]} != {value}"

    @staticmethod
    def assert_lists_equal_unordered(list1, list2):
        """Assert two lists contain the same elements, order-independent."""
        assert len(list1) == len(list2), \
            f"Lists have different lengths: {len(list1)} != {len(list2)}"
        assert set(list1) == set(list2), \
            f"Lists contain different elements"

# Context managers for testing
@contextmanager
def assert_logs(logger, level='INFO'):
    """Capture and assert on log messages."""
    import logging

    class LogCapture(logging.Handler):
        def __init__(self):
            super().__init__()
            self.records = []

        def emit(self, record):
            self.records.append(record)

    handler = LogCapture()
    handler.setLevel(getattr(logging, level))
    logger.addHandler(handler)

    try:
        yield handler.records
    finally:
        logger.removeHandler(handler)

@contextmanager
def override_env(**kwargs):
    """Temporarily override environment variables."""
    import os
    original = {}

    for key, value in kwargs.items():
        original[key] = os.environ.get(key)
        if value is None:
            os.environ.pop(key, None)
        else:
            os.environ[key] = str(value)

    try:
        yield
    finally:
        for key, value in original.items():
            if value is None:
                os.environ.pop(key, None)
            else:
                os.environ[key] = value

# Performance testing
class PerformanceTestHelper:
    @staticmethod
    @contextmanager
    def assert_performance(max_duration):
        """Assert that code block completes within max_duration seconds."""
        start = time.time()
        yield
        duration = time.time() - start
        assert duration <= max_duration, \
            f"Performance assertion failed: {duration:.3f}s > {max_duration}s"

    @staticmethod
    def benchmark(func, iterations=1000):
        """Benchmark a function over multiple iterations."""
        times = []
        for _ in range(iterations):
            start = time.perf_counter()
            func()
            times.append(time.perf_counter() - start)

        return {
            'min': min(times),
            'max': max(times),
            'mean': sum(times) / len(times),
            'median': sorted(times)[len(times) // 2],
        }
```

## Go Test Helpers

```go
// testhelpers/helpers.go
package testhelpers

import (
	"io/ioutil"
	"os"
	"path/filepath"
	"testing"
	"time"
)

// TempDir creates a temporary directory and returns a cleanup function
func TempDir(t *testing.T) (string, func()) {
	t.Helper()
	tempDir, err := ioutil.TempDir("", "test-*")
	if err != nil {
		t.Fatal(err)
	}

	return tempDir, func() {
		if err := os.RemoveAll(tempDir); err != nil {
			t.Errorf("Failed to remove temp dir: %v", err)
		}
	}
}

// WriteFile writes content to a file in the given directory
func WriteFile(t *testing.T, dir, filename, content string) string {
	t.Helper()
	fullPath := filepath.Join(dir, filename)
	if err := ioutil.WriteFile(fullPath, []byte(content), 0644); err != nil {
		t.Fatal(err)
	}
	return fullPath
}

// AssertEventually asserts that condition becomes true within timeout
func AssertEventually(t *testing.T, condition func() bool, timeout time.Duration, msg string) {
	t.Helper()
	deadline := time.Now().Add(timeout)
	interval := timeout / 100

	for time.Now().Before(deadline) {
		if condition() {
			return
		}
		time.Sleep(interval)
	}

	t.Errorf("Condition not met within %v: %s", timeout, msg)
}

// Golden compares actual output with golden file
func Golden(t *testing.T, actual []byte, goldenPath string, update bool) {
	t.Helper()

	if update {
		if err := ioutil.WriteFile(goldenPath, actual, 0644); err != nil {
			t.Fatal(err)
		}
		return
	}

	expected, err := ioutil.ReadFile(goldenPath)
	if err != nil {
		t.Fatal(err)
	}

	if string(expected) != string(actual) {
		t.Errorf("Output does not match golden file %s", goldenPath)
	}
}
```

## Best Practices

1. **Keep Helpers Simple**
   - Single responsibility per helper
   - Clear, descriptive names
   - Minimal dependencies

2. **Make Tests Readable**
   - Use descriptive assertions
   - Avoid complex setup
   - Clear test names

3. **Isolate Tests**
   - Clean up after each test
   - No shared state
   - Independent execution

4. **Performance**
   - Mock expensive operations
   - Use test doubles
   - Parallelize when possible

5. **Debugging**
   - Helpful error messages
   - Log test steps in verbose mode
   - Capture relevant state on failure

## External References

- [Jest Testing Best Practices](https://github.com/goldbergyoni/javascript-testing-best-practices)
- [Pytest Documentation](https://docs.pytest.org/)
- [Go Testing Package](https://pkg.go.dev/testing)
- [Bash Automated Testing System (BATS)](https://github.com/bats-core/bats-core)