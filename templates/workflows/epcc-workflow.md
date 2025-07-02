# Explore-Plan-Code-Commit (EPCC) Workflow

A systematic approach to feature development and bug fixes using Claude Code.

## Overview

The EPCC workflow ensures thorough understanding before implementation, reducing errors and rework.

## Workflow Steps

### 1. 🔍 Explore Phase

**Goal:** Understand the codebase and requirements

```
User: "I need to add user notifications to the app"

Claude Actions:
- Read relevant files (models, controllers, views)
- Understand current architecture
- Identify integration points
- Check for existing patterns
```

**Commands to use:**
```bash
# Have Claude explore the codebase
"Show me the current notification system if any exists"
"What files handle user interactions?"
"Find existing message/alert patterns"
```

### 2. 📋 Plan Phase

**Goal:** Create a detailed implementation plan

```
Claude: "Based on my exploration, here's my plan:

1. Create notification model/schema
   - user_id, type, message, read_status, timestamp
   
2. Add notification service
   - Send notifications
   - Mark as read
   - Get user notifications
   
3. Update UI components
   - Notification bell icon
   - Dropdown list
   - Unread count badge
   
4. Add API endpoints
   - GET /api/notifications
   - PUT /api/notifications/:id/read
   - POST /api/notifications
   
5. Implement real-time updates (optional)
   - WebSocket connection
   - Push notifications
"
```

**Review checklist:**
- [ ] Plan covers all requirements
- [ ] Follows existing patterns
- [ ] Considers edge cases
- [ ] Includes testing approach

### 3. 💻 Code Phase

**Goal:** Implement the plan incrementally

```
User: "Let's start with step 1 - create the notification model"

Claude: [Creates model with migrations]

User: "Good, now implement the notification service"

Claude: [Implements service layer]

User: "Let's see the UI components next"

Claude: [Creates React components]
```

**Best practices:**
- Implement one step at a time
- Test each component before moving on
- Ask for clarification if needed
- Follow project coding standards

### 4. ✅ Commit Phase

**Goal:** Document and commit changes properly

```
Claude Actions:
1. Review all changes: `git diff`
2. Run tests: `npm test`
3. Check linting: `npm run lint`
4. Create meaningful commit:
   ```bash
   git add -A
   git commit -m "feat: add user notification system

   - Add notification model and migrations
   - Implement notification service layer  
   - Create UI components for notifications
   - Add REST API endpoints
   - Include comprehensive tests"
   ```
```

**Commit checklist:**
- [ ] All tests pass
- [ ] Code is linted
- [ ] Changes are reviewed
- [ ] Commit message is descriptive
- [ ] Documentation is updated

## Example Session

```bash
# Start exploration
User: "I need to add a shopping cart feature to our e-commerce site"

# Claude explores
Claude: "I'll explore the current codebase structure..."
[Reads product models, user system, existing order logic]

# Claude plans
Claude: "Here's my implementation plan:
1. Create cart model (user_id, items array, total)
2. Add cart service (add/remove items, calculate total)
3. Build cart UI components
4. Create cart API endpoints
5. Add cart persistence"

# User approves
User: "Good plan, let's proceed step by step"

# Implementation
Claude: [Implements each step with user feedback]

# Commit
Claude: "All features implemented and tested. Ready to commit:
- Cart functionality complete
- All tests passing
- UI responsive and accessible"
```

## Tips for Success

1. **Be patient during exploration**
   - Let Claude understand the codebase
   - Provide additional context if needed

2. **Refine the plan together**
   - Discuss trade-offs
   - Consider alternatives
   - Adjust based on constraints

3. **Maintain momentum in coding**
   - Keep sessions focused
   - Complete logical units of work
   - Test incrementally

4. **Document thoroughly**
   - Update README if needed
   - Add inline comments for complex logic
   - Include examples in documentation

## When to Use This Workflow

✅ **Ideal for:**
- New feature development
- Bug fixes requiring investigation
- Refactoring existing code
- Adding integrations

❌ **Not ideal for:**
- Quick typo fixes
- Simple configuration changes
- Pure UI styling updates

## Customization

Adapt this workflow by:
- Adding review steps
- Including design phases
- Adding performance testing
- Incorporating team ceremonies