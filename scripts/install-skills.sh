#!/bin/bash
# Install Axiom skills to Windsurf Next global skills directory
#
# Usage: ./scripts/install-skills.sh
#
# This copies all skills from the repo to ~/.codeium/windsurf-next/skills/

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"
SOURCE_DIR="$REPO_ROOT/skills"
TARGET_DIR="$HOME/.codeium/windsurf-next/skills"

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "Axiom Skills Installer for Windsurf Next"
echo "========================================="
echo ""

# Check source exists
if [[ ! -d "$SOURCE_DIR" ]]; then
    echo "Error: Source directory not found: $SOURCE_DIR"
    exit 1
fi

# Create target directory if needed
if [[ ! -d "$TARGET_DIR" ]]; then
    echo -e "${YELLOW}Creating Windsurf skills directory...${NC}"
    mkdir -p "$TARGET_DIR"
fi

# Count skills
skill_count=$(find "$SOURCE_DIR" -mindepth 1 -maxdepth 1 -type d | wc -l | tr -d ' ')

echo "Installing $skill_count skills to: $TARGET_DIR"
echo ""

# Copy each skill
installed=0
updated=0
for skill_dir in "$SOURCE_DIR"/*/; do
    skill_name=$(basename "$skill_dir")
    target_skill_dir="$TARGET_DIR/$skill_name"

    if [[ -d "$target_skill_dir" ]]; then
        # Update existing
        rm -rf "$target_skill_dir"
        cp -r "$skill_dir" "$target_skill_dir"
        ((updated++))
    else
        # Fresh install
        cp -r "$skill_dir" "$target_skill_dir"
        ((installed++))
    fi
done

echo -e "${GREEN}Done!${NC}"
echo ""
echo "  New:     $installed skills"
echo "  Updated: $updated skills"
echo ""
echo "Skills are now available in Windsurf Next."
echo "You may need to restart Windsurf for changes to take effect."
