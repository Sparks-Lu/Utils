#!/bin/bash

# Install Python 3.12 from source on Ubuntu 20.04
# Usage: sudo ./install_python312.sh

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

PYTHON_VERSION="3.12.0"
INSTALL_PREFIX="/usr/local"
BUILD_DIR="/tmp/python-build-$(date +%s)"

# Chinese mirror sites (ordered by preference)
PYTHON_MIRRORS=(
    "https://mirrors.tuna.tsinghua.edu.cn/python/${PYTHON_VERSION}/Python-${PYTHON_VERSION}.tgz"
    "https://mirrors.huaweicloud.com/python/${PYTHON_VERSION}/Python-${PYTHON_VERSION}.tgz"
    "https://npmmirror.com/mirrors/python/${PYTHON_VERSION}/Python-${PYTHON_VERSION}.tgz"
    "https://mirrors.aliyun.com/python/${PYTHON_VERSION}/Python-${PYTHON_VERSION}.tgz"
)

log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

check_root() {
    if [[ $EUID -ne 0 ]]; then
        log_error "This script must be run as root (use sudo)"
        exit 1
    fi
}

install_dependencies() {
    log_info "Installing build dependencies..."
    
    apt-get update
    
    apt-get install -y \
        build-essential \
        zlib1g-dev \
        libncurses5-dev \
        libgdbm-dev \
        libnss3-dev \
        libssl-dev \
        libreadline-dev \
        libffi-dev \
        libsqlite3-dev \
        wget \
        libbz2-dev \
        liblzma-dev \
        tk-dev \
        uuid-dev \
        libgdbm-compat-dev \
        dpkg-dev
    
    log_info "Dependencies installed successfully."
}

download_python() {
    log_info "Downloading Python ${PYTHON_VERSION} from Chinese mirrors..."
    
    mkdir -p "${BUILD_DIR}"
    cd "${BUILD_DIR}"
    
    local downloaded=false
    
    for mirror in "${PYTHON_MIRRORS[@]}"; do
        log_info "Trying mirror: ${mirror}"
        if wget --timeout=30 --tries=2 "${mirror}" -O "Python-${PYTHON_VERSION}.tgz"; then
            downloaded=true
            log_info "Download successful from: ${mirror}"
            break
        else
            log_warn "Failed to download from: ${mirror}"
        fi
    done
    
    if [[ "${downloaded}" == false ]]; then
        log_error "Failed to download Python from all mirrors"
        exit 1
    fi
    
    log_info "Extracting source code..."
    tar -xzf "Python-${PYTHON_VERSION}.tgz"
    
    log_info "Download and extraction complete."
}

build_python() {
    log_info "Configuring Python build..."
    
    cd "${BUILD_DIR}/Python-${PYTHON_VERSION}"
    
    # Configure with optimizations and shared library support
    ./configure \
        --prefix="${INSTALL_PREFIX}" \
        --enable-optimizations \
        --with-lto \
        --enable-shared \
        --with-system-ffi \
        --with-ensurepip=install \
        LDFLAGS="-Wl,-rpath,${INSTALL_PREFIX}/lib"
    
    log_info "Building Python (this may take a while)..."
    
    # Use multiple cores for faster build
    NPROC=$(nproc)
    make -j"${NPROC}"
    
    log_info "Installing Python..."
    make altinstall
    
    log_info "Build and installation complete."
}

post_install() {
    log_info "Performing post-installation setup..."
    
    # Update shared library cache
    ldconfig
    
    # Create symlinks for convenience (optional)
    if [[ ! -e "${INSTALL_PREFIX}/bin/python3.12" ]]; then
        log_warn "Python 3.12 binary not found at expected location"
    else
        log_info "Python 3.12 installed at: ${INSTALL_PREFIX}/bin/python3.12"
        log_info "Pip 3.12 installed at: ${INSTALL_PREFIX}/bin/pip3.12"
    fi
    
    # Verify installation
    if "${INSTALL_PREFIX}/bin/python3.12" --version; then
        log_info "Python 3.12 installed successfully!"
    else
        log_error "Python installation verification failed"
        exit 1
    fi
    
    # Upgrade pip
    log_info "Upgrading pip..."
    "${INSTALL_PREFIX}/bin/python3.12" -m pip install --upgrade pip
    
    # Install setuptools for distutils compatibility (removed in Python 3.12)
    # Required by virtualenv, mkvirtualenv, and other tools
    log_info "Installing setuptools for distutils compatibility..."
    "${INSTALL_PREFIX}/bin/python3.12" -m pip install setuptools
    
    log_info "distutils compatibility layer installed."
}

cleanup() {
    log_info "Cleaning up build directory..."
    rm -rf "${BUILD_DIR}"
    log_info "Cleanup complete."
}

print_usage() {
    echo ""
    echo "=========================================="
    echo "Python 3.12 Installation Complete!"
    echo "=========================================="
    echo ""
    echo "Usage:"
    echo "  python3.12   -> ${INSTALL_PREFIX}/bin/python3.12"
    echo "  pip3.12      -> ${INSTALL_PREFIX}/bin/pip3.12"
    echo ""
    echo "To make python3 default to python3.12, add to ~/.bashrc:"
    echo "  alias python3='${INSTALL_PREFIX}/bin/python3.12'"
    echo "  alias pip3='${INSTALL_PREFIX}/bin/pip3.12'"
    echo ""
}

main() {
    log_info "Starting Python ${PYTHON_VERSION} installation from source..."
    
    check_root
    install_dependencies
    download_python
    build_python
    post_install
    cleanup
    print_usage
    
    log_info "All done! Enjoy Python 3.12!"
}

# Run main function
main "$@"