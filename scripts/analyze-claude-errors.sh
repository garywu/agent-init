#!/usr/bin/env bash
# Analyze Claude chat logs for error patterns and generate improvement recommendations

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Default values
CHAT_FILE="${1:-}"
OUTPUT_DIR="${2:-./claude-error-analysis}"
DB_FILE="${OUTPUT_DIR}/error-database.json"
REPORT_FILE="${OUTPUT_DIR}/error-report.md"

# Function to print colored output
print_status() { echo -e "${GREEN}==>${NC} $1"; }
print_error() { echo -e "${RED}Error:${NC} $1"; }
print_warning() { echo -e "${YELLOW}Warning:${NC} $1"; }
print_info() { echo -e "${BLUE}Info:${NC} $1"; }

# Usage function
usage() {
    cat << EOF
Usage: $0 <chat-file> [output-dir]

Analyzes Claude chat logs for error patterns and generates recommendations.

Arguments:
  chat-file    Path to the chat log file (text or JSON format)
  output-dir   Directory for analysis output (default: ./claude-error-analysis)

The script will:
1. Parse the chat log for error patterns
2. Categorize errors by type
3. Count occurrences
4. Generate recommendations for prevention
5. Create an error database for tracking

EOF
    exit 1
}

# Check arguments
if [[ -z "$CHAT_FILE" ]] || [[ ! -f "$CHAT_FILE" ]]; then
    print_error "Chat file not provided or doesn't exist"
    usage
fi

# Create output directory
mkdir -p "$OUTPUT_DIR"

print_status "Analyzing Claude chat log: $CHAT_FILE"

# Initialize error database
cat > "$DB_FILE" << 'EOF'
{
  "metadata": {
    "analyzed_at": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
    "chat_file": "$CHAT_FILE",
    "version": "1.0.0"
  },
  "error_categories": {
    "path_errors": {
      "description": "Errors related to file paths and directory navigation",
      "patterns": [
        "no such file or directory",
        "cannot access",
        "not found",
        "does not exist"
      ],
      "count": 0,
      "examples": []
    },
    "command_efficiency": {
      "description": "Inefficient command usage requiring multiple round trips",
      "patterns": [
        "multiple attempts for same operation",
        "redundant directory checks",
        "repeated pwd/ls commands"
      ],
      "count": 0,
      "examples": []
    },
    "assumption_errors": {
      "description": "Incorrect assumptions about file contents or state",
      "patterns": [
        "String to replace not found",
        "file exists but contents are empty",
        "assuming file structure"
      ],
      "count": 0,
      "examples": []
    },
    "git_errors": {
      "description": "Git operation errors and confusion",
      "patterns": [
        "modified:.*submodule",
        "pre-commit.*failed",
        "git.*error"
      ],
      "count": 0,
      "examples": []
    },
    "context_loss": {
      "description": "Losing track of context or previous instructions",
      "patterns": [
        "forgot previous instruction",
        "repeated same mistake",
        "ignored user correction"
      ],
      "count": 0,
      "examples": []
    },
    "tool_usage_errors": {
      "description": "Incorrect or suboptimal tool usage",
      "patterns": [
        "should have used",
        "wrong tool for",
        "inefficient approach"
      ],
      "count": 0,
      "examples": []
    }
  },
  "preventable_errors": [],
  "recommendations": []
}
EOF

# Create error analysis script in Python for better parsing
cat > "${OUTPUT_DIR}/analyze.py" << 'PYTHON_SCRIPT'
#!/usr/bin/env python3
import json
import re
import sys
from collections import defaultdict
from datetime import datetime

