# Health Assessment Patterns

This guide documents patterns and best practices for implementing comprehensive project health assessments.

## Overview

The health assessment system provides multi-dimensional analysis of project quality, helping teams maintain high standards and identify improvement areas.

## Key Principles

1. **Multi-dimensional Analysis** - Evaluate across multiple quality aspects
2. **Weighted Scoring** - Different dimensions have different importance
3. **Actionable Feedback** - Provide specific improvement recommendations
4. **CI/CD Integration** - Automated quality gates in pipelines
5. **False Positive Avoidance** - Smart patterns that avoid noise

## Implementation Patterns

### 1. Dimension Selection

Choose dimensions that matter for your project type:

```bash
# Web Applications
- Code Quality (20%)
- Test Coverage (15%)
- Security (20%)
- Performance (15%)
- UI Consistency (10%)

# APIs
- Code Quality (25%)
- Test Coverage (20%)
- Security (25%)
- Performance (20%)
- Documentation (10%)

# Libraries
- Code Quality (20%)
- Test Coverage (25%)
- Documentation (25%)
- API Design (20%)
- Examples (10%)
```

### 2. Smart Security Scanning

Avoid false positives with targeted patterns:

```bash
# Bad: Too broad, catches "Dansk-Top", "hsk-vocabulary"
grep -r "sk-[a-zA-Z0-9]"

# Good: Specific API key patterns
grep -rE "(sk-proj-|sk-ant-|OPENAI_API_KEY|ANTHROPIC_API_KEY).*[a-zA-Z0-9]{20,}"
```

### 3. Test Coverage Calculation

Calculate meaningful ratios:

```bash
# Count test files
test_files=$(find . -name "*.test.ts" -o -name "*.spec.ts" | wc -l)

# Count source files (excluding tests)
src_files=$(find ./src -name "*.ts" | grep -v ".test\|.spec" | wc -l)

# Calculate ratio
coverage_ratio=$(( (test_files * 100) / src_files ))
```

### 4. Performance Checks

Focus on measurable impacts:

```bash
# Check bundle size
large_bundles=$(find .next -name "*.js" -size +500k | wc -l)

# Check for optimization flags
grep -q "swcMinify\|compress" next.config.ts

# Check image optimization
unoptimized_images=$(find public -name "*.png" -o -name "*.jpg" | wc -l)
```

### 5. Documentation Quality

Measure both quantity and coverage:

```bash
# Documentation files
doc_files=$(find docs -name "*.md" | wc -l)

# Inline comment density
comment_lines=$(grep -r "//\|/\*" src --include="*.ts" | wc -l)
code_lines=$(find src -name "*.ts" | xargs wc -l | tail -1 | awk '{print $1}')
comment_ratio=$(( (comment_lines * 100) / code_lines ))
```

## Scoring Patterns

### Grade Boundaries

```bash
if [[ $score -ge 90 ]]; then
    grade="EXCELLENT"
elif [[ $score -ge 70 ]]; then
    grade="GOOD"
elif [[ $score -ge 50 ]]; then
    grade="MODERATE"
else
    grade="CRITICAL"
fi
```

### Weighted Calculation

```bash
# Simple weighted average
total_score=$((
    SCORE_CODE_QUALITY * WEIGHT_CODE_QUALITY +
    SCORE_TEST_COVERAGE * WEIGHT_TEST_COVERAGE +
    SCORE_SECURITY * WEIGHT_SECURITY
))
total_weight=$((
    WEIGHT_CODE_QUALITY +
    WEIGHT_TEST_COVERAGE +
    WEIGHT_SECURITY
))
overall_score=$(( total_score / total_weight ))
```

## Output Patterns

### Human-Readable Format

```
════════════════════════════════════════
        PROJECT HEALTH REPORT
════════════════════════════════════════
Project: my-app
Overall Score: 85%

Breakdown:
─────────────────────────────────────
code_quality         75%  (weight: 20%)
test_coverage       100%  (weight: 15%)
security             90%  (weight: 20%)
```

### CI-Friendly JSON

```json
{
  "project": "my-app",
  "overall_score": 85,
  "passed": true,
  "dimensions": {
    "code_quality": 75,
    "test_coverage": 100,
    "security": 90
  }
}
```

## CI/CD Integration Patterns

### GitHub Actions

```yaml
- name: Health Check
  run: |
    make health-ci

- name: Upload Health Report
  if: always()
  uses: actions/upload-artifact@v3
  with:
    name: health-report
    path: HEALTH_REPORT.md
```

### Quality Gates

```bash
# Exit codes based on score
if [[ $overall_score -lt 50 ]]; then
    exit 2  # Critical - fail build
elif [[ $overall_score -lt 70 ]]; then
    exit 1  # Warning - optional fail
else
    exit 0  # Success
fi
```

## Customization Patterns

### Project-Specific Dimensions

```bash
# Add custom dimension for API projects
analyze_api_design() {
    local score=100

    # Check for OpenAPI spec
    if [[ ! -f "openapi.yaml" ]]; then
        score=$((score - 30))
    fi

    # Check for versioning
    if ! grep -q "version:" openapi.yaml; then
        score=$((score - 20))
    fi

    SCORE_API_DESIGN=$score
}
```

### Dynamic Weight Adjustment

```bash
# Adjust weights based on project maturity
if [[ -f "VERSION" ]] && grep -q "^0\." VERSION; then
    # Early stage - focus on features
    WEIGHT_TEST_COVERAGE=10
    WEIGHT_DOCUMENTATION=5
else
    # Mature - focus on quality
    WEIGHT_TEST_COVERAGE=25
    WEIGHT_DOCUMENTATION=15
fi
```

## Common Pitfalls and Solutions

### 1. Overly Strict Scoring

**Problem**: Teams get discouraged by low scores
**Solution**: Start with achievable thresholds, gradually increase

### 2. Gaming the Metrics

**Problem**: Adding meaningless tests to boost coverage
**Solution**: Combine quantitative and qualitative checks

### 3. Platform Differences

**Problem**: Scripts fail on different shells/OS
**Solution**: Use bash 3.2 compatible syntax, test cross-platform

### 4. Performance Impact

**Problem**: Health checks slow down CI
**Solution**: Cache results, run in parallel, sample large codebases

## Best Practices

1. **Start Simple** - Begin with 3-4 key dimensions
2. **Iterate Based on Feedback** - Adjust weights and thresholds
3. **Document Exceptions** - Some warnings may be acceptable
4. **Track Trends** - Monitor improvement over time
5. **Celebrate Improvements** - Recognize score increases
6. **Automate Fixes** - Provide scripts to address common issues
7. **Keep It Fast** - Health checks should complete in <30 seconds

## Future Enhancements

- **Historical Tracking** - Store scores over time
- **Comparative Analysis** - Compare with similar projects
- **Auto-fix Capabilities** - Automatically resolve simple issues
- **IDE Integration** - Real-time health feedback
- **Badge Generation** - README badges showing health score