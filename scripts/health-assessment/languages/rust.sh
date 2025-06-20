#!/usr/bin/env bash
# Rust Health Checker
# Part of claude-init health assessment system

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Configuration
PROJECT_ROOT="${1:-.}"
OUTPUT_FORMAT="${2:-human}"

# Health metrics
SCORE=100
ISSUES=()
RECOMMENDATIONS=()

# Check if this is a Rust project
check_rust_project() {
    if [[ ! -f "$PROJECT_ROOT/Cargo.toml" ]]; then
        echo "Not a Rust project"
        exit 1
    fi
}

# Cargo.toml validation
check_cargo_toml() {
    local cargo_file="$PROJECT_ROOT/Cargo.toml"
    
    # Check for basic metadata
    if ! grep -q "name =" "$cargo_file"; then
        SCORE=$((SCORE - 10))
        ISSUES+=("Missing 'name' in Cargo.toml")
    fi
    
    if ! grep -q "version =" "$cargo_file"; then
        SCORE=$((SCORE - 5))
        ISSUES+=("Missing 'version' in Cargo.toml")
    fi
    
    if ! grep -q "authors =" "$cargo_file" && ! grep -q "edition =" "$cargo_file"; then
        SCORE=$((SCORE - 3))
        ISSUES+=("Missing metadata in Cargo.toml")
    fi
    
    # Check for workspace
    if [[ -d "$PROJECT_ROOT/crates" ]] && ! grep -q "\[workspace\]" "$cargo_file"; then
        SCORE=$((SCORE - 5))
        ISSUES+=("Multi-crate project without workspace configuration")
    fi
    
    # Check edition
    local edition=$(grep "edition =" "$cargo_file" | sed 's/.*"\(.*\)".*/\1/' || echo "")
    if [[ -z "$edition" ]]; then
        SCORE=$((SCORE - 5))
        ISSUES+=("No Rust edition specified")
    elif [[ "$edition" < "2021" ]]; then
        SCORE=$((SCORE - 5))
        ISSUES+=("Using outdated Rust edition: $edition")
        RECOMMENDATIONS+=("Update to Rust 2021 edition or later")
    fi
}

# Dependencies check
check_dependencies() {
    # Check Cargo.lock
    if [[ ! -f "$PROJECT_ROOT/Cargo.lock" ]]; then
        if grep -q "\[lib\]" "$PROJECT_ROOT/Cargo.toml"; then
            # It's a library, Cargo.lock is optional
            RECOMMENDATIONS+=("Consider committing Cargo.lock for reproducible builds")
        else
            # It's a binary, Cargo.lock should be committed
            SCORE=$((SCORE - 10))
            ISSUES+=("Missing Cargo.lock for binary project")
        fi
    fi
    
    # Check for outdated dependencies
    if command -v cargo &>/dev/null; then
        # This would require cargo-outdated to be installed
        RECOMMENDATIONS+=("Run 'cargo update' to update dependencies")
        RECOMMENDATIONS+=("Use 'cargo outdated' to check for newer versions")
    fi
    
    # Check for security advisories
    RECOMMENDATIONS+=("Run 'cargo audit' to check for security vulnerabilities")
}

# Code organization check
check_code_organization() {
    # Check for standard Rust project structure
    local has_src=false
    local has_lib=false
    local has_main=false
    
    if [[ -d "$PROJECT_ROOT/src" ]]; then
        has_src=true
        [[ -f "$PROJECT_ROOT/src/lib.rs" ]] && has_lib=true
        [[ -f "$PROJECT_ROOT/src/main.rs" ]] && has_main=true
    else
        SCORE=$((SCORE - 20))
        ISSUES+=("Missing src directory")
    fi
    
    # Check for binary vs library confusion
    if [[ "$has_lib" == "true" && "$has_main" == "true" ]]; then
        RECOMMENDATIONS+=("Consider separating library and binary code")
    fi
    
    # Check for examples
    if [[ -d "$PROJECT_ROOT/examples" ]]; then
        RECOMMENDATIONS+=("Good: Examples directory present")
    elif [[ "$has_lib" == "true" ]]; then
        RECOMMENDATIONS+=("Consider adding examples directory for library usage")
    fi
    
    # Check for benches
    if [[ -d "$PROJECT_ROOT/benches" ]]; then
        RECOMMENDATIONS+=("Good: Benchmarks directory present")
    fi
}

