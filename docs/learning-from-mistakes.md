# Learning from Mistakes: A Meta-Guide

This guide documents the process of learning from debugging experiences and how to contribute that knowledge back to claude-init.

## The Learning Process

### 1. Encounter a Problem
Something doesn't work as expected. You spend hours debugging.

### 2. Find the Solution
After much trial and error, you discover the fix.

### 3. Document the Journey
This is the critical step most people skip. Document:
- What the symptoms were
- What you tried that didn't work
- What the actual problem was
- How you fixed it
- How to prevent it in the future

### 4. Contribute Back
Add your learnings to claude-init so others don't repeat your pain.

## Example: The Starlight Documentation Build Issue

### The Journey

1. **Initial Problem** (30 minutes wasted)
   - Docs site worked in dev, but production build only had 2 pages
   - No error messages, build reported success

2. **Failed Attempts** (2 hours wasted)
   - Tried manual sidebar configuration
   - Attempted CSS theme fixes
   - Rebuilt multiple times
   - Checked file permissions

3. **Discovery Process** (1 hour)
   - Compared dev vs build output
   - Found content pages existed in dev but not build
   - Discovered Astro content collections need explicit sync
   - Learned about package-lock.json cross-platform issues

4. **The Fix** (5 minutes)
   ```json
   "build": "astro sync && astro check && astro build"
   ```

5. **Knowledge Captured**
   - Created comprehensive debugging guide
   - Documented all failed attempts
   - Provided clear prevention steps
   - Added automated tests to catch this

**Total time: 3.5 hours. Time for next person: 5 minutes.**

**Key documentation that helped**: [Astro CLI Reference - astro sync](https://docs.astro.build/en/reference/cli-reference/#astro-sync)

## How to Document Debugging Sessions

### During Debugging

Keep a debugging log:

```bash
# debug.log
2024-01-15 10:00 - Docs build missing pages
2024-01-15 10:15 - Tried: manual sidebar config - FAILED
2024-01-15 10:30 - Tried: removing theme customization - FAILED
2024-01-15 11:00 - Found: astro sync requirement
2024-01-15 11:05 - FIXED: Added astro sync to build
```

### After Solving

Create a structured document:

```markdown
# Problem: [Clear problem title]

## Symptoms
- What the user sees
- Error messages (if any)
- When it happens

## Root Cause
- Technical explanation
- Why it happens

## Solution
- Exact steps to fix
- Code examples

## Prevention
- How to avoid this problem
- Best practices

## Failed Attempts
- What doesn't work (saves others time)
- Why these attempts seem logical but fail
```

## Patterns in Our Debugging

### Pattern 1: Platform Differences

**Problems Encountered**:
- Package-lock.json works on macOS, fails on Linux CI
- APFS volumes on macOS can't be removed in CI
- Systemd not available in containers

**Learning**: Always test on multiple platforms, document platform-specific behavior

### Pattern 2: Missing Build Steps

**Problems Encountered**:
- Astro content collections need sync
- TypeScript projects need type generation
- Some tools need explicit initialization

**Learning**: Document ALL required steps, even "obvious" ones

### Pattern 3: CI Environment Limitations

**Problems Encountered**:
- Can't remove system directories
- No interactive prompts
- Different permission models

**Learning**: Design for CI constraints from the start

## Creating Effective Documentation

### Bad Documentation
```markdown
Run `npm install` and `npm build` to build the docs.
```

### Good Documentation
```markdown
## Building Documentation

1. Install dependencies:
   ```bash
   npm install
   ```

2. Build the site:
   ```bash
   npm run build
   ```
   
   Note: This runs `astro sync` first, which is required for 
   content collections. Without it, your content pages won't 
   be included in the build.

3. Preview locally:
   ```bash
   npm run preview
   ```

Common issues:
- If pages are missing, ensure `astro sync` runs before build
- If build fails on CI, remove package-lock.json first
```

## The Meta-Learning Process

### Questions to Ask After Debugging

1. **Could better error messages have helped?**
   - Add validation and helpful errors
   - Create diagnostic commands

2. **Was this documented anywhere?**
   - If not, document it
   - If yes but hard to find, improve organization

3. **Will others hit this?**
   - If yes, add to common issues
   - Create automated checks

4. **What keywords would someone search for?**
   - Use these in your documentation
   - Create multiple paths to the solution

### Example Commit Message

```bash
git commit -m "docs: add debugging guide for missing Astro pages

- Document the astro sync requirement prominently
- Add troubleshooting section with symptoms
- Include all failed attempts to save others time
- Add automated test to catch this issue

This would have saved 3.5 hours of debugging (Issue #15)"
```

## Contributing Your Learnings

### Where to Add Documentation

1. **Specific problem guides**: `docs/[topic]-troubleshooting.md`
2. **General patterns**: `docs/debugging-and-troubleshooting.md`
3. **Best practices**: Update relevant guide with prevention tips
4. **Quick fixes**: Add to topic-specific guide

### Documentation Template

```markdown
## [Problem Name]

**Time to debug: X hours**
**Time to fix: Y minutes**

### Quick Fix
[One-line solution for those in a hurry]

### Detailed Explanation
[Full context for those who want to understand]

### How to Recognize This Problem
[Specific symptoms and error messages]

### Why This Happens
[Root cause explanation]

### Prevention
[How to avoid this problem entirely]

### Related Issues
[Links to similar problems]
```

## Making Debugging Easier for Others

### Add Diagnostic Commands

```bash
# Instead of leaving people to figure out what's wrong
npm run diagnose

# Which runs:
echo "Checking content files..."
find src/content -name "*.md*" | wc -l
echo "Checking sync status..."
test -d .astro && echo "✓ Synced" || echo "✗ Not synced"
```

### Create Verification Scripts

```bash
# verify-setup.sh
#!/bin/bash

echo "Verifying Astro setup..."

# Check critical things that often go wrong
checks=(
  "astro sync exists in build script"
  "content directory exists"
  "config.ts defines collections"
)

for check in "${checks[@]}"; do
  # Run actual verification
  echo "Checking: $check"
done
```

### Document the Investigation Process

Not just the solution, but HOW to investigate:

```markdown
## How to Debug Missing Pages

1. Check if pages exist in dev:
   ```bash
   npm run dev
   # Visit http://localhost:3000 and count pages
   ```

2. Check if pages are built:
   ```bash
   find dist -name "*.html" | wc -l
   ```

3. Check if content is synced:
   ```bash
   ls -la .astro/types.d.ts
   ```

4. Check build output:
   ```bash
   npm run build 2>&1 | grep -i "page"
   ```
```

## The Value of Failed Attempts

Document what DOESN'T work:

```markdown
## Failed Solutions

These seem logical but don't work:

### ❌ Manually listing pages
The sidebar config doesn't affect what gets built

### ❌ Clearing cache
`.astro` cache clearing doesn't help if sync wasn't run

### ❌ Changing theme
Theme has nothing to do with page generation
```

This saves others from trying the same dead ends.

## Conclusion

Every debugging session is a learning opportunity. The time you spend documenting your findings is multiplied by every person who doesn't have to repeat your debugging journey.

Remember: **Your 3 hours of debugging + 30 minutes of documentation = 5 minutes for the next person**.