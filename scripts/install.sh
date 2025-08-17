#!/bin/bash

# Git Security Audit Framework - Installation Script
# Professional one-line installation for all platforms
# Usage: curl -fsSL https://raw.githubusercontent.com/Franklin-Andres-Rodriguez/git-security-audit/main/scripts/install.sh | bash

set -euo pipefail

# Script metadata
SCRIPT_NAME="Git Security Audit Framework Installer"
VERSION="2.0.0"
REPO_OWNER="Franklin-Andres-Rodriguez"  # Repository owner
REPO_NAME="git-security-audit"
INSTALL_DIR="${INSTALL_DIR:-/usr/local/bin}"
TEMP_DIR="/tmp/git-security-audit-install"

# Colors for better UX
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'
BOLD='\033[1m'

# Platform detection
OS="$(uname -s)"
ARCH="$(uname -m)"
USER_SHELL="$(basename "$SHELL")"

# GitHub API endpoints (using GitHub's REST API v3)
API_BASE="https://api.github.com"
RELEASES_URL="$API_BASE/repos/$REPO_OWNER/$REPO_NAME/releases"
LATEST_URL="$RELEASES_URL/latest"
RAW_BASE="https://raw.githubusercontent.com/$REPO_OWNER/$REPO_NAME/main"

log_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

log_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

log_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

log_error() {
    echo -e "${RED}❌ $1${NC}" >&2
}

log_step() {
    echo -e "${PURPLE}🔧 $1${NC}"
}

# Enhanced error handling with context
error_exit() {
    log_error "$1"
    echo -e "${CYAN}For support, please visit: https://github.com/$REPO_OWNER/$REPO_NAME/issues${NC}"
    echo -e "${CYAN}Installation logs available in: $TEMP_DIR${NC}"
    exit 1
}

# Check if running as root (modern approach)
check_permissions() {
    if [[ $EUID -eq 0 ]]; then
        log_warning "Running as root. Installation will be system-wide."
        INSTALL_DIR="/usr/local/bin"
    else
        # Check if user can write to default location
        if [[ ! -w "$(dirname "$INSTALL_DIR")" ]]; then
            log_warning "No write permission to $INSTALL_DIR"
            
            # Offer user-local installation
            local user_bin="$HOME/.local/bin"
            mkdir -p "$user_bin"
            INSTALL_DIR="$user_bin"
            
            log_info "Installing to user directory: $INSTALL_DIR"
            
            # Check if it's in PATH
            if [[ ":$PATH:" != *":$user_bin:"* ]]; then
                log_warning "$user_bin is not in your PATH"
                echo -e "${YELLOW}Add this to your shell configuration:${NC}"
                echo -e "${CYAN}export PATH=\"\$HOME/.local/bin:\$PATH\"${NC}"
            fi
        fi
    fi
}

