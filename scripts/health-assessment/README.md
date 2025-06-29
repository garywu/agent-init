# Health Assessment System

A comprehensive project health evaluation tool that analyzes code quality, security, performance, and more.

## Overview

The health assessment system provides multi-dimensional analysis of your project's health across 8 key areas:

1. **Code Quality** - Linting, formatting, TypeScript configuration
2. **Test Coverage** - Test file ratio, test framework setup
3. **Security** - API key exposure, security headers, environment variables
4. **Performance** - Bundle optimization, image optimization, lazy loading
5. **Maintenance** - Documentation, file structure, dependency management
6. **Documentation** - README, inline comments, API docs
7. **Database** - Migrations, schema, seed data
8. **UI Consistency** - Component library, design tokens, styling approach

## Quick Start

```bash
# Run health assessment
make health

# Get JSON output
make health-json

# Save markdown report
make health-markdown

# CI integration (exits with error if unhealthy)
make health-ci
```

## Scoring System

Each dimension is scored 0-100 and weighted to produce an overall health score:

| Dimension | Weight | Focus Areas |
|-----------|--------|-------------|
| Code Quality | 20% | Linting, formatting, pre-commit hooks |
| Security | 20% | Exposed secrets, HTTPS, environment handling |
| Test Coverage | 15% | Test ratio, framework configuration |
| Performance | 15% | Bundle size, optimization, lazy loading |
| Maintenance | 10% | README, structure, dependencies |
| Documentation | 10% | Docs coverage, inline comments |
| Database | 5% | Migrations, schema, seeds |
| UI Consistency | 5% | Design system, component library |

## Health Grades

- **90-100%**: EXCELLENT - Maintain current standards
- **70-89%**: GOOD - Minor improvements recommended  
- **50-69%**: MODERATE - Several areas need attention
- **0-49%**: CRITICAL - Major improvements needed

## Customization

### Adding New Dimensions

1. Add score variable in `core-health.sh`
2. Create analysis function
3. Add to weight configuration
4. Include in overall calculation

### Language-Specific Analyzers

Create analyzers in `languages/` directory:

```bash
scripts/health-assessment/languages/
├── javascript-health.sh
├── python-health.sh
├── go-health.sh
└── rust-health.sh
```

### Project-Specific Adjustments

Modify weights and thresholds based on project priorities:

```bash
# For security-critical projects
WEIGHT_SECURITY=30
WEIGHT_CODE_QUALITY=25

# For MVP/prototypes
WEIGHT_PERFORMANCE=10
WEIGHT_TEST_COVERAGE=10
```

## CI/CD Integration

The health assessment integrates with CI pipelines:

```yaml
# GitHub Actions example
- name: Run health check
  run: make health-ci
  
# Fails the build if score < 70%
```

## Common Issues and Solutions

### False Positives in Security Scan

The security scanner uses smart patterns to avoid false positives:

- Won't flag "Dansk-Top" as "sk-" API key
- Won't flag "hsk-vocabulary" as exposed secret
- Focuses on actual API key patterns

### Bash Compatibility

The scripts are compatible with older bash versions (3.2+) for macOS compatibility.

## Future Enhancements

- [ ] Historical tracking and trends
- [ ] GitHub badge generation
- [ ] Slack/Discord notifications
- [ ] Custom rule definitions
- [ ] Auto-fix capabilities