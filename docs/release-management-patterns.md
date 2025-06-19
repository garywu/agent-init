# Release Management Patterns

This guide documents sophisticated patterns for version management, changelog generation, and release automation based on real-world experience.

## Semantic Versioning with Conventional Commits

### Version Calculation from Commits

```bash
# Calculate next version based on conventional commits
calculate_next_version() {
    local current_version=$1
    local commit_range=${2:-"HEAD"}
    
    # Parse current version
    local major=$(echo "$current_version" | cut -d. -f1)
    local minor=$(echo "$current_version" | cut -d. -f2)
    local patch=$(echo "$current_version" | cut -d. -f3)
    
    # Check commit types
    local has_breaking=false
    local has_feat=false
    local has_fix=false
    
    # Analyze commits
    while IFS= read -r commit; do
        if [[ "$commit" =~ BREAKING[[:space:]]CHANGE ]] || [[ "$commit" =~ ^[a-z]+! ]]; then
            has_breaking=true
        elif [[ "$commit" =~ ^feat ]]; then
            has_feat=true
        elif [[ "$commit" =~ ^fix ]]; then
            has_fix=true
        fi
    done < <(git log --format=%s "$commit_range")
    
    # Calculate new version
    if [[ "$has_breaking" == true ]]; then
        echo "$((major + 1)).0.0"
    elif [[ "$has_feat" == true ]]; then
        echo "$major.$((minor + 1)).0"
    elif [[ "$has_fix" == true ]]; then
        echo "$major.$minor.$((patch + 1))"
    else
        echo "$current_version"
    fi
}
```

### Conventional Commit Validation

```bash
# Pre-commit hook for commit message validation
validate_commit_message() {
    local commit_regex='^(feat|fix|docs|style|refactor|test|chore|perf|ci|revert)(\(.+\))?: .{1,50}'
    local merge_regex='^Merge (branch|pull request)'
    
    if ! grep -qE "($commit_regex|$merge_regex)" "$1"; then
        echo "❌ Invalid commit message format!"
        echo ""
        echo "Valid format: <type>(<scope>): <subject>"
        echo ""
        echo "Types: feat, fix, docs, style, refactor, test, chore, perf, ci, revert"
        echo ""
        echo "Examples:"
        echo "  feat(auth): add OAuth2 support"
        echo "  fix: resolve memory leak in worker"
        echo "  docs(api): update authentication examples"
        return 1
    fi
}
```

## Changelog Generation

### Automated Changelog from Commits

```bash
# Generate changelog section for a version
generate_changelog_section() {
    local version=$1
    local from_tag=$2
    local to_tag=${3:-HEAD}
    local release_date=$(date +%Y-%m-%d)
    
    cat << EOF
## [$version] - $release_date

EOF
    
    # Group commits by type
    local sections=(
        "feat:### ✨ Features"
        "fix:### 🐛 Bug Fixes"
        "perf:### ⚡ Performance Improvements"
        "docs:### 📚 Documentation"
        "BREAKING:### 💥 Breaking Changes"
    )
    
    for section in "${sections[@]}"; do
        local type="${section%%:*}"
        local heading="${section#*:}"
        local commits=""
        
        if [[ "$type" == "BREAKING" ]]; then
            commits=$(git log --format="- %s" "$from_tag..$to_tag" | grep -E "(BREAKING CHANGE|^[a-z]+!:)")
        else
            commits=$(git log --format="- %s" "$from_tag..$to_tag" | grep "^$type:" | sed "s/^$type\(([^)]*)\)\?: //")
        fi
        
        if [[ -n "$commits" ]]; then
            echo "$heading"
            echo ""
            echo "$commits"
            echo ""
        fi
    done
    
    # Contributors section
    echo "### 👥 Contributors"
    echo ""
    git log --format="- @%an" "$from_tag..$to_tag" | sort -u
    echo ""
}
```

### Changelog File Management

```bash
# Update CHANGELOG.md with new release
update_changelog() {
    local version=$1
    local changelog_entry=$2
    local changelog_file="CHANGELOG.md"
    
    # Create backup
    cp "$changelog_file" "$changelog_file.bak"
    
    # Create temporary file with new entry
    {
        # Keep header
        sed -n '1,/^## \[Unreleased\]/p' "$changelog_file"
        
        # Add new version
        echo ""
        echo "$changelog_entry"
        
        # Keep rest of file
        sed -n '/^## \[Unreleased\]/,$ { /^## \[Unreleased\]/!p }' "$changelog_file"
    } > "$changelog_file.tmp"
    
    mv "$changelog_file.tmp" "$changelog_file"
    echo "✅ Updated $changelog_file"
}
```

## Release Workflow

### Interactive Release Process