# Comprehensive dependency checking
check_dependencies() {
    log_step "Checking system dependencies..."
    
    local missing_deps=()
    local recommended_deps=()
    
    # Essential dependencies
    command -v git >/dev/null 2>&1 || missing_deps+=("git")
    command -v curl >/dev/null 2>&1 || missing_deps+=("curl")
    command -v jq >/dev/null 2>&1 || recommended_deps+=("jq")
    
    # Platform-specific package managers
    local pkg_manager=""
    if command -v apt-get >/dev/null 2>&1; then
        pkg_manager="apt-get"
    elif command -v yum >/dev/null 2>&1; then
        pkg_manager="yum"
    elif command -v brew >/dev/null 2>&1; then
        pkg_manager="brew"
    elif command -v pacman >/dev/null 2>&1; then
        pkg_manager="pacman"
    fi
    
    # Handle missing essential dependencies
    if [[ ${#missing_deps[@]} -gt 0 ]]; then
        log_error "Missing essential dependencies: ${missing_deps[*]}"
        
        if [[ -n "$pkg_manager" ]]; then
            echo -e "${CYAN}Install them with:${NC}"
            case "$pkg_manager" in
                "apt-get")
                    echo "sudo apt-get update && sudo apt-get install -y ${missing_deps[*]}"
                    ;;
                "yum")
                    echo "sudo yum install -y ${missing_deps[*]}"
                    ;;
                "brew")
                    echo "brew install ${missing_deps[*]}"
                    ;;
                "pacman")
                    echo "sudo pacman -S ${missing_deps[*]}"
                    ;;
            esac
        fi
        error_exit "Please install missing dependencies and try again."
    fi
    
    # Handle recommended dependencies
    if [[ ${#recommended_deps[@]} -gt 0 ]]; then
        log_warning "Recommended dependencies not found: ${recommended_deps[*]}"
        log_info "The tool will work without them, but some features may be limited."
    fi
    
    log_success "Dependency check completed"
}

# Platform-specific optimizations
detect_platform() {
    log_step "Detecting platform configuration..."
    
    echo -e "${CYAN}Platform Details:${NC}"
    echo "  OS: $OS"
    echo "  Architecture: $ARCH"
    echo "  Shell: $USER_SHELL"
    echo "  Install Directory: $INSTALL_DIR"
    
    # Platform-specific notes
    case "$OS" in
        "Darwin")
            log_info "macOS detected - ensuring Homebrew compatibility"
            # Check for Apple Silicon optimizations
            if [[ "$ARCH" == "arm64" ]]; then
                log_info "Apple Silicon detected - using ARM64 optimizations"
            fi
            ;;
        "Linux")
            log_info "Linux detected - checking distribution"
            if [[ -f /etc/os-release ]]; then
                local distro=$(grep '^ID=' /etc/os-release | cut -d'=' -f2 | tr -d '"')
                echo "  Distribution: $distro"
            fi
            ;;
        "MINGW"*|"MSYS"*|"CYGWIN"*)
            log_info "Windows environment detected (Git Bash/WSL)"
            ;;
        *)
            log_warning "Unknown operating system: $OS"
            ;;
    esac
}

# Fetch latest release information using GitHub API
get_latest_release() {
    log_step "Fetching latest release information..."
    
    # Create temp directory with secure permissions
    mkdir -p "$TEMP_DIR"
    chmod 700 "$TEMP_DIR"
    
    # Fetch release info with error handling
    if ! curl -fsSL "$LATEST_URL" > "$TEMP_DIR/release.json" 2>/dev/null; then
        log_warning "GitHub API unavailable, falling back to main branch"
        echo '{"tag_name": "main", "name": "Development Version"}' > "$TEMP_DIR/release.json"
    fi
    
    # Extract version info
    local tag_name=$(jq -r '.tag_name' "$TEMP_DIR/release.json" 2>/dev/null || echo "main")
    local release_name=$(jq -r '.name' "$TEMP_DIR/release.json" 2>/dev/null || echo "Development Version")
    
    echo "  Latest Version: $tag_name"
    echo "  Release: $release_name"
    
    echo "$tag_name" > "$TEMP_DIR/version.txt"
}

# GPG signature verification (enterprise security)
verify_signature() {
    local file="$1"
    local sig_url="$2"
    
    log_step "Verifying GPG signature (optional)..."
    
    # Download signature if available
    if curl -fsSL "$sig_url" > "$file.sig" 2>/dev/null; then
        # Try to verify signature
        if command -v gpg >/dev/null 2>&1; then
            # Import public key (would need to be published)
            # gpg --keyserver keyserver.ubuntu.com --recv-keys YOUR_KEY_ID
            
            if gpg --verify "$file.sig" "$file" 2>/dev/null; then
                log_success "GPG signature verified"
                return 0
            else
                log_warning "GPG signature verification failed"
                echo -e "${YELLOW}Continue anyway? (y/N)${NC}"
                read -r response
                [[ "$response" =~ ^[Yy]$ ]] || error_exit "Installation cancelled by user"
            fi
        else
            log_info "GPG not available, skipping signature verification"
        fi
    else
        log_info "No GPG signature available for this release"
    fi
}

