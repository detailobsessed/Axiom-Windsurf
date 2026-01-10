#!/bin/sh
# Axiom Skills Installer for Windsurf Next
#
# Usage:
#   curl -LsSf https://raw.githubusercontent.com/detailobsessed/Axiom-Windsurf/main/install.sh | sh
#
# Or with a specific version:
#   curl -LsSf https://raw.githubusercontent.com/detailobsessed/Axiom-Windsurf/main/install.sh | sh -s -- --version v1.0.0

set -eu

# Configuration
REPO="detailobsessed/Axiom-Windsurf"
BRANCH="main"
SKILLS_DIR="${HOME}/.codeium/windsurf-next/skills"
WORKFLOWS_DIR="${HOME}/.codeium/windsurf-next/global_workflows"
TEMP_DIR=""
WORKFLOWS_NEW=0
WORKFLOWS_UPDATED=0

# Colors (only if terminal supports it)
if [ -t 1 ]; then
    GREEN='\033[0;32m'
    YELLOW='\033[1;33m'
    RED='\033[0;31m'
    BOLD='\033[1m'
    NC='\033[0m'
else
    GREEN=''
    YELLOW=''
    RED=''
    BOLD=''
    NC=''
fi

# Cleanup on exit
cleanup() {
    if [ -n "$TEMP_DIR" ] && [ -d "$TEMP_DIR" ]; then
        rm -rf "$TEMP_DIR"
    fi
}
trap cleanup EXIT

# Print functions
info() {
    printf "%b\n" "$1"
}

success() {
    printf "%b%b%b\n" "$GREEN" "$1" "$NC"
}

warn() {
    printf "%b%b%b\n" "$YELLOW" "$1" "$NC"
}

error() {
    printf "%b%b%b\n" "$RED" "$1" "$NC" >&2
}

# Parse arguments
VERSION=""
while [ $# -gt 0 ]; do
    case "$1" in
        --version)
            if [ $# -lt 2 ] || [ -z "${2:-}" ]; then
                error "Missing value for --version"
                exit 1
            fi
            case "$2" in
                -*) error "Invalid version: '$2' looks like a flag"; exit 1 ;;
            esac
            VERSION="$2"
            shift 2
            ;;
        --version=*)
            VERSION="${1#*=}"
            shift
            ;;
        --help)
            info "Axiom Skills Installer for Windsurf Next"
            info ""
            info "Usage:"
            info "  curl -LsSf https://raw.githubusercontent.com/$REPO/main/install.sh | sh"
            info ""
            info "Options:"
            info "  --version <tag>  Install a specific version (e.g., v1.0.0)"
            info "  --help           Show this help message"
            exit 0
            ;;
        *)
            error "Unknown option: $1"
            exit 1
            ;;
    esac
done

# Determine download URL
if [ -n "$VERSION" ]; then
    DOWNLOAD_URL="https://github.com/$REPO/archive/refs/tags/$VERSION.tar.gz"
    # GitHub strips 'v' prefix from archive folder names
    ARCHIVE_PREFIX="Axiom-Windsurf-${VERSION#v}"
else
    DOWNLOAD_URL="https://github.com/$REPO/archive/refs/heads/$BRANCH.tar.gz"
    ARCHIVE_PREFIX="Axiom-Windsurf-$BRANCH"
fi

# Header
info ""
info "${BOLD}Axiom Skills Installer for Windsurf Next${NC}"
info "========================================="
info ""

# Check for required tools
for cmd in curl tar; do
    if ! command -v "$cmd" >/dev/null 2>&1; then
        error "Error: '$cmd' is required but not installed."
        exit 1
    fi
done

# Create temp directory
TEMP_DIR=$(mktemp -d)
ARCHIVE_PATH="$TEMP_DIR/axiom.tar.gz"

# Download
if [ -n "$VERSION" ]; then
    info "Downloading Axiom Skills $VERSION..."
else
    info "Downloading Axiom Skills (latest)..."
fi

