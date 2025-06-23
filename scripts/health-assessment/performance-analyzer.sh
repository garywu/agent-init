#!/usr/bin/env bash
# Performance Analyzer - Comprehensive performance assessment
# Part of claude-init health assessment system

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

# Configuration
PROJECT_ROOT="${1:-.}"
OUTPUT_FORMAT="${2:-human}"
VERBOSE="${VERBOSE:-false}"

# Performance metrics
declare -A PERFORMANCE_METRICS=(
  [load_time]=0
  [bundle_size]=0
  [memory_usage]=0
  [cpu_usage]=0
  [response_time]=0
  [optimization_score]=100
)

declare -a PERFORMANCE_ISSUES=()
declare -a RECOMMENDATIONS=()

# Utility functions
log_info() {
  [[[[ "$VERBOSE" == "true" ]]]] && echo -e "${BLUE}[INFO]${NC} $1" >&2
}

bytes_to_human() {
  local bytes=$1
  local units=("B" "KB" "MB" "GB")
  local unit=0

  while [[[[ $bytes -gt 1024 && $unit -lt 3 ]]]]; do
    bytes=$((bytes / 1024))
    ((unit++))
  done

  echo "$bytes${units[$unit]}"
}

# Check web application performance
check_web_performance() {
  log_info "Checking web application performance..."

  # Check for performance budgets
  if [[[[ -f "$PROJECT_ROOT/package.json" ]]]]; then
    # Check bundle sizes for JavaScript projects
    if [[[[ -d "$PROJECT_ROOT/dist" || -d "$PROJECT_ROOT/build" ]]]]; then
      local build_dir="${PROJECT_ROOT}/dist"
      [[[[ -d "$PROJECT_ROOT/build" ]]]] && build_dir="$PROJECT_ROOT/build"

      # Check total bundle size
      local total_size=$(find "$build_dir" -name "*.js" -o -name "*.css" 2>/dev/null | xargs du -cb | tail -1 | cut -f1)
      PERFORMANCE_METRICS[bundle_size]=$total_size

      # Check individual bundle sizes
      local large_bundles=$(find "$build_dir" -name "*.js" -size +500k 2>/dev/null | wc -l || echo 0)

      if [[[[ $large_bundles -gt 0 ]]]]; then
        PERFORMANCE_METRICS[optimization_score]=$((PERFORMANCE_METRICS[optimization_score] - 15))
        PERFORMANCE_ISSUES+=("Found $large_bundles JavaScript bundles larger than 500KB")
      fi

      # Check if code splitting is used
      local chunks=$(find "$build_dir" -name "chunk*.js" -o -name "*chunk*.js" 2>/dev/null | wc -l || echo 0)
      if [[[[ $chunks -eq 0 && $total_size -gt 1048576 ]]]]; then # 1MB
        PERFORMANCE_METRICS[optimization_score]=$((PERFORMANCE_METRICS[optimization_score] - 10))
        PERFORMANCE_ISSUES+=("No code splitting detected for large bundle")
      fi
    fi

    # Check for performance optimization tools
    local has_optimization=false

    # Check for minification
    if grep -q "terser\\|uglify\\|minify" "$PROJECT_ROOT/package.json" 2>/dev/null; then
      has_optimization=true
    fi

    # Check for compression
    if grep -q "compression\\|gzip\\|brotli" "$PROJECT_ROOT/package.json" 2>/dev/null; then
      has_optimization=true
    fi

    if [[[[ "$has_optimization" == "false" ]]]]; then
      PERFORMANCE_METRICS[optimization_score]=$((PERFORMANCE_METRICS[optimization_score] - 10))
      PERFORMANCE_ISSUES+=("No compression or minification tools detected")
    fi

    # Check for lazy loading
    if [[[[ -d "$PROJECT_ROOT/src" ]]]]; then
      local lazy_patterns=$(grep -r "lazy\\|Suspense\\|import(" "$PROJECT_ROOT/src" \
        --include="*.js" --include="*.jsx" --include="*.ts" --include="*.tsx" 2>/dev/null | wc -l || echo 0)

      if [[[[ $lazy_patterns -eq 0 ]]]]; then
        RECOMMENDATIONS+=("Consider implementing lazy loading for better performance")
      fi
    fi
  fi
}