# Testing check
check_testing() {
    # Check for tests directory
    local has_tests=false
    
    if [[ -d "$PROJECT_ROOT/tests" ]]; then
        has_tests=true
        local integration_tests=$(find "$PROJECT_ROOT/tests" -name "*.rs" 2>/dev/null | wc -l)
        if [[ $integration_tests -eq 0 ]]; then
            SCORE=$((SCORE - 10))
            ISSUES+=("Tests directory exists but contains no test files")
        fi
    fi
    
    # Check for unit tests in source files
    local unit_tests=$(grep -r "#\[test\]" "$PROJECT_ROOT/src" 2>/dev/null | wc -l || echo 0)
    local cfg_tests=$(grep -r "#\[cfg(test)\]" "$PROJECT_ROOT/src" 2>/dev/null | wc -l || echo 0)
    
    if [[ $unit_tests -eq 0 && ! "$has_tests" == "true" ]]; then
        SCORE=$((SCORE - 20))
        ISSUES+=("No tests found")
    elif [[ $unit_tests -lt 5 ]]; then
        SCORE=$((SCORE - 10))
        ISSUES+=("Very few unit tests found")
    fi
    
    # Check for doc tests
    local doc_tests=$(grep -r "///" "$PROJECT_ROOT/src" 2>/dev/null | grep -c "```" || echo 0)
    if [[ $doc_tests -eq 0 ]]; then
        RECOMMENDATIONS+=("Add doc tests in documentation comments")
    fi
}

# Code quality check
check_code_quality() {
    # Check for clippy configuration
    if [[ ! -f "$PROJECT_ROOT/clippy.toml" && ! -f "$PROJECT_ROOT/.clippy.toml" ]]; then
        RECOMMENDATIONS+=("Add clippy.toml for consistent linting")
    fi
    
    # Check for rustfmt configuration
    if [[ ! -f "$PROJECT_ROOT/rustfmt.toml" && ! -f "$PROJECT_ROOT/.rustfmt.toml" ]]; then
        SCORE=$((SCORE - 5))
        ISSUES+=("No rustfmt configuration")
    fi
    
    # Check for common anti-patterns (simplified)
    local unwraps=$(grep -r "\.unwrap()" "$PROJECT_ROOT/src" 2>/dev/null | grep -v test | wc -l || echo 0)
    if [[ $unwraps -gt 10 ]]; then
        SCORE=$((SCORE - 10))
        ISSUES+=("Excessive use of unwrap() ($unwraps occurrences)")
        RECOMMENDATIONS+=("Replace unwrap() with proper error handling")
    fi
    
    # Check for panic! usage
    local panics=$(grep -r "panic!" "$PROJECT_ROOT/src" 2>/dev/null | grep -v test | wc -l || echo 0)
    if [[ $panics -gt 5 ]]; then
        SCORE=$((SCORE - 5))
        ISSUES+=("Multiple panic! calls found ($panics occurrences)")
    fi
}

# Documentation check
check_documentation() {
    # Check for README
    if [[ ! -f "$PROJECT_ROOT/README.md" ]]; then
        SCORE=$((SCORE - 10))
        ISSUES+=("Missing README.md")
    fi
    
    # Check for documentation comments
    local pub_items=$(grep -r "^pub " "$PROJECT_ROOT/src" 2>/dev/null | wc -l || echo 0)
    local doc_comments=$(grep -r "^///" "$PROJECT_ROOT/src" 2>/dev/null | wc -l || echo 0)
    
    if [[ $pub_items -gt 0 && $doc_comments -eq 0 ]]; then
        SCORE=$((SCORE - 15))
        ISSUES+=("No documentation comments for public items")
    elif [[ $pub_items -gt 0 ]]; then
        local doc_ratio=$((doc_comments * 100 / pub_items))
        if [[ $doc_ratio -lt 50 ]]; then
            SCORE=$((SCORE - 10))
            ISSUES+=("Low documentation coverage (${doc_ratio}%)")
        fi
    fi
    
    # Check for CHANGELOG
    if [[ ! -f "$PROJECT_ROOT/CHANGELOG.md" ]]; then
        RECOMMENDATIONS+=("Add CHANGELOG.md to track version history")
    fi
}

# Build and CI check
check_build() {
    # Check if project builds
    if command -v cargo &>/dev/null; then
        if ! cargo check --manifest-path "$PROJECT_ROOT/Cargo.toml" 2>/dev/null; then
            SCORE=$((SCORE - 25))
            ISSUES+=("Project fails to compile")
        fi
    fi
    
    # Check for CI configuration
    local has_ci=false
    if [[ -f "$PROJECT_ROOT/.github/workflows/rust.yml" ]] || \
       [[ -f "$PROJECT_ROOT/.github/workflows/ci.yml" ]] || \
       [[ -f "$PROJECT_ROOT/.travis.yml" ]]; then
        has_ci=true
    fi
    
    if [[ "$has_ci" == "false" ]]; then
        SCORE=$((SCORE - 10))
        ISSUES+=("No CI configuration found")
    fi
}

