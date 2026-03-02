#!/bin/bash

# =============================================================================
# Frontend Source Package Script
# =============================================================================
# This script creates a tgz archive containing only source code and 
# configuration files for frontend projects (Vue, React, Angular, etc.).
#
# Excludes: node_modules, dist, .git, build artifacts, temp files
#
# Usage: ./package.sh <source_folder> [version]
#   source_folder: Path to the project root (default: current directory)
#   version:       Optional version tag (default: uses package.json version)
#
# Examples:
#   ./package.sh                              # Package current directory
#   ./package.sh /path/to/project             # Package specified project
#   ./package.sh /path/to/project 2.0.0       # Package with custom version
#
# Output: {project-name}-{version}-src.tgz
# =============================================================================

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Logging functions
log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Show usage
show_usage() {
    echo "Usage: $0 <source_folder> [version]"
    echo ""
    echo "Arguments:"
    echo "  source_folder  Path to the frontend project root"
    echo "  version        Optional version (default: from package.json)"
    echo ""
    echo "Examples:"
    echo "  $0 .                           # Package current directory"
    echo "  $0 /path/to/project            # Package specified project"
    echo "  $0 /path/to/project 2.0.0      # Package with custom version"
}

# Get project name from folder or package.json
get_project_name() {
    local source_dir=$1
    local name=""
    
    # Try to get name from package.json
    if [ -f "${source_dir}/package.json" ]; then
        name=$(grep '"name"' "${source_dir}/package.json" | head -1 | sed 's/.*: "\(.*\)",.*/\1/')
    fi
    
    # Fallback to folder name
    if [ -z "$name" ] || [ "$name" = "" ]; then
        name=$(basename "${source_dir}")
    fi
    
    echo "$name"
}

# Get version from argument or package.json
get_version() {
    local source_dir=$1
    local version_arg=$2
    
    if [ -n "$version_arg" ]; then
        echo "$version_arg"
    elif [ -f "${source_dir}/package.json" ]; then
        grep '"version"' "${source_dir}/package.json" | head -1 | sed 's/.*: "\(.*\)",.*/\1/'
    else
        echo "1.0.0"
    fi
}

# Create exclude patterns file
create_exclude_file() {
    local source_dir=$1
    local exclude_file="${source_dir}/.package_exclude"
    
    cat > "${exclude_file}" << 'EOF'
.git
.gitignore
.gitattributes
node_modules
dist
build
out
.next
.nuxt
packages
*.tgz
*.tar.gz
*.log
.DS_Store
Thumbs.db
.vscode
.idea
*.swp
*.swo
*~
.env.local
.env.*.local
.env.production
.env.development
coverage
.nyc_output
.package_exclude
package-lock.json
pnpm-lock.yaml
yarn.lock
package.sh
build.sh
deploy.sh
EOF
    
    echo "${exclude_file}"
}

# Create the source tgz archive
create_archive() {
    local source_dir=$1
    local project_name=$2
    local version=$3
    local archive_name="${project_name}-${version}-src.tgz"
    local output_dir="${source_dir}/packages"
    local archive_path="${output_dir}/${archive_name}"
    local exclude_file=$(create_exclude_file "${source_dir}")

    log_info "Creating source archive: ${archive_name}"

    # Create output directory
    mkdir -p "${output_dir}"

    # Create archive excluding specified patterns
    tar --exclude-from="${exclude_file}" \
        -czf "${archive_path}" \
        -C "${source_dir}" .

    # Clean up exclude file
    rm -f "${exclude_file}"

    # Create a manifest file
    cat > "${output_dir}/MANIFEST.md" << EOF
# Package Manifest

## Package Information
- **Name**: ${project_name}
- **Version**: ${version}
- **Build Date**: $(date -u +"%Y-%m-%dT%H:%M:%SZ")
- **Archive**: ${archive_name}
- **Type**: Source Code (not build artifacts)

## Contents
$(tar -tzf "${archive_path}" | grep -v '^\\.$' | head -50)

## Included Files
- Source code (src/ or app/)
- Configuration files (package.json, vite.config.js, etc.)
- Documentation (README.md)
- Build scripts

## Excluded Files
- node_modules/
- dist/, build/, out/
- .git/
- Temporary files
- IDE configurations
- Lock files (package-lock.json, yarn.lock, pnpm-lock.yaml)

## Installation
\`\`\`bash
# Extract the archive
tar -xzf ${archive_name}

# Install dependencies
npm install

# Build the project
npm run build
\`\`\`

## SHA256 Checksum
$(sha256sum "${archive_path}" | awk '{print $1}')
EOF

    log_info "Archive created successfully: ${archive_path}"
    log_info "Manifest created: ${output_dir}/MANIFEST.md"

    # Display archive info
    echo ""
    log_info "Archive Details:"
    echo "  Size: $(du -h "${archive_path}" | cut -f1)"
    echo "  Files: $(tar -tzf "${archive_path}" | grep -v '/$' | wc -l)"
    echo "  SHA256: $(sha256sum "${archive_path}" | awk '{print $1}')"
    
    echo ""
    log_info "Archive Contents Preview:"
    tar -tzf "${archive_path}" | grep -v '^\\.$' | head -20 | sed 's/^/  /'
}

# Main execution
main() {
    echo "=============================================="
    echo "  Frontend Source Package Generator"
    echo "=============================================="
    echo ""

    # Parse arguments
    local source_dir=""
    local version=""

    if [ -z "$1" ]; then
        # No arguments - use current directory
        source_dir="$(pwd)"
    elif [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
        show_usage
        exit 0
    else
        source_dir="$1"
        version="$2"
    fi

    # Resolve to absolute path
    source_dir="$(cd "${source_dir}" && pwd)"

    # Get project name and version
    local project_name=$(get_project_name "${source_dir}")
    local pkg_version=$(get_version "${source_dir}" "${version}")

    log_info "Source Directory: ${source_dir}"
    log_info "Project Name: ${project_name}"
    log_info "Version: ${pkg_version}"

    # Verify required files exist
    if [ ! -f "${source_dir}/package.json" ]; then
        log_error "package.json not found in ${source_dir}"
        exit 1
    fi

    # Check for common frontend source directories
    local has_source=false
    for src_dir in "src" "app" "pages" "components"; do
        if [ -d "${source_dir}/${src_dir}" ]; then
            has_source=true
            break
        fi
    done

    if [ "$has_source" = false ]; then
        log_warn "No standard source directory found (src/, app/, pages/, components/)"
        log_warn "Proceeding anyway..."
    fi

    # Create archive
    create_archive "${source_dir}" "${project_name}" "${pkg_version}"

    echo ""
    log_info "Source package generation complete!"
    log_info "Output directory: ${source_dir}/packages"
}

# Run main function with all arguments
main "$@"