if ! curl -fsSL "$DOWNLOAD_URL" -o "$ARCHIVE_PATH" 2>/dev/null; then
    error "Error: Failed to download from $DOWNLOAD_URL"
    if [ -n "$VERSION" ]; then
        error "Make sure version '$VERSION' exists."
    fi
    exit 1
fi

# Extract
info "Extracting..."
if ! tar -xzf "$ARCHIVE_PATH" -C "$TEMP_DIR" 2>/dev/null; then
    error "Error: Failed to extract archive."
    exit 1
fi

EXTRACTED_DIR="$TEMP_DIR/$ARCHIVE_PREFIX"
if [ ! -d "$EXTRACTED_DIR" ]; then
    # Fallback: find the extracted folder (in case GitHub naming differs)
    EXTRACTED_DIR=$(find "$TEMP_DIR" -mindepth 1 -maxdepth 1 -type d -name 'Axiom-Windsurf-*' | head -n 1)
fi
SOURCE_SKILLS="$EXTRACTED_DIR/skills"
SOURCE_WORKFLOWS="$EXTRACTED_DIR/.windsurf/workflows"

if [ ! -d "$SOURCE_SKILLS" ]; then
    error "Error: Skills directory not found in archive."
    exit 1
fi

# Create target directory
if [ ! -d "$SKILLS_DIR" ]; then
    warn "Creating Windsurf skills directory..."
    mkdir -p "$SKILLS_DIR"
fi

# Count skills
skill_count=$(find "$SOURCE_SKILLS" -mindepth 1 -maxdepth 1 -type d | wc -l | tr -d ' ')

info "Skills:    $SKILLS_DIR"
info "Workflows: $WORKFLOWS_DIR"
info ""

# Install skills
installed=0
updated=0
for skill_dir in "$SOURCE_SKILLS"/*/; do
    [ -d "$skill_dir" ] || continue
    skill_name=$(basename "$skill_dir")
    target_skill_dir="$SKILLS_DIR/$skill_name"

    if [ -d "$target_skill_dir" ]; then
        # Atomic update: copy to temp, then move
        backup_dir="${target_skill_dir}.bak"
        mv "$target_skill_dir" "$backup_dir"
        if cp -r "$skill_dir" "$target_skill_dir"; then
            rm -rf "$backup_dir"
            updated=$((updated + 1))
        else
            # Restore on failure
            mv "$backup_dir" "$target_skill_dir"
            warn "Failed to update $skill_name"
        fi
    else
        cp -r "$skill_dir" "$target_skill_dir"
        installed=$((installed + 1))
    fi
done

# Copy workflows to global workflows directory
if [ -d "$SOURCE_WORKFLOWS" ]; then
    mkdir -p "$WORKFLOWS_DIR"
    for workflow in "$SOURCE_WORKFLOWS"/*.md; do
        [ -f "$workflow" ] || continue
        workflow_name=$(basename "$workflow")
        if [ -f "$WORKFLOWS_DIR/$workflow_name" ]; then
            if cp "$workflow" "$WORKFLOWS_DIR/"; then
                WORKFLOWS_UPDATED=$((WORKFLOWS_UPDATED + 1))
            else
                warn "Failed to update workflow $workflow_name"
            fi
        else
            if cp "$workflow" "$WORKFLOWS_DIR/"; then
                WORKFLOWS_NEW=$((WORKFLOWS_NEW + 1))
            else
                warn "Failed to install workflow $workflow_name"
            fi
        fi
    done
fi

# Validate installation
if [ $((installed + updated)) -eq 0 ]; then
    error "Error: No skills were installed."
    exit 1
fi

# Summary
info ""
success "Done!"
info ""
info "  Skills new:       $installed"
info "  Skills updated:   $updated"
info "  Workflows new:    $WORKFLOWS_NEW"
info "  Workflows updated: $WORKFLOWS_UPDATED"
info ""
info "Skills are now available in Windsurf Next."
info "You may need to restart Windsurf for changes to take effect."
info ""
