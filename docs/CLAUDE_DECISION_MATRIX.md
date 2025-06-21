# Claude AI Decision Matrix for EditorConfig

This document provides **instant decision patterns** for Claude CLI to eliminate pre-commit configuration errors.

## 🎯 Primary Objective
**Eliminate all EditorConfig conflicts** by giving Claude CLI clear, unambiguous rules for every project scenario.

## 📊 Decision Flow Chart

```
Project Analysis → Language Detection → Framework Detection → Configuration Selection
```

## 🔍 Project Type Detection Patterns

### Pattern 1: Web/Frontend Projects
**Indicators** (any present = web project):
- `package.json` with frontend frameworks: `react`, `vue`, `svelte`, `angular`, `next`, `nuxt`, `vite`
- `src/` directory with `.jsx`, `.tsx`, `.vue`, `.svelte` files
- `public/` or `static/` directories
- `webpack.config.js`, `vite.config.js`, `next.config.js`

**Claude Decision**: Apply `.editorconfig-web`
**Rationale**: Web ecosystem standard is 2-space indentation
**Shell scripts**: Minimal - use 2-space for consistency

### Pattern 2: Infrastructure/DevOps Projects  
**Indicators** (any present = infrastructure project):
- `Dockerfile`, `docker-compose.yml`, `Vagrantfile`
- `scripts/` directory with multiple `.sh` files
- `Makefile` with system commands
- `requirements.txt`, `pyproject.toml`, `Pipfile`
- `terraform/`, `ansible/`, `k8s/`, `.github/workflows/`
- Repository name contains: `admin`, `infra`, `ops`, `deploy`, `config`, `tools`

**Claude Decision**: Apply `.editorconfig-infrastructure`  
**Rationale**: Systems work needs clear visual hierarchy (4-space)
**Configuration files**: 2-space for readability

### Pattern 3: Backend API Projects
**Indicators** (any present = backend project):
- `package.json` with: `express`, `fastify`, `koa`, `nest`
- `go.mod` with web frameworks
- `requirements.txt` with: `django`, `flask`, `fastapi`
- `src/controllers/`, `src/routes/`, `src/models/` directories
- `prisma/`, `migrations/`, `seeders/` directories

**Claude Decision**: Apply `.editorconfig-backend`
**Rationale**: Server-side code benefits from 4-space indentation
**API schemas**: 2-space for JSON/YAML readability

### Pattern 4: Full-Stack Projects
**Indicators** (multiple patterns present):
- Web indicators + Backend indicators
- `frontend/` and `backend/` directories
- `package.json` with both frontend and backend dependencies
- Monorepo indicators: `lerna.json`, `nx.json`, `turbo.json`

**Claude Decision**: Apply `.editorconfig-fullstack`
**Rationale**: Language-specific rules for mixed codebase

### Pattern 5: Library/Package Projects
**Indicators**:
- `package.json` with `"main"`, `"module"`, `"exports"` fields
- `lib/`, `dist/`, `build/` directories
- `rollup.config.js`, `webpack.config.js` for bundling
- `index.d.ts`, `types/` directories
- Repository name ends with: `-lib`, `-sdk`, `-utils`, `-core`

**Claude Decision**: Apply `.editorconfig-library`
**Rationale**: Focus on consistency and contributor experience

## 🎯 Language-Specific Override Rules

### JavaScript/TypeScript Family
```yaml
patterns:
  - "*.{js,jsx,ts,tsx,mjs,cjs}"
  - "*.{vue,svelte}"
decision: 2-space indentation
rationale: "Ecosystem standard, Prettier default, npm ecosystem"
```

### Python Family  
```yaml
patterns:
  - "*.{py,pyi}"
  - "pyproject.toml"
decision: 4-space indentation
rationale: "PEP 8 standard, Black formatter default"
```

### Shell Script Family
```yaml
patterns:
  - "*.{sh,bash,zsh,fish}"
context_dependent: true
rules:
  - if: web_project
    decision: 2-space
    rationale: "Minimal shell usage, consistency with project"
  - if: infrastructure_project  
    decision: 4-space
    rationale: "Complex shell logic needs visual hierarchy"
  - if: fullstack_project
    decision: 4-space
    rationale: "Shell scripts typically for build/deploy"
```

### Configuration Files
```yaml
patterns:
  - "*.{json,jsonc,yaml,yml}"
decision: 2-space indentation
rationale: "Readability, standard across all ecosystems"
exceptions:
  - "docker-compose.yml": 2-space (Docker standard)
  - "pyproject.toml": 4-space (Python ecosystem)
```

## 🚨 Anti-Pattern Detection

