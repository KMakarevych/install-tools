# Install Tools

Bash script for automatic installation of popular DevOps tools and AI agents into the user's home directory.

## Installed Tools

### DevOps Tools
- **OpenTofu** - open-source Terraform alternative
- **Talosctl** - CLI for managing Talos Linux
- **Helm** - package manager for Kubernetes
- **Kubectl** - CLI for managing Kubernetes clusters

### AI Agents (requires Node.js and npm)
- **Claude Code CLI** - Anthropic's AI coding assistant
- **Gemini CLI** - Google's AI agent for terminal
- **Qwen Code CLI** - Alibaba's agentic coding tool

## Features

- Automatic architecture detection (amd64, arm64, arm)
- Installation of latest stable versions
- Bash completion configuration for all tools
- Adding `k` alias for `kubectl`
- Installation in `~/.local/bin` (no sudo required)
- Automatic npm configuration for home directory (no sudo required for AI agents)
- Automatic PATH configuration for both bash and fish shells
- Smart detection of existing PATH entries

## Requirements

### Required for DevOps Tools
- **curl** - for downloading files
- **bash** - version 4.0 or newer
- **tar** - for extracting archives

### Optional for AI Agents
- **Node.js** - version 18 or newer
- **npm** - Node package manager

## Usage

### Quick Installation (Remote)

Install directly from GitHub:

```bash
curl https://raw.githubusercontent.com/KMakarevych/install-tools/refs/heads/main/script.sh | bash -
```

### Local Installation

If you have already cloned the repository:

```bash
bash script.sh
```

### Excluding Tools

You can exclude specific tools from installation using the `--exclude` parameter:

```bash
# Exclude single tool
bash script.sh --exclude=talosctl

# Exclude multiple tools
bash script.sh --exclude=talosctl,helm

# Remote installation with exclusions
curl https://raw.githubusercontent.com/KMakarevych/install-tools/refs/heads/main/script.sh | bash -s -- --exclude=talosctl,helm
```

Available tools for exclusion:
- `tofu` - OpenTofu
- `talosctl` - Talosctl
- `helm` - Helm
- `kubectl` - Kubectl
- `claude` - Claude Code CLI
- `gemini` - Gemini CLI
- `qwen` - Qwen Code CLI

### Help

Display usage information:

```bash
bash script.sh --help
```

### Post-Installation

#### For Bash Users

1. Add `~/.local/bin` to PATH (if not already added):

```bash
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
```

2. Enable bash completion:

```bash
echo 'for f in ~/.local/share/bash-completion/completions/*; do source "$f"; done' >> ~/.bashrc
```

3. Reload configuration:

```bash
source ~/.bashrc
```

#### For Fish Users

1. Add `~/.local/bin` to PATH (if not already added):

```fish
fish_add_path ~/.local/bin
```

2. Enable fish completion for the tools:

```fish
# Create fish completion directory if it doesn't exist
mkdir -p ~/.config/fish/completions

# Generate and install completions for kubectl
kubectl completion fish > ~/.config/fish/completions/kubectl.fish

# Generate and install completions for helm
helm completion fish > ~/.config/fish/completions/helm.fish

# Add kubectl alias
alias --save k=kubectl
```

3. Fish will automatically reload the configuration. If needed, start a new shell session or run:

```fish
exec fish
```

## Directory Structure

- `~/.local/bin/` - DevOps tool executable files
- `~/.local/share/bash-completion/completions/` - completion files
- `~/.local/npm/` - npm global packages directory
- `~/.local/npm/bin/` - AI agents executable files

## Supported Platforms

- **OS**: Linux, macOS
- **Architectures**: x86_64 (amd64), aarch64 (arm64), armv7l (arm)

## Version Check

After installation, check versions:

### DevOps Tools
```bash
tofu version
talosctl version
helm version
kubectl version --client
```

### AI Agents
```bash
claude --version
gemini --version
qwen --version
```

## Aliases

The script automatically configures:

- `k` - short alias for `kubectl`

## Updates

To update tools, simply run the script again:

```bash
bash script.sh
```

## AI Agents Setup

The script automatically installs AI agents if Node.js and npm are detected. If they are not installed, you'll see a warning message.

### Installing Node.js and npm

```bash
# Debian/Ubuntu
sudo apt install nodejs npm

# Fedora/RHEL
sudo dnf install nodejs npm

# Arch Linux
sudo pacman -S nodejs npm

# macOS
brew install node
```

### Using AI Agents

After installation, the AI agents are available globally:

```bash
# Claude Code - Anthropic's AI coding assistant
claude --help

# Gemini CLI - Google's AI agent for terminal
gemini --help

# Qwen Code - Alibaba's agentic coding tool
qwen --help
```

### npm Configuration

The script automatically:
- Configures npm to install global packages in `~/.local/npm` (no sudo required)
- Adds `~/.local/npm/bin` to PATH in both bash and fish configurations
- Checks for existing PATH entries to avoid duplicates

## Troubleshooting

### curl not found

```bash
# Debian/Ubuntu
sudo apt install curl

# Fedora/RHEL
sudo dnf install curl

# Arch Linux
sudo pacman -S curl
```

### npm not found

If you want to install AI agents but don't have npm:

```bash
# Debian/Ubuntu
sudo apt install nodejs npm

# Fedora/RHEL
sudo dnf install nodejs npm

# Arch Linux
sudo pacman -S nodejs npm
```

After installing npm, run the script again to install AI agents.

### PATH does not contain ~/.local/bin or ~/.local/npm/bin

The script automatically adds these directories to your shell configuration. If they're not working:

For bash, add to your `~/.bashrc`:

```bash
export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/.local/npm/bin:$PATH"
```

For fish, run:

```fish
fish_add_path ~/.local/bin
fish_add_path ~/.local/npm/bin
```

### Completion not working

Make sure you added the line to load completion files in `~/.bashrc` and reloaded the shell.

## License

This script is free software and can be used without restrictions.
