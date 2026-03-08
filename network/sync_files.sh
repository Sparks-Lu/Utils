#!/bin/bash

# File Sync Script
# Syncs files from ipaddr1:/data to local /data using rsync
# Usage: ./sync_files.sh [options]

set -euo pipefail

# Configuration
SOURCE_IP="${SOURCE_IP:-ipaddr1}"
SOURCE_PATH="/data"
DEST_PATH="/data"
SSH_USER="${SSH_USER:-root}"
SSH_PORT="${SSH_PORT:-22}"
LOG_FILE="/var/log/file_sync.log"
DRY_RUN=false
VERBOSE=false

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Logging function
log() {
    local level="$1"
    local message="$2"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo -e "${timestamp} [${level}] ${message}" | tee -a "$LOG_FILE"
}

# Help message
show_help() {
    cat << EOF
Usage: $(basename "$0") [OPTIONS]

Sync files from ${SOURCE_IP}:${SOURCE_PATH} to local ${DEST_PATH}

Options:
    -h, --help              Show this help message
    -s, --source IP         Source server IP (default: ${SOURCE_IP})
    -u, --user USER          SSH user (default: ${SSH_USER})
    -p, --port PORT          SSH port (default: ${SSH_PORT})
    -n, --dry-run            Perform a dry run without making changes
    -v, --verbose            Enable verbose output
    -l, --log FILE           Log file path (default: ${LOG_FILE})

Environment Variables:
    SOURCE_IP                Source server IP
    SSH_USER                 SSH username
    SSH_PORT                 SSH port number

Examples:
    $(basename "$0")
    $(basename "$0") --source 192.168.1.10
    $(basename "$0") --dry-run --verbose
    SOURCE_IP=10.0.0.1 $(basename "$0")

Prerequisites:
    - SSH key-based authentication configured from local server to source
    - rsync installed on both source and local server
    - Sufficient permissions on both servers

EOF
    exit 0
}

# Parse command line arguments
parse_args() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                show_help
                ;;
            -s|--source)
                SOURCE_IP="$2"
                shift 2
                ;;
            -u|--user)
                SSH_USER="$2"
                shift 2
                ;;
            -p|--port)
                SSH_PORT="$2"
                shift 2
                ;;
            -n|--dry-run)
                DRY_RUN=true
                shift
                ;;
            -v|--verbose)
                VERBOSE=true
                shift
                ;;
            -l|--log)
                LOG_FILE="$2"
                shift 2
                ;;
            *)
                echo "Unknown option: $1"
                show_help
                ;;
        esac
    done
}

# Check prerequisites
check_prerequisites() {
    log "INFO" "Checking prerequisites..."
    
    # Check if rsync is installed
    if ! command -v rsync &> /dev/null; then
        log "ERROR" "rsync is not installed. Please install it first."
        exit 1
    fi
    
    # Check if ssh is installed
    if ! command -v ssh &> /dev/null; then
        log "ERROR" "ssh is not installed. Please install it first."
        exit 1
    fi
    
    # Create log directory if it doesn't exist
    LOG_DIR=$(dirname "$LOG_FILE")
    if [[ ! -d "$LOG_DIR" ]]; then
        sudo mkdir -p "$LOG_DIR"
        sudo chmod 755 "$LOG_DIR"
    fi
    
    # Check if we can write to log file
    if [[ ! -w "$LOG_FILE" ]] && [[ ! -w "$LOG_DIR" ]]; then
        log "WARN" "Cannot write to log file: ${LOG_FILE}. Using /tmp/file_sync.log"
        LOG_FILE="/tmp/file_sync.log"
    fi
    
    log "INFO" "Prerequisites check passed"
}

# Test SSH connectivity
test_connectivity() {
    log "INFO" "Testing SSH connectivity..."
    
    # Test connection to source
    log "INFO" "Testing connection to source: ${SSH_USER}@${SOURCE_IP}:${SSH_PORT}"
    if ! ssh -o ConnectTimeout=10 -o StrictHostKeyChecking=no -p "$SSH_PORT" "${SSH_USER}@${SOURCE_IP}" "exit" 2>/dev/null; then
        log "ERROR" "Cannot connect to source server: ${SOURCE_IP}"
        log "ERROR" "Please ensure SSH key-based authentication is configured"
        exit 1
    fi
    
    log "INFO" "SSH connectivity test passed"
}

# Check if source directory exists
check_source_directory() {
    log "INFO" "Checking source directory on ${SOURCE_IP}..."
    
    if ! ssh -p "$SSH_PORT" "${SSH_USER}@${SOURCE_IP}" "[[ -d '${SOURCE_PATH}' ]]" 2>/dev/null; then
        log "ERROR" "Source directory ${SOURCE_PATH} does not exist on ${SOURCE_IP}"
        exit 1
    fi
    
    log "INFO" "Source directory exists and is accessible"
}

# Ensure destination directory exists
ensure_destination_directory() {
    log "INFO" "Ensuring destination directory exists locally..."
    
    if [[ ! -d "${DEST_PATH}" ]]; then
        mkdir -p "${DEST_PATH}"
        log "INFO" "Created destination directory: ${DEST_PATH}"
    fi
    
    log "INFO" "Destination directory is ready"
}

# Perform the sync
perform_sync() {
    log "INFO" "Starting file sync..."
    
    # Build rsync command
    local RSYNC_OPTS=(
        -avz                          # archive mode, verbose, compress
        --progress                   # show progress
        --human-readable             # human readable numbers
        --delete                     # delete extraneous files from destination
        --stats                      # give some file-transfer stats
        -e "ssh -p ${SSH_PORT}"      # specify ssh port
    )
    
    if [[ "$DRY_RUN" == true ]]; then
        RSYNC_OPTS+=(--dry-run)
        log "INFO" "Dry run mode enabled - no changes will be made"
    fi
    
    if [[ "$VERBOSE" == true ]]; then
        RSYNC_OPTS+=(--verbose)
    fi
    
    # Construct source and destination
    local SOURCE="${SSH_USER}@${SOURCE_IP}:${SOURCE_PATH}/"
    local DEST="${DEST_PATH}/"
    
    log "INFO" "Syncing from ${SOURCE} to ${DEST}"
    
    # Execute rsync
    if rsync "${RSYNC_OPTS[@]}" "$SOURCE" "$DEST" 2>&1 | tee -a "$LOG_FILE"; then
        log "INFO" "${GREEN}Sync completed successfully${NC}"
    else
        log "ERROR" "${RED}Sync failed${NC}"
        exit 1
    fi
}

# Main function
main() {
    echo -e "${GREEN}======================================${NC}"
    echo -e "${GREEN}File Sync Script${NC}"
    echo -e "${GREEN}======================================${NC}"
    
    parse_args "$@"
    check_prerequisites
    test_connectivity
    check_source_directory
    ensure_destination_directory
    perform_sync
    
    echo -e "${GREEN}======================================${NC}"
    log "INFO" "Sync process completed"
    echo -e "${GREEN}======================================${NC}"
}

# Run main function
main "$@"