# Install Tools

Bash script for automatic installation of popular DevOps tools into the user's home directory.

## Installed Tools

- **OpenTofu** - open-source Terraform alternative
- **Talosctl** - CLI for managing Talos Linux
- **Helm** - package manager for Kubernetes
- **Kubectl** - CLI for managing Kubernetes clusters

## Features

- Automatic architecture detection (amd64, arm64, arm)
- Installation of latest stable versions
- Bash completion configuration for all tools
- Adding `k` alias for `kubectl`
- Installation in `~/.local/bin` (no sudo required)

## Requirements

- **curl** - for downloading files
- **bash** - version 4.0 or newer
- **tar** - for extracting archives

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

- `~/.local/bin/` - executable files
- `~/.local/share/bash-completion/completions/` - completion files

## Supported Platforms

- **OS**: Linux, macOS
- **Architectures**: x86_64 (amd64), aarch64 (arm64), armv7l (arm)

## Version Check

After installation, check versions:

```bash
tofu version
talosctl version
helm version
kubectl version --client
```

## Aliases

The script automatically configures:

- `k` - short alias for `kubectl`

## Updates

To update tools, simply run the script again:

```bash
bash script.sh
```

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

### PATH does not contain ~/.local/bin

Add to your `~/.bashrc`:

```bash
export PATH="$HOME/.local/bin:$PATH"
```

### Completion not working

Make sure you added the line to load completion files in `~/.bashrc` and reloaded the shell.

## License

This script is free software and can be used without restrictions.