```bash
# Main release script
release() {
    echo "🚀 Release Process"
    echo "=================="
    
    # Pre-flight checks
    if ! git diff --quiet; then
        echo "❌ Error: Working directory has uncommitted changes"
        return 1
    fi
    
    if ! git diff --cached --quiet; then
        echo "❌ Error: Index has uncommitted changes"
        return 1
    fi
    
    # Get current version
    local current_version=$(git describe --tags --abbrev=0 2>/dev/null || echo "0.0.0")
    current_version=${current_version#v}  # Remove 'v' prefix if present
    
    echo "📌 Current version: $current_version"
    
    # Calculate next version
    local next_version=$(calculate_next_version "$current_version")
    
    # Allow manual override
    echo ""
    read -p "Next version [$next_version]: " manual_version
    next_version=${manual_version:-$next_version}
    
    # Confirm release
    echo ""
    echo "📋 Release Summary:"
    echo "  From: v$current_version"
    echo "  To:   v$next_version"
    echo ""
    
    if ! confirm "Proceed with release?"; then
        echo "❌ Release cancelled"
        return 1
    fi
    
    # Generate changelog
    echo "📝 Generating changelog..."
    local changelog_entry=$(generate_changelog_section "$next_version" "v$current_version")
    
    # Update files
    update_version_files "$next_version"
    update_changelog "$next_version" "$changelog_entry"
    
    # Commit changes
    git add .
    git commit -m "chore(release): prepare v$next_version"
    
    # Create tag
    git tag -a "v$next_version" -m "Release v$next_version"
    
    echo "✅ Release v$next_version prepared!"
    echo ""
    echo "Next steps:"
    echo "  1. Review the changes: git show"
    echo "  2. Push to remote: git push origin main --tags"
    echo "  3. Create GitHub release: gh release create v$next_version"
}
```

### Version File Updates

```bash
# Update version in multiple files
update_version_files() {
    local new_version=$1
    
    # Common version file patterns
    local version_files=(
        "package.json:\"version\": \"$new_version\""
        "Cargo.toml:version = \"$new_version\""
        "pyproject.toml:version = \"$new_version\""
        "VERSION:$new_version"
        "version.txt:$new_version"
        ".version:$new_version"
    )
    
    for file_pattern in "${version_files[@]}"; do
        local file="${file_pattern%%:*}"
        local pattern="${file_pattern#*:}"
        
        if [[ -f "$file" ]]; then
            echo "📝 Updating $file..."
            
            case "$file" in
                *.json)
                    # Use jq for JSON files
                    jq ".version = \"$new_version\"" "$file" > "$file.tmp" && mv "$file.tmp" "$file"
                    ;;
                *.toml)
                    # Use sed for TOML files
                    sed -i.bak "s/version = \".*\"/version = \"$new_version\"/" "$file"
                    rm "$file.bak"
                    ;;
                *)
                    # Simple replacement for text files
                    echo "$new_version" > "$file"
                    ;;
            esac
        fi
    done
}
```

## Release Channels

### Multi-Channel Release Management

```bash
# Determine release channel from version
get_release_channel() {
    local version=$1
    
    if [[ "$version" =~ -alpha\. ]]; then
        echo "alpha"
    elif [[ "$version" =~ -beta\. ]]; then
        echo "beta"
    elif [[ "$version" =~ -rc\. ]]; then
        echo "release-candidate"
    else
        echo "stable"
    fi
}

# Channel-specific release process
release_to_channel() {
    local version=$1
    local channel=$(get_release_channel "$version")
    
    echo "📢 Releasing to $channel channel..."
    
    case "$channel" in
        alpha)
            # Alpha releases - automated daily
            git push origin main --tags
            ;;
        beta)
            # Beta releases - automated weekly
            git push origin main:beta --tags
            gh release create "v$version" --prerelease --title "Beta Release v$version"
            ;;
        release-candidate)
            # RC releases - manual approval required
            git push origin main:rc --tags
            gh release create "v$version" --prerelease --title "Release Candidate v$version"
            ;;
        stable)
            # Stable releases - full process
            git push origin main:stable --tags
            gh release create "v$version" --title "Release v$version" --notes-file RELEASE_NOTES.md
            ;;
    esac
}
```

## Pre-Release Management

### Pre-Release Versioning

```bash
# Generate pre-release version
generate_prerelease_version() {
    local base_version=$1
    local prerelease_type=$2  # alpha, beta, rc
    local build_number=${3:-$(git rev-list --count HEAD)}
    
    case "$prerelease_type" in
        alpha)
            echo "${base_version}-alpha.${build_number}"
            ;;
        beta)
            # Count beta releases for this version
            local beta_count=$(git tag -l "v${base_version}-beta.*" | wc -l)
            echo "${base_version}-beta.$((beta_count + 1))"
            ;;
        rc)
            # Count RC releases for this version
            local rc_count=$(git tag -l "v${base_version}-rc.*" | wc -l)
            echo "${base_version}-rc.$((rc_count + 1))"
            ;;
        *)
            echo "${base_version}-dev.${build_number}"
            ;;
    esac
}
```

## Release Automation

### GitHub Actions Release Workflow

