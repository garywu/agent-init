#!/usr/bin/env bash
# JavaScript/TypeScript specific health checks

analyze_javascript_health() {
  local project_root=$1
  local score=100
  local issues=()
  
  # Check for package.json
  if [[ ! -f "$project_root/hub/package.json" ]]; then
    echo "0|CRITICAL|No package.json found"
    return
  fi
  
  # Check for lockfile
  if [[ ! -f "$project_root/hub/package-lock.json" ]] && \
     [[ ! -f "$project_root/hub/yarn.lock" ]] && \
     [[ ! -f "$project_root/hub/pnpm-lock.yaml" ]]; then
    issues+=("No lockfile found (package-lock.json, yarn.lock, or pnpm-lock.yaml)")
    score=$((score - 20))
  fi
  
  # Check for outdated dependencies
  if command -v npm >/dev/null 2>&1; then
    local outdated_count=$(cd "$project_root/hub" && npm outdated --json 2>/dev/null | jq 'length' 2>/dev/null || echo "0")
    if [[ $outdated_count -gt 10 ]]; then
      issues+=("$outdated_count outdated dependencies")
      score=$((score - 15))
    elif [[ $outdated_count -gt 5 ]]; then
      issues+=("$outdated_count outdated dependencies")
      score=$((score - 10))
    fi
  fi
  
  # Check for security vulnerabilities
  if command -v npm >/dev/null 2>&1; then
    local audit_result=$(cd "$project_root/hub" && npm audit --json 2>/dev/null || echo '{}')
    local high_vulns=$(echo "$audit_result" | jq '.metadata.vulnerabilities.high // 0' 2>/dev/null || echo "0")
    local critical_vulns=$(echo "$audit_result" | jq '.metadata.vulnerabilities.critical // 0' 2>/dev/null || echo "0")
    
    if [[ $critical_vulns -gt 0 ]]; then
      issues+=("$critical_vulns critical security vulnerabilities")
      score=$((score - 30))
    fi
    if [[ $high_vulns -gt 0 ]]; then
      issues+=("$high_vulns high security vulnerabilities")
      score=$((score - 20))
    fi
  fi
  
  # Check for TypeScript strict mode
  if [[ -f "$project_root/hub/tsconfig.json" ]]; then
    if ! grep -q '"strict": true' "$project_root/hub/tsconfig.json" 2>/dev/null; then
      issues+=("TypeScript strict mode not enabled")
      score=$((score - 10))
    fi
  fi
  
  # Check for unused dependencies
  if command -v depcheck >/dev/null 2>&1; then
    local unused_deps=$(cd "$project_root/hub" && depcheck --json 2>/dev/null | jq '.dependencies | length' 2>/dev/null || echo "0")
    if [[ $unused_deps -gt 5 ]]; then
      issues+=("$unused_deps potentially unused dependencies")
      score=$((score - 5))
    fi
  fi
  
  # Check for bundle size
  if [[ -d "$project_root/hub/.next" ]]; then
    local large_bundles=$(find "$project_root/hub/.next" -name "*.js" -size +500k 2>/dev/null | wc -l | tr -d ' ')
    if [[ $large_bundles -gt 5 ]]; then
      issues+=("$large_bundles large JavaScript bundles (>500KB)")
      score=$((score - 10))
    fi
  fi
  
  # Output results
  echo "$score"
  for issue in "${issues[@]}"; do
    echo "|WARNING|$issue"
  done
}

# Run if called directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  analyze_javascript_health "${1:-$(pwd)}"
fi