def analyze_chat_log(chat_file):
    """Analyze chat log for error patterns."""
    
    error_patterns = {
        "path_errors": {
            "patterns": [
                r"no such file or directory",
                r"cannot access.*No such file",
                r"not found",
                r"does not exist",
                r"cd.*no such file"
            ],
            "examples": []
        },
        "command_efficiency": {
            "patterns": [
                r"Let me check.*",
                r"Let me.*first.*",
                r"multiple round trips",
                r"pwd.*\n.*ls.*\n.*pwd"
            ],
            "examples": []
        },
        "assumption_errors": {
            "patterns": [
                r"String to replace not found",
                r"file exists but.*empty",
                r"assuming.*structure",
                r"Let me read.*to see"
            ],
            "examples": []
        },
        "git_errors": {
            "patterns": [
                r"modified:.*\(new commits\)",
                r"pre-commit.*[Ff]ailed",
                r"git.*error",
                r"rejected.*pre-receive hook"
            ],
            "examples": []
        },
        "working_directory_confusion": {
            "patterns": [
                r"Error:.*pwd.*shows.*directory",
                r"confused about.*directory",
                r"thought I was in",
                r"cd.*blocked"
            ],
            "examples": []
        },
        "retry_patterns": {
            "patterns": [
                r"Let me try again",
                r"retry",
                r"attempt.*again",
                r"same.*error"
            ],
            "examples": []
        }
    }
    
    # Read chat log
    with open(chat_file, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # Track errors found
    error_counts = defaultdict(int)
    total_errors = 0
    
    # Analyze each error category
    for category, data in error_patterns.items():
        for pattern in data["patterns"]:
            matches = re.finditer(pattern, content, re.IGNORECASE | re.MULTILINE)
            for match in matches:
                error_counts[category] += 1
                total_errors += 1
                
                # Extract context (50 chars before and after)
                start = max(0, match.start() - 100)
                end = min(len(content), match.end() + 100)
                context = content[start:end].strip()
                
                # Clean up context
                context = ' '.join(context.split())
                if len(context) > 200:
                    context = context[:200] + "..."
                
                data["examples"].append({
                    "match": match.group(),
                    "context": context
                })
    
    # Generate recommendations based on findings
    recommendations = generate_recommendations(error_counts, error_patterns)
    
    # Create report
    report = {
        "metadata": {
            "analyzed_at": datetime.utcnow().isoformat() + "Z",
            "chat_file": chat_file,
            "total_errors": total_errors
        },
        "error_counts": dict(error_counts),
        "error_details": error_patterns,
        "recommendations": recommendations,
        "preventable_errors": identify_preventable_errors(error_patterns)
    }
    
    return report

def generate_recommendations(error_counts, error_patterns):
    """Generate specific recommendations based on error patterns."""
    recommendations = []
    
    if error_counts.get("path_errors", 0) > 2:
        recommendations.append({
            "category": "path_errors",
            "severity": "high",
            "recommendation": "Always verify paths with 'ls' or 'test -f' before operations",
            "prevention": "Add path validation function to CLAUDE.md"
        })
    
    if error_counts.get("command_efficiency", 0) > 3:
        recommendations.append({
            "category": "command_efficiency",
            "severity": "medium",
            "recommendation": "Use compound commands with && to reduce round trips",
            "prevention": "Create command templates for common operations"
        })
    
    if error_counts.get("working_directory_confusion", 0) > 0:
        recommendations.append({
            "category": "working_directory_confusion",
            "severity": "high",
            "recommendation": "Track working directory in prompts, use absolute paths",
            "prevention": "Add PWD tracking to self-reflection protocol"
        })
    
    if error_counts.get("assumption_errors", 0) > 2:
        recommendations.append({
            "category": "assumption_errors",
            "severity": "high",
            "recommendation": "Always read files before editing, never assume contents",
            "prevention": "Add pre-edit verification checklist"
        })
    
    if error_counts.get("git_errors", 0) > 1:
        recommendations.append({
            "category": "git_errors",
            "severity": "medium",
            "recommendation": "Run 'make pre-commit-fix' before all commits",
            "prevention": "Add git workflow automation scripts"
        })
    
    return recommendations

def identify_preventable_errors(error_patterns):
    """Identify which errors could have been prevented."""
    preventable = []
    
    for category, data in error_patterns.items():
        if category in ["path_errors", "assumption_errors", "working_directory_confusion"]:
            for example in data.get("examples", [])[:3]:  # Top 3 examples
                preventable.append({
                    "category": category,
                    "error": example["match"],
                    "prevention": get_prevention_method(category)
                })
    
    return preventable

def get_prevention_method(category):
    """Get specific prevention method for error category."""
    prevention_methods = {
        "path_errors": "Verify with 'test -f' or 'ls' before use",
        "assumption_errors": "Read file contents before editing",
        "working_directory_confusion": "Use 'pwd' in compound commands",
        "command_efficiency": "Batch operations in single command",
        "git_errors": "Always run pre-commit fixes"
    }
    return prevention_methods.get(category, "Follow verification protocol")

def generate_markdown_report(report):
    """Generate markdown report from analysis."""
    md = f"""# Claude Error Analysis Report

Generated: {report['metadata']['analyzed_at']}
Total Errors Found: {report['metadata']['total_errors']}

## Error Summary

| Category | Count | Severity |
|----------|-------|----------|
"""
    
    # Sort by count
    sorted_errors = sorted(report['error_counts'].items(), key=lambda x: x[1], reverse=True)
    
    for category, count in sorted_errors:
        severity = "High" if count > 5 else "Medium" if count > 2 else "Low"
        md += f"| {category.replace('_', ' ').title()} | {count} | {severity} |\n"
    
    md += "\n## Top Recommendations\n\n"
    
    for i, rec in enumerate(report['recommendations'], 1):
        md += f"### {i}. {rec['category'].replace('_', ' ').title()}\n"
        md += f"**Severity**: {rec['severity'].upper()}\n\n"
        md += f"**Recommendation**: {rec['recommendation']}\n\n"
        md += f"**Prevention**: {rec['prevention']}\n\n"
    
    md += "## Preventable Errors\n\n"
    
    for error in report['preventable_errors'][:10]:  # Top 10
        md += f"- **{error['category']}**: `{error['error']}`\n"
        md += f"  - Prevention: {error['prevention']}\n\n"
    
    md += """## Implementation Checklist

Based on this analysis, add these to CLAUDE.md:

1. [ ] Path verification protocol
2. [ ] Command efficiency templates  
3. [ ] Working directory tracking
4. [ ] Pre-edit file verification
5. [ ] Git workflow automation

## Error Prevention Protocol

```bash
# Before file operations
test -f "$FILE" || { echo "File not found"; exit 1; }

# Before directory changes  
pwd && cd "$DIR" && pwd

# Before editing
cat "$FILE" | head -20  # Verify contents

# Before commits
make pre-commit-fix && git add -u && git commit
```
"""
    
    return md

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: analyze.py <chat-file>")
        sys.exit(1)
    
    chat_file = sys.argv[1]
    report = analyze_chat_log(chat_file)
    
    # Save JSON report
    with open("error-database.json", 'w') as f:
        json.dump(report, f, indent=2)
    
    # Generate markdown report
    md_report = generate_markdown_report(report)
    with open("error-report.md", 'w') as f:
        f.write(md_report)
    
    print(f"Analysis complete. Total errors found: {report['metadata']['total_errors']}")
    print(f"Report saved to: error-report.md")
    print(f"Database saved to: error-database.json")

PYTHON_SCRIPT

# Make Python script executable
chmod +x "${OUTPUT_DIR}/analyze.py"

# Run the analysis
print_status "Running error analysis..."
cd "$OUTPUT_DIR"
python3 analyze.py "../$CHAT_FILE"

# Display summary
print_status "Analysis complete!"
print_info "Reports generated:"
echo "  - Error database: $DB_FILE"
echo "  - Analysis report: $REPORT_FILE"

# Show top recommendations
echo ""
print_status "Top Recommendations:"
head -50 "$REPORT_FILE" | grep -A2 "^### [0-9]" || true

print_info "View full report: cat $REPORT_FILE"