```yaml
# .github/workflows/release.yml
name: Release

on:
  workflow_dispatch:
    inputs:
      release_type:
        description: 'Release type'
        required: true
        type: choice
        options:
          - patch
          - minor
          - major
          - prerelease

jobs:
  release:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0  # Need full history for changelog
          
      - name: Configure Git
        run: |
          git config user.name "Release Bot"
          git config user.email "bot@example.com"
          
      - name: Calculate Version
        id: version
        run: |
          current=$(git describe --tags --abbrev=0 || echo "v0.0.0")
          ./scripts/calculate-version.sh "$current" "${{ inputs.release_type }}"
          
      - name: Generate Changelog
        run: |
          ./scripts/generate-changelog.sh "${{ steps.version.outputs.next }}"
          
      - name: Create Release
        run: |
          ./scripts/create-release.sh "${{ steps.version.outputs.next }}"
          
      - name: Push Changes
        run: |
          git push origin main --tags
```

### Release Validation

```bash
# Pre-release validation checks
validate_release() {
    local version=$1
    local errors=()
    
    echo "🔍 Validating release v$version..."
    
    # Check tests pass
    if ! npm test &>/dev/null; then
        errors+=("Tests are failing")
    fi
    
    # Check build succeeds
    if ! npm run build &>/dev/null; then
        errors+=("Build is failing")
    fi
    
    # Check no WIP commits
    if git log --format=%s "v$(git describe --tags --abbrev=0)..HEAD" | grep -i "wip"; then
        errors+=("Found WIP commits")
    fi
    
    # Check changelog updated
    if ! grep -q "\[$version\]" CHANGELOG.md; then
        errors+=("CHANGELOG.md not updated for v$version")
    fi
    
    # Check version files updated
    if [[ -f package.json ]] && ! grep -q "\"version\": \"$version\"" package.json; then
        errors+=("package.json version not updated")
    fi
    
    # Report results
    if [[ ${#errors[@]} -gt 0 ]]; then
        echo "❌ Release validation failed:"
        printf '  - %s\n' "${errors[@]}"
        return 1
    else
        echo "✅ All validation checks passed!"
        return 0
    fi
}
```

## Release Notes Generation

### Automated Release Notes

```bash
# Generate comprehensive release notes
generate_release_notes() {
    local version=$1
    local previous_version=$2
    local output_file="RELEASE_NOTES.md"
    
    cat > "$output_file" << EOF
# Release Notes for v$version

## 🎉 Highlights

$(git log --format="- %s" "v$previous_version..HEAD" | grep -E "^feat" | head -5)

## 📊 Summary

- **Commits**: $(git rev-list --count "v$previous_version..HEAD")
- **Contributors**: $(git log --format="%an" "v$previous_version..HEAD" | sort -u | wc -l)
- **Files Changed**: $(git diff --name-only "v$previous_version..HEAD" | wc -l)

$(generate_changelog_section "$version" "v$previous_version")

## 📦 Installation

\`\`\`bash
# npm
npm install myproject@$version

# yarn
yarn add myproject@$version

# Direct download
curl -L https://github.com/org/project/releases/download/v$version/release.tar.gz
\`\`\`

## 🔗 Links

- [Full Changelog](https://github.com/org/project/compare/v$previous_version...v$version)
- [Documentation](https://docs.example.com/v$version)
- [Migration Guide](https://docs.example.com/v$version/migration)
EOF

    echo "✅ Generated release notes: $output_file"
}
```

## Post-Release Actions

### Automated Post-Release Tasks

```bash
# Execute post-release tasks
post_release_tasks() {
    local version=$1
    
    echo "🔄 Running post-release tasks for v$version..."
    
    # Update documentation
    if [[ -d docs ]]; then
        echo "📚 Updating documentation..."
        npm run docs:version "$version"
    fi
    
    # Notify channels
    notify_release "$version"
    
    # Update stable branch
    if [[ ! "$version" =~ -(alpha|beta|rc) ]]; then
        echo "🌿 Updating stable branch..."
        git checkout stable
        git merge "v$version"
        git push origin stable
        git checkout main
    fi
    
    # Prepare next development cycle
    echo "🔮 Preparing next development cycle..."
    local next_dev_version=$(calculate_next_version "$version")
    next_dev_version="${next_dev_version}-dev"
    update_version_files "$next_dev_version"
    git add .
    git commit -m "chore: prepare for next development cycle"
}
```

## Best Practices

1. **Always validate before release** - Run comprehensive checks
2. **Use semantic versioning** - Be consistent with version bumps
3. **Maintain changelog** - Keep it updated with each release
4. **Tag everything** - Tags are immutable references
5. **Automate where possible** - Reduce human error
6. **Document release process** - Make it repeatable
7. **Use release channels** - Separate stable from experimental
8. **Test the release process** - In a separate environment first
9. **Keep release notes comprehensive** - Include all important changes
10. **Plan for rollbacks** - Have a strategy to revert if needed