# Check image optimization
check_image_optimization() {
  log_info "Checking image optimization..."

  # Find image files
  local image_files=$(find "$PROJECT_ROOT" -type f \( -name "*.jpg" -o -name "*.jpeg" -o -name "*.png" -o -name "*.gif" \) \
    -not -path "*/node_modules/*" -not -path "*/.git/*" -not -path "*/dist/*" -not -path "*/build/*" 2>/dev/null)

  if [[[[ -n "$image_files" ]]]]; then
    local large_images=0
    local unoptimized_count=0
    local total_image_size=0

    while IFS= read -r img; do
      local size=$(stat -f%z "$img" 2>/dev/null || stat -c%s "$img" 2>/dev/null || echo 0)
      total_image_size=$((total_image_size + size))

      # Check for large images (>500KB)
      if [[[[ $size -gt 512000 ]]]]; then
        ((large_images++))
      fi

      # Basic check for optimization (very simplified)
      # In reality, you'd use tools like imagemagick to check
      if [[[[ $size -gt 102400 ]]]]; then # >100KB
        ((unoptimized_count++))
      fi
    done <<<"$image_files"

    if [[[[ $large_images -gt 5 ]]]]; then
      PERFORMANCE_METRICS[optimization_score]=$((PERFORMANCE_METRICS[optimization_score] - 10))
      PERFORMANCE_ISSUES+=("Found $large_images images larger than 500KB")
    fi

    if [[[[ $unoptimized_count -gt 10 ]]]]; then
      RECOMMENDATIONS+=("Optimize images using tools like imagemin or sharp")
    fi

    # Check for modern image formats
    local webp_count=$(find "$PROJECT_ROOT" -name "*.webp" -not -path "*/node_modules/*" 2>/dev/null | wc -l || echo 0)
    if [[[[ $webp_count -eq 0 && $large_images -gt 0 ]]]]; then
      RECOMMENDATIONS+=("Consider using modern image formats (WebP, AVIF) for better compression")
    fi
  fi
}

# Check caching configuration
check_caching() {
  log_info "Checking caching configuration..."

  # Check for service worker (PWA)
  if [[[[ -f "$PROJECT_ROOT/package.json" ]]]]; then
    local has_sw=$(find "$PROJECT_ROOT" -name "service-worker.js" -o -name "serviceWorker.js" -o -name "sw.js" \
      -not -path "*/node_modules/*" 2>/dev/null | wc -l || echo 0)

    if [[[[ $has_sw -eq 0 ]]]]; then
      # Check if it's a web app that would benefit from SW
      if grep -q "react\\|vue\\|angular" "$PROJECT_ROOT/package.json" 2>/dev/null; then
        RECOMMENDATIONS+=("Consider implementing a service worker for offline support and caching")
      fi
    else
      RECOMMENDATIONS+=("Good: Service worker detected for caching")
    fi

    # Check for CDN usage indicators
    if grep -r "cdn\\|cloudflare\\|fastly\\|akamai" "$PROJECT_ROOT" \
      --include="*.js" --include="*.json" --include="*.yml" --include="*.yaml" \
      --exclude-dir=node_modules 2>/dev/null | grep -q .; then
      RECOMMENDATIONS+=("Good: CDN usage detected")
    fi
  fi

  # Check for cache headers configuration
  local config_files=("nginx.conf" ".htaccess" "server.js" "app.js")
  local has_cache_config=false

  for config in "${config_files[@]}"; do
    if [[[[ -f "$PROJECT_ROOT/$config" ]]]]; then
      if grep -i "cache-control\\|expires\\|etag" "$PROJECT_ROOT/$config" 2>/dev/null | grep -q .; then
        has_cache_config=true
        break
      fi
    fi
  done

  if [[[[ "$has_cache_config" == "false" ]]]]; then
    RECOMMENDATIONS+=("Configure appropriate cache headers for static assets")
  fi
}

