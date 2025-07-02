# Claude Code Workflow Templates

Pre-configured workflow templates based on Anthropic's official best practices.

## Available Workflows

### 1. Explore-Plan-Code-Commit (EPCC)
Standard workflow for feature development and bug fixes.

**File:** `epcc-workflow.md`
**Use Case:** New features, bug fixes, refactoring

### 2. Test-Driven Development (TDD)
Write tests first, then implement code to pass them.

**File:** `tdd-workflow.md`
**Use Case:** Complex logic, API development, algorithms

### 3. Visual Iteration
Iterative UI development with screenshots and feedback.

**File:** `visual-iteration-workflow.md`
**Use Case:** UI/UX implementation, design matching

### 4. Parallel Development
Using multiple Claude instances for concurrent tasks.

**File:** `parallel-workflow.md`
**Use Case:** Large features, full-stack development

### 5. Code Review
Systematic code review and improvement process.

**File:** `code-review-workflow.md`
**Use Case:** PR reviews, code quality improvement

## Using Workflow Templates

1. **Copy to your project:**
   ```bash
   cp ~/.claude/workflows/epcc-workflow.md ./WORKFLOW.md
   ```

2. **Reference in CLAUDE.md:**
   ```markdown
   ## Development Workflow
   See WORKFLOW.md for our development process.
   ```

3. **Customize for your needs:**
   - Adjust steps based on project requirements
   - Add project-specific commands
   - Include team conventions

## Creating Custom Workflows

Use the `workflow-template.md` as a starting point for creating project-specific workflows.