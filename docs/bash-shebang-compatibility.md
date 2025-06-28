# Bash Shebang Compatibility Guide

## The Problem

Many developers write shell scripts with `#!/bin/bash`, which works fine on Linux but causes issues on macOS:

- **macOS ships with bash 3.2.57** (from 2007) at `/bin/bash` due to GPL licensing
- **Modern bash 5.2+** is typically installed via package managers (Homebrew, Nix, MacPorts)
- Bash 3.2 lacks many modern features like:
  - Associative arrays (`declare -A`)
  - `mapfile`/`readarray`
  - Advanced parameter expansion
  - Many bug fixes and performance improvements

## The Solution

**Always use `#!/usr/bin/env bash`** instead of `#!/bin/bash`:

```bash
#!/usr/bin/env bash
# ✅ CORRECT - finds bash in PATH (modern version)

#!/bin/bash
# ❌ WRONG - hardcoded to ancient macOS bash 3.2
```

## Why This Matters

1. **Feature availability**: Scripts using bash 4+ features will fail on macOS with `/bin/bash`
2. **Consistency**: Same script behavior across Linux and macOS
3. **Future-proofing**: Works with any bash location (Homebrew, Nix, MacPorts, etc.)

## Common Error Messages

If you see these errors, you're likely using old bash:

```
declare: -A: invalid option
declare: usage: declare [-afFirtx] [-p] [name[=value] ...]
```

## Implementing Enforcement

### 1. Pre-commit Hook

Create `.pre-commit-config.yaml`:

```yaml
repos:
  - repo: local
    hooks:
      - id: check-bash-shebang
        name: Check bash shebang
        entry: ./scripts/check-bash-shebang.sh
        language: system
        pass_filenames: false
        stages: [commit]
```

### 2. Shebang Checker Script

Save as `scripts/check-bash-shebang.sh`:

```bash
#!/usr/bin/env bash

set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m'

issues_found=0

while IFS= read -r -d '' file; do
    if [[ ! -f "$file" ]]; then
        continue
    fi
    
    if [[ "$file" == *.sh ]] || head -1 "$file" 2>/dev/null | grep -q "^#!.*sh"; then
        shebang=$(head -1 "$file" 2>/dev/null || echo "")
        
        if [[ "$shebang" == "#!/bin/bash" ]] || [[ "$shebang" == "#!/usr/bin/bash" ]]; then
            echo -e "${RED}ERROR:${NC} Hardcoded bash path in $file"
            echo -e "  Found: ${YELLOW}$shebang${NC}"
            echo -e "  Use:   ${GREEN}#!/usr/bin/env bash${NC}"
            ((issues_found++))
        fi
    fi
done < <(git diff --cached --name-only -z)

if [[ $issues_found -gt 0 ]]; then
    echo -e "\n${RED}Found $issues_found file(s) with hardcoded bash paths${NC}"
    echo "Fix with: sed -i '' '1s|^#!/bin/bash$|#!/usr/bin/env bash|' <file>"
    exit 1
fi

exit 0
```

### 3. Bulk Fix Script

For fixing existing scripts:

```bash
#!/usr/bin/env bash
# fix-shebangs.sh - Fix all bash shebangs in the project

find . -type f -name "*.sh" -exec grep -l "^#!/bin/bash" {} \; | while read -r file; do
    echo "Fixing: $file"
    if [[ "$(uname)" == "Darwin" ]]; then
        sed -i '' '1s|^#!/bin/bash$|#!/usr/bin/env bash|' "$file"
    else
        sed -i '1s|^#!/bin/bash$|#!/usr/bin/env bash|' "$file"
    fi
done
```

## Testing Your Setup

Check which bash you're using:

```bash
# Check bash in PATH
which bash
bash --version

# Check system bash
/bin/bash --version

# On macOS, you'll see:
# GNU bash, version 3.2.57(1)-release (arm64-apple-darwin)
```

## Integration with CI/CD

Add to your GitHub Actions:

```yaml
- name: Check bash shebangs
  run: |
    files=$(find . -name "*.sh" -exec grep -l "^#!/bin/bash" {} \; || true)
    if [[ -n "$files" ]]; then
      echo "Error: Found scripts with hardcoded bash paths:"
      echo "$files"
      echo "Use #!/usr/bin/env bash instead"
      exit 1
    fi
```

## Additional Resources

- [Bash Changelog](https://tiswww.case.edu/php/chet/bash/CHANGES)
- [macOS Bash Version History](https://apple.stackexchange.com/questions/193411/why-is-bash-3-2-still-the-default-shell-on-macos)
- [Shellcheck](https://www.shellcheck.net/) - Catches many bash compatibility issues