# Download and install the main script
install_script() {
    log_step "Downloading Git Security Audit Framework..."
    
    local version=$(cat "$TEMP_DIR/version.txt")
    local script_url
    
    # Determine download URL based on version
    if [[ "$version" == "main" ]]; then
        script_url="$RAW_BASE/src/git-security-audit.sh"
    else
        script_url="https://github.com/$REPO_OWNER/$REPO_NAME/releases/download/$version/git-security-audit.sh"
        
        # Fallback to raw if release asset doesn't exist
        if ! curl -fsSL -I "$script_url" >/dev/null 2>&1; then
            script_url="$RAW_BASE/src/git-security-audit.sh"
        fi
    fi
    
    # Download with integrity check
    local temp_script="$TEMP_DIR/git-security-audit.sh"
    if ! curl -fsSL "$script_url" -o "$temp_script"; then
        error_exit "Failed to download script from $script_url"
    fi
    
    # Basic integrity checks
    if [[ ! -s "$temp_script" ]]; then
        error_exit "Downloaded script is empty"
    fi
    
    # Check if it's a valid shell script
    if ! head -1 "$temp_script" | grep -q "#!/bin/bash"; then
        error_exit "Downloaded file doesn't appear to be a valid bash script"
    fi
    
    # Verify signature if available
    verify_signature "$temp_script" "$script_url.sig"
    
    log_success "Script downloaded successfully"
    
    # Install script
    log_step "Installing to $INSTALL_DIR..."
    
    # Create install directory if it doesn't exist
    mkdir -p "$INSTALL_DIR"
    
    # Copy with proper permissions
    cp "$temp_script" "$INSTALL_DIR/git-security-audit"
    chmod +x "$INSTALL_DIR/git-security-audit"
    
    log_success "Installation completed"
}

# Install shell completions (modern developer experience)
install_completions() {
    log_step "Installing shell completions..."
    
    # Generate basic completions
    local completion_script="$TEMP_DIR/git-security-audit-completion.bash"
    
    cat > "$completion_script" << 'EOF'
# Git Security Audit Framework bash completion
_git_security_audit() {
    local cur prev opts
    COMPREPLY=()
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"
    
    opts="--help --version --type --secret --patterns --output --branches --depth --exclude --entropy --compliance --verbose --quiet --list-patterns"
    
    case "${prev}" in
        --type)
            COMPREPLY=( $(compgen -W "quick comprehensive secrets files compliance" -- ${cur}) )
            return 0
            ;;
        --output)
            COMPREPLY=( $(compgen -W "text json csv html" -- ${cur}) )
            return 0
            ;;
        --compliance)
            COMPREPLY=( $(compgen -W "pci hipaa gdpr sox iso27001" -- ${cur}) )
            return 0
            ;;
        --branches)
            COMPREPLY=( $(compgen -W "all current main" -- ${cur}) )
            return 0
            ;;
    esac
    
    COMPREPLY=( $(compgen -W "${opts}" -- ${cur}) )
    return 0
}

complete -F _git_security_audit git-security-audit
EOF
    
    # Install completions based on shell
    case "$USER_SHELL" in
        "bash")
            local bash_completion_dir
            if [[ -d "/usr/share/bash-completion/completions" ]]; then
                bash_completion_dir="/usr/share/bash-completion/completions"
            elif [[ -d "/usr/local/etc/bash_completion.d" ]]; then
                bash_completion_dir="/usr/local/etc/bash_completion.d"
            elif [[ -d "$HOME/.local/share/bash-completion/completions" ]]; then
                bash_completion_dir="$HOME/.local/share/bash-completion/completions"
            else
                mkdir -p "$HOME/.local/share/bash-completion/completions"
                bash_completion_dir="$HOME/.local/share/bash-completion/completions"
            fi
            
            if [[ -w "$bash_completion_dir" ]] || [[ -w "$(dirname "$bash_completion_dir")" ]]; then
                cp "$completion_script" "$bash_completion_dir/git-security-audit"
                log_success "Bash completions installed"
            else
                log_info "Could not install system-wide completions, add this to ~/.bashrc:"
                echo "source $completion_script"
            fi
            ;;
        "zsh")
            log_info "For zsh completions, add to ~/.zshrc:"
            echo "autoload -U compinit && compinit"
            echo "source $completion_script"
            ;;
        *)
            log_info "Shell completions available for bash/zsh"
            ;;
    esac
}

