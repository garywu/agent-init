#!/usr/bin/env bash
# Setup GitHub labels with platform-specific additions
# Extends the base label set with platform labels

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# First, run the base label setup
echo "Setting up base labels..."
"${SCRIPT_DIR}/../../scripts/setup-github-labels.sh"

# Colors for output
GREEN='\033[0;32m'
NC='\033[0m' # No Color

print_status() { echo -e "${GREEN}==>${NC} $1"; }

echo ""
print_status "Adding platform-specific labels..."

# Platform labels
declare -a PLATFORM_LABELS=(
  "platform-macos|macOS specific issues|000000"
  "platform-linux|Linux specific issues|FCC624"
  "platform-windows|Windows specific issues|0078D4"
  "platform-wsl|WSL specific issues|9B59B6"
  "platform-android|Android specific issues|3DDC84"
  "platform-ios|iOS specific issues|000000"
  "platform-web|Web platform specific|FF6900"
  "platform-docker|Docker specific issues|2496ED"
)

# Create platform labels
for label_data in "${PLATFORM_LABELS[@]}"; do
  IFS='|' read -r name description color <<<"$label_data"

  if gh label create "$name" --description "$description" --color "$color" --force 2>/dev/null; then
    print_status "Added platform label: $name"
  fi
done

print_status "Platform labels added successfully!"
