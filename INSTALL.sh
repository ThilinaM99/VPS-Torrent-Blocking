#!/bin/bash

################################################################################
# VPS Torrent Blocking - One-Command Installation Script
# 
# This script downloads and runs the enhanced installation automatically
# Works on Ubuntu, Debian, and other Linux distributions
#
# Usage: bash INSTALL.sh
# Or: wget https://raw.githubusercontent.com/ThilinaM99/VPS-Torrent-Blocking/main/INSTALL.sh && bash INSTALL.sh
#
################################################################################

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Configuration
REPO_URL="https://raw.githubusercontent.com/ThilinaM99/VPS-Torrent-Blocking/main"
TEMP_DIR="/tmp/torrent-blocking-install"
INSTALL_SCRIPT="install-enhanced.sh"

# Functions
print_header() {
    echo -e "${BLUE}========================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}========================================${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

# Check root
check_root() {
    if [[ $EUID -ne 0 ]]; then
        print_error "This script must be run as root"
        echo "Please run: sudo bash INSTALL.sh"
        exit 1
    fi
}

# Check internet
check_internet() {
    print_info "Checking internet connection..."
    if ! ping -c 1 8.8.8.8 &> /dev/null; then
        print_error "No internet connection"
        exit 1
    fi
    print_success "Internet connection OK"
}

# Check dependencies
check_dependencies() {
    print_info "Checking dependencies..."
    
    if ! command -v wget &> /dev/null; then
        print_warning "wget not found, installing..."
        apt-get update -qq
        apt-get install -y wget > /dev/null 2>&1
    fi
    
    print_success "Dependencies OK"
}

# Download installer
download_installer() {
    print_info "Downloading enhanced installer..."
    
    mkdir -p "$TEMP_DIR"
    cd "$TEMP_DIR"
    
    if wget -q "$REPO_URL/$INSTALL_SCRIPT"; then
        print_success "Installer downloaded"
        chmod +x "$INSTALL_SCRIPT"
    else
        print_error "Failed to download installer"
        exit 1
    fi
}

# Run installer
run_installer() {
    print_header "Starting Enhanced Installation"
    
    cd "$TEMP_DIR"
    bash "$INSTALL_SCRIPT"
    
    if [ $? -eq 0 ]; then
        print_success "Installation completed successfully"
    else
        print_error "Installation failed"
        exit 1
    fi
}

# Cleanup
cleanup() {
    print_info "Cleaning up temporary files..."
    rm -rf "$TEMP_DIR"
    print_success "Cleanup complete"
}

# Main
main() {
    print_header "VPS Torrent Blocking - Installation"
    
    check_root
    check_internet
    check_dependencies
    download_installer
    run_installer
    cleanup
    
    print_header "Installation Complete!"
    echo ""
    print_success "Your server is now protected from torrent traffic"
    echo ""
    echo "Next steps:"
    echo "  1. View statistics: cat /var/log/torrent-blocking/blocking-stats.txt"
    echo "  2. Monitor logs: tail -f /var/log/torrent-blocking/blocked-domains.log"
    echo "  3. Uninstall: sudo /opt/torrent-blocking/uninstall.sh"
    echo ""
    print_info "For more information, visit: https://github.com/ThilinaM99/VPS-Torrent-Blocking"
}

# Run main function
main