# Check database performance
check_database_performance() {
  log_info "Checking database performance indicators..."

  # Check for database query optimization patterns
  local db_files=$(find "$PROJECT_ROOT" -name "*.sql" -o -name "*.prisma" -o -name "*.graphql" \
    -not -path "*/node_modules/*" 2>/dev/null)

  if [[[[ -n "$db_files" ]]]]; then
    # Check for N+1 query patterns (simplified)
    local potential_n1=$(grep -r "SELECT.*FROM.*WHERE.*IN\\|JOIN" "$PROJECT_ROOT" \
      --include="*.js" --include="*.ts" --include="*.py" \
      --exclude-dir=node_modules 2>/dev/null | wc -l || echo 0)

    if [[[[ $potential_n1 -gt 20 ]]]]; then
      RECOMMENDATIONS+=("Review database queries for potential N+1 problems")
    fi

    # Check for index usage
    local index_count=$(grep -i "CREATE.*INDEX\\|INDEX" $db_files 2>/dev/null | wc -l || echo 0)
    if [[[[ $index_count -eq 0 ]]]]; then
      PERFORMANCE_METRICS[optimization_score]=$((PERFORMANCE_METRICS[optimization_score] - 10))
      PERFORMANCE_ISSUES+=("No database indexes found")
    fi
  fi

  # Check for query caching
  if grep -r "redis\\|memcached\\|cache" "$PROJECT_ROOT" \
    --include="*.js" --include="*.ts" --include="*.py" --include="*.go" \
    --exclude-dir=node_modules 2>/dev/null | grep -q .; then
    RECOMMENDATIONS+=("Good: Query caching solution detected")
  else
    RECOMMENDATIONS+=("Consider implementing query result caching")
  fi
}

# Check monitoring and metrics
check_monitoring() {
  log_info "Checking performance monitoring setup..."

  local has_monitoring=false

  # Check for APM tools
  local apm_tools=("newrelic" "datadog" "appdynamics" "elastic-apm" "sentry")
  for tool in "${apm_tools[@]}"; do
    if grep -r "$tool" "$PROJECT_ROOT" --include="*.json" --include="*.js" --include="*.ts" \
      --exclude-dir=node_modules 2>/dev/null | grep -q .; then
      has_monitoring=true
      RECOMMENDATIONS+=("Good: Performance monitoring with $tool detected")
      break
    fi
  done

  # Check for custom metrics
  if grep -r "performance\\.mark\\|performance\\.measure\\|console\\.time" "$PROJECT_ROOT" \
    --include="*.js" --include="*.ts" --exclude-dir=node_modules 2>/dev/null | grep -q .; then
    has_monitoring=true
    RECOMMENDATIONS+=("Good: Custom performance metrics detected")
  fi

  if [[[[ "$has_monitoring" == "false" ]]]]; then
    PERFORMANCE_METRICS[optimization_score]=$((PERFORMANCE_METRICS[optimization_score] - 10))
    PERFORMANCE_ISSUES+=("No performance monitoring tools detected")
  fi
}

