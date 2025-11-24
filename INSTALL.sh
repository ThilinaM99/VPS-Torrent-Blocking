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
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
BOLD='\033[1m'
NC='\033[0m'

# Configuration
REPO_URL="https://raw.githubusercontent.com/ThilinaM99/VPS-Torrent-Blocking/main"
TEMP_DIR="/tmp/torrent-blocking-install"
INSTALL_SCRIPT="install-enhanced.sh"

# Functions
print_header() {
    echo ""
    echo -e "${CYAN}${BOLD}╔════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}${BOLD}║  $1${NC}"
    echo -e "${CYAN}${BOLD}╚════════════════════════════════════════╝${NC}"
    echo ""
}

print_section() {
    echo -e "${MAGENTA}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${MAGENTA}${BOLD}$1${NC}"
    echo -e "${MAGENTA}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

print_success() {
    echo -e "${GREEN}${BOLD}✅ $1${NC}"
}

print_error() {
    echo -e "${RED}${BOLD}❌ $1${NC}"
}

print_info() {
    echo -e "${BLUE}${BOLD}ℹ️  $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}${BOLD}⚠️  $1${NC}"
}

print_step() {
    echo -e "${CYAN}▶ $1${NC}"
}

# Check root
check_root() {
    print_info "Checking root privileges..."
    if [[ $EUID -ne 0 ]]; then
        print_error "This script must be run as root"
        echo "Please run: ${CYAN}sudo bash INSTALL.sh${NC}"
        exit 1
    fi
    print_success "Root privileges confirmed"
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

# ASCII Art Banner
print_banner() {
    echo -e "${CYAN}"
    echo "  ╔═══════════════════════════════════════════════════════════╗"
    echo "  ║                                                           ║"
    echo "  ║    ██╗   ██╗██████╗ ███████╗    ████████╗ ██████╗       ║"
    echo "  ║    ██║   ██║██╔══██╗██╔════╝    ╚══██╔══╝██╔═══██╗      ║"
    echo "  ║    ██║   ██║██████╔╝███████╗       ██║   ██║   ██║      ║"
    echo "  ║    ╚██╗ ██╔╝██╔═══╝ ╚════██║       ██║   ██║   ██║      ║"
    echo "  ║     ╚████╔╝ ██║     ███████║       ██║   ╚██████╔╝      ║"
    echo "  ║      ╚═══╝  ╚═╝     ╚══════╝       ╚═╝    ╚═════╝       ║"
    echo "  ║                                                           ║"
    echo "  ║          🛡️  TORRENT BLOCKING INSTALLER 🛡️              ║"
    echo "  ║                                                           ║"
    echo "  ╚═══════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
}

# Main
main() {
    print_banner
    
    print_header "VPS Torrent Blocking - Installation"
    
    print_section "Pre-Installation Checks"
    check_root
    check_internet
    check_dependencies
    
    print_section "Downloading Installer"
    download_installer
    
    print_section "Running Installation"
    run_installer
    
    print_section "Cleanup"
    cleanup
    
    # Success Banner
    echo -e "${GREEN}"
    echo "  ╔═══════════════════════════════════════════════════════════╗"
    echo "  ║                                                           ║"
    echo "  ║              ✨ INSTALLATION SUCCESSFUL! ✨              ║"
    echo "  ║                                                           ║"
    echo "  ║   Your server is now protected from torrent traffic!     ║"
    echo "  ║                                                           ║"
    echo "  ╚═══════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
    echo ""
    
    print_section "Next Steps"
    echo ""
    print_step "View statistics:"
    echo "   ${CYAN}cat /var/log/torrent-blocking/blocking-stats.txt${NC}"
    echo ""
    print_step "Monitor logs in real-time:"
    echo "   ${CYAN}tail -f /var/log/torrent-blocking/blocked-domains.log${NC}"
    echo ""
    print_step "Uninstall if needed:"
    echo "   ${CYAN}sudo /opt/torrent-blocking/uninstall.sh${NC}"
    echo ""
    
    print_section "Documentation"
    echo ""
    echo -e "${MAGENTA}  📚 GitHub Repository:${NC}"
    echo "   ${CYAN}https://github.com/ThilinaM99/VPS-Torrent-Blocking${NC}"
    echo ""
    echo -e "${MAGENTA}  📂 Installation Directory:${NC}"
    echo "   ${CYAN}/opt/torrent-blocking${NC}"
    echo ""
    echo -e "${MAGENTA}  📋 Configuration Directory:${NC}"
    echo "   ${CYAN}/etc/torrent-blocklists${NC}"
    echo ""
    
    # Footer
    echo -e "${CYAN}"
    echo "  ╔═══════════════════════════════════════════════════════════╗"
    echo "  ║  Thank you for using VPS Torrent Blocking! Stay secure!  ║"
    echo "  ╚═══════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
    echo ""
}

# Run main function
main