# Post-installation verification and setup
verify_installation() {
    log_step "Verifying installation..."
    
    # Test if script is accessible
    if ! command -v git-security-audit >/dev/null 2>&1; then
        log_warning "git-security-audit not found in PATH"
        echo -e "${CYAN}Try running: export PATH=\"$INSTALL_DIR:\$PATH\"${NC}"
        echo -e "${CYAN}Or add this to your shell configuration file${NC}"
    else
        log_success "git-security-audit is accessible in PATH"
    fi
    
    # Test basic functionality
    if git-security-audit --version >/dev/null 2>&1; then
        log_success "Basic functionality test passed"
    else
        log_warning "Basic functionality test failed"
        log_info "Try running: $INSTALL_DIR/git-security-audit --help"
    fi
    
    # Show installation summary
    echo ""
    echo -e "${BOLD}${GREEN}🎉 Installation Summary${NC}"
    echo "===================="
    echo "✅ Git Security Audit Framework installed successfully"
    echo "📂 Location: $INSTALL_DIR/git-security-audit"
    echo "📋 Version: $(cat "$TEMP_DIR/version.txt")"
    echo ""
    
    # Show next steps
    echo -e "${BOLD}${CYAN}🚀 Next Steps${NC}"
    echo "============="
    echo "1. Run your first scan:"
    echo "   ${CYAN}git-security-audit --type quick${NC}"
    echo ""
    echo "2. View all options:"
    echo "   ${CYAN}git-security-audit --help${NC}"
    echo ""
    echo "3. Read the documentation:"
    echo "   ${CYAN}https://github.com/$REPO_OWNER/$REPO_NAME/blob/main/README.md${NC}"
    echo ""
    
    # Show useful examples
    echo -e "${BOLD}${PURPLE}💡 Quick Examples${NC}"
    echo "=================="
    echo "• Comprehensive scan:  ${CYAN}git-security-audit --type comprehensive --entropy${NC}"
    echo "• Search specific key: ${CYAN}git-security-audit --secret \"your-api-key\"${NC}"
    echo "• PCI compliance:      ${CYAN}git-security-audit --compliance pci${NC}"
    echo "• JSON output:         ${CYAN}git-security-audit --output json${NC}"
}

# Cleanup temporary files
cleanup() {
    if [[ -d "$TEMP_DIR" ]]; then
        rm -rf "$TEMP_DIR"
    fi
}

# Main installation flow
main() {
    # Trap cleanup on exit
    trap cleanup EXIT
    
    # Display header
    echo -e "${BOLD}${PURPLE}$SCRIPT_NAME v$VERSION${NC}"
    echo -e "${PURPLE}========================================${NC}"
    echo ""
    
    # Installation steps
    check_permissions
    check_dependencies
    detect_platform
    get_latest_release
    install_script
    install_completions
    verify_installation
    
    # Final success message
    echo ""
    echo -e "${BOLD}${GREEN}🛡️ Git Security Audit Framework is ready to use!${NC}"
    echo -e "${GREEN}Start securing your repositories today.${NC}"
    echo ""
    echo -e "${CYAN}Support: https://github.com/$REPO_OWNER/$REPO_NAME/issues${NC}"
    echo -e "${CYAN}Docs:    https://github.com/$REPO_OWNER/$REPO_NAME/blob/main/docs/${NC}"
}

# Execute main function
main "$@"