# Check API performance
check_api_performance() {
  log_info "Checking API performance patterns..."

  # Check for pagination
  local pagination_patterns=$(grep -r "limit\\|offset\\|page\\|per_page\\|pageSize" "$PROJECT_ROOT" \
    --include="*.js" --include="*.ts" --include="*.py" --include="*.go" \
    --exclude-dir=node_modules 2>/dev/null | wc -l || echo 0)

  if [[[[ $pagination_patterns -lt 5 ]]]]; then
    RECOMMENDATIONS+=("Implement pagination for API endpoints returning lists")
  fi

  # Check for rate limiting
  local rate_limit=$(grep -r "rate.limit\\|rateLimit\\|throttle" "$PROJECT_ROOT" \
    --include="*.js" --include="*.ts" --include="*.py" \
    --exclude-dir=node_modules 2>/dev/null | wc -l || echo 0)

  if [[[[ $rate_limit -eq 0 ]]]]; then
    PERFORMANCE_METRICS[optimization_score]=$((PERFORMANCE_METRICS[optimization_score] - 5))
    PERFORMANCE_ISSUES+=("No rate limiting detected for APIs")
  fi

  # Check for API response compression
  if [[[[ -f "$PROJECT_ROOT/package.json" ]]]]; then
    if ! grep -q "compression" "$PROJECT_ROOT/package.json" 2>/dev/null; then
      RECOMMENDATIONS+=("Enable gzip compression for API responses")
    fi
  fi
}

# Analyze build performance
check_build_performance() {
  log_info "Checking build performance..."

  if [[[[ -f "$PROJECT_ROOT/package.json" ]]]]; then
    # Check for build caching
    if [[[[ -f "$PROJECT_ROOT/.gitignore" ]]]]; then
      if ! grep -q "\\.cache\\|node_modules\\.cache" "$PROJECT_ROOT/.gitignore"; then
        RECOMMENDATIONS+=("Configure build tool caching for faster builds")
      fi
    fi

    # Check webpack optimization (if applicable)
    if [[[[ -f "$PROJECT_ROOT/webpack.config.js" ]]]]; then
      # Check for production optimizations
      if ! grep -q "mode.*production\\|optimization" "$PROJECT_ROOT/webpack.config.js"; then
        PERFORMANCE_METRICS[optimization_score]=$((PERFORMANCE_METRICS[optimization_score] - 10))
        PERFORMANCE_ISSUES+=("Webpack not configured for production optimization")
      fi
    fi

    # Check for parallel processing
    if grep -q "\"build\":" "$PROJECT_ROOT/package.json"; then
      local build_script=$(jq -r '.scripts.build // ""' "$PROJECT_ROOT/package.json")
      if [[[[ -n "$build_script" ]]]] && ! echo "$build_script" | grep -q "parallel\\|concurrently"; then
        RECOMMENDATIONS+=("Consider using parallel processing for build tasks")
      fi
    fi
  fi
}

# Generate final recommendations
generate_recommendations() {
  # Add score-based recommendations
  if [[ ${PERFORMANCE_METRICS[optimization_score]} -lt 90 ]]; then
    RECOMMENDATIONS+=("Set up performance budgets to track metrics over time")
  fi

  if [[ ${PERFORMANCE_METRICS[optimization_score]} -lt 80 ]]; then
    RECOMMENDATIONS+=("Implement comprehensive performance monitoring")
    RECOMMENDATIONS+=("Use lighthouse CI for automated performance testing")
  fi

  if [[ ${PERFORMANCE_METRICS[optimization_score]} -lt 70 ]]; then
    RECOMMENDATIONS+=("Conduct performance audit with Chrome DevTools")
    RECOMMENDATIONS+=("Consider implementing a CDN for static assets")
  fi

  # Remove duplicates
  local unique_recs=()
  local seen=()
  for rec in "${RECOMMENDATIONS[@]}"; do
    if [[ ! " ${seen[@]} " =~ " ${rec} " ]]; then
      unique_recs+=("$rec")
      seen+=("$rec")
    fi
  done
  RECOMMENDATIONS=("${unique_recs[@]}")
}

