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
# Main logic
# ============================================
main() {
    log_info "Starting DevOps tools installation..."
    
    if ! command_exists curl; then
        log_error "curl not found. Install it: sudo apt install curl"
        exit 1
    fi
    
    install_tofu
    install_talosctl
    install_helm
    install_kubectl
    configure_kubectl_alias
    
    log_info "All tools installed in $BIN_DIR"
    log_info "Completion files in $COMPLETION_DIR"
    echo ""
    log_warn "Add to ~/.bashrc to enable completions:"
    echo "for f in ~/.local/share/bash-completion/completions/*; do source \"\$f\"; done"
    echo ""
    log_info "Reload terminal or run: source ~/.bashrc"
}

main "$@"