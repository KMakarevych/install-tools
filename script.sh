#!/usr/bin/env bash
set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Logging functions
log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

# Check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Detect architecture
ARCH=$(uname -m)
case $ARCH in
    x86_64) ARCH="amd64" ;;
    aarch64) ARCH="arm64" ;;
    armv7l) ARCH="arm" ;;
    *) log_error "Unsupported architecture: $ARCH"; exit 1 ;;
esac

OS=$(uname -s | tr '[:upper:]' '[:lower:]')
BIN_DIR="${HOME}/.local/bin"
COMPLETION_DIR="${HOME}/.local/share/bash-completion/completions"
NPM_DIR="${HOME}/.local/npm"
NPM_BIN_DIR="${NPM_DIR}/bin"

# Parse arguments
EXCLUDED_TOOLS=()
for arg in "$@"; do
    case $arg in
        --exclude=*)
            IFS=',' read -ra EXCLUDED_TOOLS <<< "${arg#*=}"
            ;;
        --help|-h)
            echo "Usage: $0 [OPTIONS]"
            echo ""
            echo "Options:"
            echo "  --exclude=tool1,tool2  Exclude specific tools from installation"
            echo "                         Available tools: tofu, talosctl, helm, kubectl, claude, gemini, qwen"
            echo "  --help, -h             Show this help message"
            echo ""
            echo "Example:"
            echo "  $0 --exclude=talosctl,helm"
            echo "  $0 --exclude=claude,gemini,qwen  # Exclude all AI agents"
            exit 0
            ;;
    esac
done

# Check if tool is excluded
is_excluded() {
    local tool=$1
    for excluded in "${EXCLUDED_TOOLS[@]}"; do
        if [[ "$excluded" == "$tool" ]]; then
            return 0
        fi
    done
    return 1
}

# Configure npm to use home directory
configure_npm() {
    log_info "Configuring npm to use home directory..."
    mkdir -p "$NPM_DIR" "$NPM_BIN_DIR"

    npm config set prefix "$NPM_DIR"
    log_info "npm configured to install global packages in $NPM_DIR"
}

# Add directory to PATH in bash configuration
add_to_bash_path() {
    local dir=$1
    local bashrc="${HOME}/.bashrc"
    local path_line="export PATH=\"${dir}:\$PATH\""

    # Create .bashrc if it doesn't exist
    touch "$bashrc"

    # Check if PATH entry already exists
    if grep -qF "$path_line" "$bashrc" 2>/dev/null; then
        log_info "PATH already contains $dir in ~/.bashrc"
        return 0
    fi

    # Check if similar PATH entry exists (with different formatting)
    if grep -q "PATH.*${dir}" "$bashrc" 2>/dev/null; then
        log_info "PATH already contains $dir in ~/.bashrc (different format)"
        return 0
    fi

    # Add PATH entry
    echo "" >> "$bashrc"
    echo "# Added by install-tools script" >> "$bashrc"
    echo "$path_line" >> "$bashrc"
    log_info "Added $dir to PATH in ~/.bashrc"
}

# Add directory to PATH in fish configuration
add_to_fish_path() {
    local dir=$1
    local fish_config="${HOME}/.config/fish/config.fish"
    local fish_config_dir="${HOME}/.config/fish"

    # Create fish config directory and file if they don't exist
    mkdir -p "$fish_config_dir"
    touch "$fish_config"

    # Check if PATH entry already exists using fish_add_path
    if grep -qF "fish_add_path $dir" "$fish_config" 2>/dev/null; then
        log_info "PATH already contains $dir in fish config"
        return 0
    fi

    # Check if PATH entry exists using set -gx PATH
    if grep -q "set -gx PATH.*${dir}" "$fish_config" 2>/dev/null; then
        log_info "PATH already contains $dir in fish config (different format)"
        return 0
    fi

    # Add PATH entry using fish_add_path (preferred method)
    echo "" >> "$fish_config"
    echo "# Added by install-tools script" >> "$fish_config"
    echo "fish_add_path $dir" >> "$fish_config"
    log_info "Added $dir to PATH in fish config"
}