### Red Flags (Never Do This)
```yaml
mixed_indentation_same_file:
  pattern: "Same file with both 2-space and 4-space"
  claude_action: "Flag as critical error, suggest fix"

global_2_space_with_infrastructure:
  pattern: "Global 2-space + heavy shell scripting"
  claude_action: "Suggest infrastructure template"

no_editorconfig_with_team:
  pattern: "Multi-contributor project without .editorconfig"
  claude_action: "Automatically add appropriate template"
```

## 📋 Quick Decision Commands for Claude

### Instant Project Analysis
```bash
# Claude should run these commands for instant context:
find . -name "package.json" -exec grep -l "react\|vue\|angular" {} \; | head -1
find . -name "*.sh" | wc -l
find . -name "Dockerfile" -o -name "docker-compose.yml" | head -1
find . -name "go.mod" -o -name "requirements.txt" | head -1
```

### Configuration Decision Tree
```yaml
decision_tree:
  step_1:
    check: "package.json with frontend frameworks"
    if_true: "web_project"
    if_false: "step_2"
  
  step_2:
    check: "shell_scripts > 3 OR Dockerfile OR infrastructure_keywords"
    if_true: "infrastructure_project"
    if_false: "step_3"
    
  step_3:
    check: "backend_indicators AND frontend_indicators"
    if_true: "fullstack_project"
    if_false: "step_4"
    
  step_4:
    check: "library_indicators"
    if_true: "library_project"
    if_false: "fullstack_project"  # Safe default
```

## 🎛️ Configuration Templates Quick Reference

| Project Type | Template File | Shell Scripts | Primary Languages | Use Case |
|--------------|---------------|---------------|-------------------|----------|
| Web | `.editorconfig-web` | 2-space | JS/TS/CSS | React, Vue, Angular |
| Infrastructure | `.editorconfig-infrastructure` | 4-space | Shell/Python | DevOps, Admin tools |
| Backend | `.editorconfig-backend` | 4-space | Python/Go/Node | APIs, Services |
| Full-Stack | `.editorconfig-fullstack` | 4-space | Mixed | Monorepos |
| Library | `.editorconfig-library` | 2-space | Language-specific | NPM packages |

## 🤖 Claude CLI Integration Patterns

### Auto-Detection Command
```bash
# Claude should use this exact command sequence:
PROJECT_TYPE=$(detect_project_type .)
echo "Detected: $PROJECT_TYPE"
cp .editorconfig-$PROJECT_TYPE .editorconfig
echo "Applied: .editorconfig-$PROJECT_TYPE"
```

### Validation Commands
```bash
# Claude should verify no conflicts:
editorconfig-checker .
pre-commit run --all-files editorconfig-checker
```

### Common Error Prevention
```yaml
before_any_file_edit:
  1. "Check if .editorconfig exists"
  2. "If not, auto-apply based on project type"
  3. "Verify indentation before editing files"
  4. "Use detected indentation in all edits"

before_commit:
  1. "Run editorconfig-checker"
  2. "Fix any violations automatically"
  3. "Verify pre-commit hooks pass"
```

## 📚 Error Pattern Recognition

### Common Pre-commit Failures
```yaml
"Wrong amount of left-padding spaces":
  cause: "File indentation doesn't match .editorconfig"
  claude_fix: "Auto-fix indentation using detected project type"
  
"Line too long":
  cause: "Line exceeds max_line_length setting"
  claude_fix: "Break long lines appropriately for language"
  
"Wrong indent style found (tabs instead of spaces)":
  cause: "Mixed tabs/spaces"
  claude_fix: "Convert to project-appropriate space indentation"
```

## 🔄 Project Evolution Handling

### When Projects Change Type
```yaml
web_to_fullstack:
  trigger: "Backend code added to web project"
  action: "Upgrade to .editorconfig-fullstack"
  
simple_to_infrastructure:
  trigger: "Multiple shell scripts added"
  action: "Upgrade to .editorconfig-infrastructure"
  
any_to_monorepo:
  trigger: "Multiple package.json or workspace structure"
  action: "Apply .editorconfig-fullstack with workspace-aware rules"
```

## 🎯 Success Metrics

Claude CLI should achieve:
- **Zero pre-commit EditorConfig failures**
- **Instant project type detection** (< 1 second)
- **Automatic configuration** without user input
- **Conflict prevention** through pattern recognition

## 📖 Quick Reference for Claude

### Before ANY file operation:
1. Detect project type using patterns above
2. Ensure appropriate .editorconfig exists
3. Use correct indentation for all edits
4. Validate before commit

### Emergency Override:
If uncertain: **Always use fullstack template** - it handles all cases safely.