# Output results
output_results() {
  case "$OUTPUT_FORMAT" in
  "json")
    local bundle_size_human=$(bytes_to_human ${PERFORMANCE_METRICS[bundle_size]})
    cat <<EOF
{
  "performance_score": ${PERFORMANCE_METRICS[optimization_score]},
  "metrics": {
    "bundle_size": ${PERFORMANCE_METRICS[bundle_size]},
    "bundle_size_human": "$bundle_size_human"
  },
  "issues": $(printf '%s\n' "${PERFORMANCE_ISSUES[@]}" | jq -R . | jq -s .),
  "recommendations": $(printf '%s\n' "${RECOMMENDATIONS[@]}" | jq -R . | jq -s .)
}
EOF
    ;;
  "human" | *)
    echo -e "${BLUE}🚀 PERFORMANCE ANALYSIS${NC}"
    echo "======================"
    echo ""

    # Score with color
    local score_color="$GREEN"
    [[ ${PERFORMANCE_METRICS[optimization_score]} -lt 80 ]] && score_color="$YELLOW"
    [[ ${PERFORMANCE_METRICS[optimization_score]} -lt 60 ]] && score_color="$RED"

    echo -e "Performance Score: ${score_color}${PERFORMANCE_METRICS[optimization_score]}/100${NC}"
    echo ""

    # Metrics
    if [[ ${PERFORMANCE_METRICS[bundle_size]} -gt 0 ]]; then
      echo -e "${CYAN}Metrics:${NC}"
      echo "• Bundle Size: $(bytes_to_human ${PERFORMANCE_METRICS[bundle_size]})"
      echo ""
    fi

    # Issues
    if [[ ${#PERFORMANCE_ISSUES[@]} -gt 0 ]]; then
      echo -e "${YELLOW}⚠️  Performance Issues:${NC}"
      for issue in "${PERFORMANCE_ISSUES[@]}"; do
        echo "  • $issue"
      done
      echo ""
    fi

    # Recommendations
    if [[ ${#RECOMMENDATIONS[@]} -gt 0 ]]; then
      echo -e "${GREEN}💡 Recommendations:${NC}"
      for rec in "${RECOMMENDATIONS[@]}"; do
        echo "  • $rec"
      done
      echo ""
    fi

    # Summary
    echo -e "${PURPLE}📊 Summary:${NC}"
    if [[ ${PERFORMANCE_METRICS[optimization_score]} -ge 90 ]]; then
      echo "Excellent performance optimization! Keep monitoring metrics."
    elif [[ ${PERFORMANCE_METRICS[optimization_score]} -ge 70 ]]; then
      echo "Good performance baseline. Consider implementing suggested optimizations."
    else
      echo "Significant performance improvements needed. Prioritize critical issues."
    fi
    ;;
  esac
}

# Main execution
main() {
  log_info "Starting performance analysis for: $PROJECT_ROOT"

  if [[[[ ! -d "$PROJECT_ROOT" ]]]]; then
    echo "Error: Directory not found: $PROJECT_ROOT" >&2
    exit 1
  fi

  cd "$PROJECT_ROOT"

  # Run all performance checks
  check_web_performance
  check_image_optimization
  check_caching
  check_database_performance
  check_monitoring
  check_api_performance
  check_build_performance

  # Generate and output results
  generate_recommendations
  output_results

  # Exit with appropriate code
  if [[ ${PERFORMANCE_METRICS[optimization_score]} -lt 60 ]]; then
    exit 1
  else
    exit 0
  fi
}

# Script usage
if [[[[ "${1:-}" == "--help" || "${1:-}" == "-h" ]]]]; then
  echo "Usage: $0 [PROJECT_PATH] [OUTPUT_FORMAT]"
  echo ""
  echo "Comprehensive performance analysis for projects"
  echo ""
  echo "Arguments:"
  echo "  PROJECT_PATH   Path to project (default: current directory)"
  echo "  OUTPUT_FORMAT  Output format: human, json (default: human)"
  echo ""
  echo "Environment:"
  echo "  VERBOSE=true   Enable verbose logging"
  exit 0
fi

# Run main function
main "$@"