# Create directories
mkdir -p "$BIN_DIR" "$COMPLETION_DIR"

# Check if BIN_DIR is in PATH
if [[ ":$PATH:" != *":$BIN_DIR:"* ]]; then
    log_warn "Add $BIN_DIR to PATH in ~/.bashrc:"
    echo "export PATH=\"\$HOME/.local/bin:\$PATH\""
fi

# ============================================
# OpenTofu
# ============================================
install_tofu() {
    log_info "Installing OpenTofu..."
    
    TOFU_VERSION=$(curl -s https://api.github.com/repos/opentofu/opentofu/releases/latest | grep '"tag_name"' | cut -d'"' -f4 | sed 's/v//')
    TOFU_URL="https://github.com/opentofu/opentofu/releases/download/v${TOFU_VERSION}/tofu_${TOFU_VERSION}_${OS}_${ARCH}.tar.gz"
    
    curl -sL "$TOFU_URL" | tar -xz -C "$BIN_DIR" tofu
    chmod +x "$BIN_DIR/tofu"
    
    # Completion
    "$BIN_DIR/tofu" -install-autocomplete 2>/dev/null || true
    log_info "OpenTofu v${TOFU_VERSION} installed"
}

# ============================================
# Talosctl
# ============================================
install_talosctl() {
    log_info "Installing talosctl..."
    
    TALOS_VERSION=$(curl -s https://api.github.com/repos/siderolabs/talos/releases/latest | grep '"tag_name"' | cut -d'"' -f4)
    TALOS_URL="https://github.com/siderolabs/talos/releases/download/${TALOS_VERSION}/talosctl-${OS}-${ARCH}"
    
    curl -sL "$TALOS_URL" -o "$BIN_DIR/talosctl"
    chmod +x "$BIN_DIR/talosctl"
    
    # Completion
    "$BIN_DIR/talosctl" completion bash > "$COMPLETION_DIR/talosctl"
    log_info "Talosctl ${TALOS_VERSION} installed"
}

# ============================================
# Helm
# ============================================
install_helm() {
    log_info "Installing Helm..."
    
    HELM_VERSION=$(curl -s https://api.github.com/repos/helm/helm/releases/latest | grep '"tag_name"' | cut -d'"' -f4)
    HELM_URL="https://get.helm.sh/helm-${HELM_VERSION}-${OS}-${ARCH}.tar.gz"
    
    curl -sL "$HELM_URL" | tar -xz -C /tmp
    mv "/tmp/${OS}-${ARCH}/helm" "$BIN_DIR/helm"
    rm -rf "/tmp/${OS}-${ARCH}"
    chmod +x "$BIN_DIR/helm"
    
    # Completion
    "$BIN_DIR/helm" completion bash > "$COMPLETION_DIR/helm"
    log_info "Helm ${HELM_VERSION} installed"
}

# ============================================
# Kubectl
# ============================================
install_kubectl() {
    log_info "Installing kubectl..."
    
    KUBECTL_VERSION=$(curl -sL https://dl.k8s.io/release/stable.txt)
    KUBECTL_URL="https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/${OS}/${ARCH}/kubectl"
    
    curl -sL "$KUBECTL_URL" -o "$BIN_DIR/kubectl"
    chmod +x "$BIN_DIR/kubectl"
    
    # Completion
    "$BIN_DIR/kubectl" completion bash > "$COMPLETION_DIR/kubectl"
    log_info "Kubectl ${KUBECTL_VERSION} installed"
}

# ============================================
# Configure kubectl alias
# ============================================
configure_kubectl_alias() {
    log_info "Configuring kubectl alias 'k'..."
    
    BASHRC="${HOME}/.bashrc"
    ALIAS_CONFIG="# Kubectl alias
alias k=kubectl
complete -o default -F __start_kubectl k"
    
    # Check if alias already exists
    if grep -q "alias k=kubectl" "$BASHRC" 2>/dev/null; then
        log_warn "Kubectl alias 'k' already exists in ~/.bashrc"
    else
        echo "" >> "$BASHRC"
        echo "$ALIAS_CONFIG" >> "$BASHRC"
        log_info "Kubectl alias 'k' added to ~/.bashrc"
    fi
}

# ============================================
# AI Agents Installation
# ============================================

# Claude Code CLI
install_claude() {
    log_info "Installing Claude Code CLI..."

    if ! command_exists npm; then
        log_error "npm not found. Install Node.js and npm first"
        return 1
    fi

    npm install -g @anthropic-ai/claude-code
    log_info "Claude Code CLI installed"
}

# Gemini CLI
install_gemini() {
    log_info "Installing Gemini CLI..."

    if ! command_exists npm; then
        log_error "npm not found. Install Node.js and npm first"
        return 1
    fi

    npm install -g @google/gemini-cli
    log_info "Gemini CLI installed"
}

# Qwen Code CLI
install_qwen() {
    log_info "Installing Qwen Code CLI..."

    if ! command_exists npm; then
        log_error "npm not found. Install Node.js and npm first"
        return 1
    fi

    npm install -g @qwen-code/qwen-code
    log_info "Qwen Code CLI installed"
}

# ============================================
# Main logic
# ============================================
main() {
    log_info "Starting DevOps tools installation..."

    if ! command_exists curl; then
        log_error "curl not found. Install it: sudo apt install curl"
        exit 1
    fi

    # Show excluded tools if any
    if [ ${#EXCLUDED_TOOLS[@]} -gt 0 ]; then
        log_warn "Excluding tools: ${EXCLUDED_TOOLS[*]}"
    fi

    # Install tools conditionally
    if ! is_excluded "tofu"; then
        install_tofu
    else
        log_info "Skipping OpenTofu (excluded)"
    fi

    if ! is_excluded "talosctl"; then
        install_talosctl
    else
        log_info "Skipping Talosctl (excluded)"
    fi

    if ! is_excluded "helm"; then
        install_helm
    else
        log_info "Skipping Helm (excluded)"
    fi

    if ! is_excluded "kubectl"; then
        install_kubectl
        configure_kubectl_alias
    else
        log_info "Skipping Kubectl (excluded)"
    fi

    # Configure npm and install AI agents if npm is available
    if command_exists npm; then
        log_info "npm found, configuring for AI agents installation..."
        configure_npm

        # Add npm bin directory to PATH for both bash and fish
        add_to_bash_path "$NPM_BIN_DIR"
        add_to_fish_path "$NPM_BIN_DIR"

        # Install AI agents conditionally
        if ! is_excluded "claude"; then
            install_claude
        else
            log_info "Skipping Claude Code CLI (excluded)"
        fi

        if ! is_excluded "gemini"; then
            install_gemini
        else
            log_info "Skipping Gemini CLI (excluded)"
        fi

        if ! is_excluded "qwen"; then
            install_qwen
        else
            log_info "Skipping Qwen Code CLI (excluded)"
        fi
    else
        log_warn "npm not found. Skipping AI agents installation."
        log_warn "Install Node.js and npm to enable AI agents: sudo apt install nodejs npm"
    fi

    log_info "Installation complete! Tools installed in $BIN_DIR"
    log_info "Completion files in $COMPLETION_DIR"
    if command_exists npm; then
        log_info "AI agents installed in $NPM_BIN_DIR"
    fi
    echo ""
    log_warn "Add to ~/.bashrc to enable completions:"
    echo "for f in ~/.local/share/bash-completion/completions/*; do source \"\$f\"; done"
    echo ""
    log_info "Reload terminal or run: source ~/.bashrc"
}

main "$@"