# Security and safety check
check_security() {
    # Check for unsafe code
    local unsafe_blocks=$(grep -r "unsafe {" "$PROJECT_ROOT/src" 2>/dev/null | wc -l || echo 0)
    if [[ $unsafe_blocks -gt 0 ]]; then
        SCORE=$((SCORE - 5))
        ISSUES+=("$unsafe_blocks unsafe blocks found")
        RECOMMENDATIONS+=("Document safety invariants for unsafe code")
    fi
    
    # Check for forbid(unsafe_code)
    if [[ $unsafe_blocks -eq 0 ]] && ! grep -r "#!\[forbid(unsafe_code)\]" "$PROJECT_ROOT/src" 2>/dev/null; then
        RECOMMENDATIONS+=("Consider adding #![forbid(unsafe_code)] if not using unsafe")
    fi
    
    # Check for security-related crates
    if grep -q "openssl\|ring\|rustls" "$PROJECT_ROOT/Cargo.toml" 2>/dev/null; then
        RECOMMENDATIONS+=("Keep cryptographic dependencies up to date")
    fi
}

# Performance considerations
check_performance() {
    # Check for release profile optimization
    if ! grep -A5 "\[profile.release\]" "$PROJECT_ROOT/Cargo.toml" 2>/dev/null | grep -q "opt-level"; then
        RECOMMENDATIONS+=("Configure release profile optimizations in Cargo.toml")
    fi
    
    # Check for LTO
    if ! grep -A5 "\[profile.release\]" "$PROJECT_ROOT/Cargo.toml" 2>/dev/null | grep -q "lto"; then
        RECOMMENDATIONS+=("Consider enabling LTO for smaller binaries")
    fi
}

# Generate recommendations
generate_recommendations() {
    if [[ $SCORE -lt 90 ]]; then
        RECOMMENDATIONS+=("Run 'cargo fmt' to format code")
        RECOMMENDATIONS+=("Run 'cargo clippy' for additional linting")
    fi
    
    if [[ $SCORE -lt 80 ]]; then
        RECOMMENDATIONS+=("Add more tests (unit and integration)")
        RECOMMENDATIONS+=("Document all public APIs")
    fi
    
    if [[ $SCORE -lt 70 ]]; then
        RECOMMENDATIONS+=("Set up continuous integration")
        RECOMMENDATIONS+=("Address compilation errors")
    fi
    
    # Remove duplicates
    RECOMMENDATIONS=($(printf '%s\n' "${RECOMMENDATIONS[@]}" | sort -u))
}

# Output results
output_results() {
    case "$OUTPUT_FORMAT" in
        "json")
            cat <<EOF
{
  "language": "rust",
  "score": $SCORE,
  "issues": $(printf '%s\n' "${ISSUES[@]}" | jq -R . | jq -s .),
  "recommendations": $(printf '%s\n' "${RECOMMENDATIONS[@]}" | jq -R . | jq -s .)
}
EOF
            ;;
        "human"|*)
            echo -e "${BLUE}Rust Health Check${NC}"
            echo "================="
            echo ""
            echo -e "Score: $(if [[ $SCORE -ge 80 ]]; then echo -e "${GREEN}$SCORE/100${NC}"; elif [[ $SCORE -ge 60 ]]; then echo -e "${YELLOW}$SCORE/100${NC}"; else echo -e "${RED}$SCORE/100${NC}"; fi)"
            echo ""
            
            if [[ ${#ISSUES[@]} -gt 0 ]]; then
                echo -e "${YELLOW}Issues Found:${NC}"
                for issue in "${ISSUES[@]}"; do
                    echo "  • $issue"
                done
                echo ""
            fi
            
            if [[ ${#RECOMMENDATIONS[@]} -gt 0 ]]; then
                echo -e "${GREEN}Recommendations:${NC}"
                for rec in "${RECOMMENDATIONS[@]}"; do
                    echo "  • $rec"
                done
                echo ""
            fi
            ;;
    esac
}

# Main execution
main() {
    check_rust_project
    check_cargo_toml
    check_dependencies
    check_code_organization
    check_testing
    check_code_quality
    check_documentation
    check_build
    check_security
    check_performance
    generate_recommendations
    output_results
}

# Run main function
main "$@"