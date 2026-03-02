#!/bin/bash

#===============================================================================
# Python Backend Project Packaging Script
# 
# Generates a tgz package excluding:
# - Git-related files and directories
# - Temporary files
# - Build intermediate/output files
# - agents.md files
# - *.bak files
#
# Usage:
#   ./package.sh <input_folder> <version>
#   ./package.sh /path/to/project 1.0.0
#===============================================================================

set -e

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Parse positional arguments
INPUT_FOLDER="${1:-}"
VERSION="${2:-}"

# Validate input parameters
if [ -z "$INPUT_FOLDER" ]; then
    echo "Error: Input folder is required"
    echo "Usage: $0 <input_folder> <version>"
    echo "Example: $0 /path/to/project 1.0.0"
    exit 1
fi

if [ -z "$VERSION" ]; then
    echo "Error: Version number is required"
    echo "Usage: $0 <input_folder> <version>"
    echo "Example: $0 /path/to/project 1.0.0"
    exit 1
fi

# Resolve to absolute path
if [[ "$INPUT_FOLDER" = /* ]]; then
    PROJECT_ROOT="$INPUT_FOLDER"
else
    PROJECT_ROOT="$(cd "$INPUT_FOLDER" 2>/dev/null && pwd)"
fi

# Validate project root exists
if [ ! -d "$PROJECT_ROOT" ]; then
    echo "Error: Input folder does not exist: $INPUT_FOLDER"
    exit 1
fi

PACKAGE_NAME="backend-${VERSION}.tgz"
OUTPUT_DIR="${PROJECT_ROOT}/dist"
OUTPUT_FILE="${OUTPUT_DIR}/${PACKAGE_NAME}"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

#-------------------------------------------------------------------------------
# Helper Functions
#-------------------------------------------------------------------------------

log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

#-------------------------------------------------------------------------------
# Create exclude patterns file
#-------------------------------------------------------------------------------

create_exclude_file() {
    local exclude_file=$(mktemp)
    
    cat > "$exclude_file" << 'EOF'
# Git-related files and directories
.git/
.gitignore
.gitattributes
.gitmodules
.github/
.gitlab-ci.yml

# Temporary files
*.tmp
*.temp
*.swp
*.swo
*~
.DS_Store
Thumbs.db

# Python build artifacts
__pycache__/
*.py[cod]
*$py.class
*.pyo
*.pyd
.Python
build/
develop-eggs/
dist/
downloads/
eggs/
.eggs/
lib/
lib64/
parts/
sdist/
var/
wheels/
*.egg-info/
.installed.cfg
*.egg

# Virtual environments
venv/
ENV/
env/
.venv/

# IDE and editor files
.idea/
.vscode/
*.iml
.project
.pydevproject
.settings/

# Testing
.pytest_cache/
.coverage
htmlcov/
.tox/
.nox/
coverage.xml
*.cover
*.py,cover
.hypothesis/

# Documentation and metadata
agents.md
AGENTS.md
*.bak
*.backup

# AI assistant directories
.qoder/

# Scripts directory
scripts/

# Existing packages (avoid including previous builds)
*.tgz
*.tar.gz
*.zip
dist/

# Environment and secrets
.env
.env.*
!.env.example
*.pem
*.key
*.crt
secrets/

# Logs
*.log
logs/

# Database
*.db
*.sqlite
*.sqlite3

# Bruno collection (if not needed in package)
bruno-collection/
bruno-collection.zip

# Documentation (optional - uncomment if not needed)
# doc/
# API.md
# README.md

# Docker (optional - uncomment if not needed)
# docker/
EOF

    echo "$exclude_file"
}

#-------------------------------------------------------------------------------
# Main packaging function
#-------------------------------------------------------------------------------

package_project() {
    log_info "Starting packaging process..."
    log_info "Project root: ${PROJECT_ROOT}"
    
    # Create output directory
    mkdir -p "$OUTPUT_DIR"
    
    # Change to project root for relative paths in archive
    cd "$PROJECT_ROOT"
    
    # Create the tarball with comprehensive exclude options
    log_info "Creating package: ${OUTPUT_FILE}"
    
    tar --exclude='.git' \
        --exclude='.gitignore' \
        --exclude='.gitattributes' \
        --exclude='.gitmodules' \
        --exclude='.github' \
        --exclude='.gitlab-ci.yml' \
        --exclude='.qoder' \
        --exclude='scripts' \
        --exclude='__pycache__' \
        --exclude='*.pyc' \
        --exclude='*.pyo' \
        --exclude='*.pyd' \
        --exclude='*.bak' \
        --exclude='*.backup' \
        --exclude='agents.md' \
        --exclude='AGENTS.md' \
        --exclude='*.tmp' \
        --exclude='*.temp' \
        --exclude='*.swp' \
        --exclude='*.swo' \
        --exclude='*~' \
        --exclude='.DS_Store' \
        --exclude='Thumbs.db' \
        --exclude='*.tgz' \
        --exclude='*.tar.gz' \
        --exclude='*.zip' \
        --exclude='dist' \
        --exclude='build' \
        --exclude='*.egg-info' \
        --exclude='.pytest_cache' \
        --exclude='.coverage' \
        --exclude='htmlcov' \
        --exclude='.tox' \
        --exclude='.nox' \
        --exclude='.hypothesis' \
        --exclude='venv' \
        --exclude='.venv' \
        --exclude='ENV' \
        --exclude='env' \
        --exclude='.idea' \
        --exclude='.vscode' \
        --exclude='*.iml' \
        --exclude='.project' \
        --exclude='.pydevproject' \
        --exclude='*.log' \
        --exclude='logs' \
        --exclude='*.db' \
        --exclude='*.sqlite' \
        --exclude='*.sqlite3' \
        --exclude='.env' \
        --exclude='secrets' \
        --exclude='*.pem' \
        --exclude='*.key' \
        --exclude='*.crt' \
        -czvf "$OUTPUT_FILE" \
        .
    
    # Verify the package was created
    if [ -f "$OUTPUT_FILE" ]; then
        local size=$(du -h "$OUTPUT_FILE" | cut -f1)
        log_info "Package created successfully!"
        log_info "Output file: ${OUTPUT_FILE}"
        log_info "Package size: ${size}"
        
        # List contents summary
        log_info "Package contents summary:"
        tar -tzf "$OUTPUT_FILE" | head -20
        local total_files=$(tar -tzf "$OUTPUT_FILE" | wc -l)
        log_info "Total files in package: ${total_files}"
    else
        log_error "Failed to create package!"
        exit 1
    fi
}

#-------------------------------------------------------------------------------
# Usage information
#-------------------------------------------------------------------------------

show_usage() {
    cat << EOF
Usage: $(basename "$0") <input_folder> <version> [OPTIONS]

Arguments:
    input_folder    Path to the project folder to package (required)
    version         Version number for the package (required)

Options:
    -h, --help      Show this help message
    -o, --output    Specify output directory (default: <input_folder>/dist)
    -l, --list      List what would be included without creating package
    -v, --verify    Verify an existing package

Examples:
    $(basename "$0") /path/to/project 1.0.0           # Create package with version
    $(basename "$0") . 1.0.0                          # Package current directory
    $(basename "$0") /path/to/project 1.0.0 -o /tmp   # Specify output directory
    $(basename "$0") /path/to/project 1.0.0 -l        # List files without creating package
    $(basename "$0") -v package.tgz                   # Verify existing package

EOF
}

list_package_contents() {
    log_info "Files that would be included in package:"
    cd "$PROJECT_ROOT"
    
    local exclude_file=$(create_exclude_file)
    trap "rm -f $exclude_file" EXIT
    
    tar --exclude-from="$exclude_file" -tvf . | head -50
}

verify_package() {
    local package="$1"
    
    if [ ! -f "$package" ]; then
        log_error "Package not found: ${package}"
        exit 1
    fi
    
    log_info "Verifying package: ${package}"
    log_info "Package size: $(du -h "$package" | cut -f1)"
    log_info "File count: $(tar -tzf "$package" | wc -l)"
    log_info "Contents:"
    tar -tzf "$package" | head -30
}

#-------------------------------------------------------------------------------
# Main entry point
#-------------------------------------------------------------------------------

main() {
    local mode="full"
    local output_dir=""
    local verify_file=""
    local positional_args=()
    
    # First, check if we're in verify mode (only option that doesn't need positional args)
    if [[ "$1" == "-v" || "$1" == "--verify" ]]; then
        verify_file="$2"
        if [ -z "$verify_file" ]; then
            log_error "Please specify a package file to verify"
            show_usage
            exit 1
        fi
        verify_package "$verify_file"
        exit 0
    fi
    
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                show_usage
                exit 0
                ;;
            -o|--output)
                output_dir="$2"
                shift 2
                ;;
            -l|--list)
                mode="list"
                shift
                ;;
            -*)
                log_error "Unknown option: $1"
                show_usage
                exit 1
                ;;
            *)
                positional_args+=("$1")
                shift
                ;;
        esac
    done
    
    # Extract positional arguments
    if [ ${#positional_args[@]} -ge 1 ]; then
        INPUT_FOLDER="${positional_args[0]}"
    fi
    if [ ${#positional_args[@]} -ge 2 ]; then
        VERSION="${positional_args[1]}"
    fi
    
    # Re-validate after parsing
    if [ -z "$INPUT_FOLDER" ]; then
        echo "Error: Input folder is required"
        show_usage
        exit 1
    fi
    
    if [ -z "$VERSION" ]; then
        echo "Error: Version number is required"
        show_usage
        exit 1
    fi
    
    # Resolve to absolute path
    if [[ "$INPUT_FOLDER" = /* ]]; then
        PROJECT_ROOT="$INPUT_FOLDER"
    else
        PROJECT_ROOT="$(cd "$INPUT_FOLDER" 2>/dev/null && pwd)"
    fi
    
    # Update package name with version
    PACKAGE_NAME="backend-${VERSION}.tgz"
    OUTPUT_FILE="${OUTPUT_DIR}/${PACKAGE_NAME}"
    
    # Apply output directory override
    [ -n "$output_dir" ] && OUTPUT_DIR="$output_dir" && OUTPUT_FILE="${OUTPUT_DIR}/${PACKAGE_NAME}"
    
    case $mode in
        full)
            package_project
            ;;
        list)
            list_package_contents
            ;;
        verify)
            verify_package "$verify_file"
            ;;
    esac
}

# Run main function with all arguments
main "$@"
