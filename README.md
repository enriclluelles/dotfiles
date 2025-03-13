# Dotfiles

A dotfiles repository managed with [chezmoi](https://chezmoi.io/) to automate setup of a macOS development environment.

## Overview

This repository contains configuration files (dotfiles) for various tools and applications, managed with chezmoi. The configuration is primarily designed for the [Fish shell](https://fishshell.com/), a smart and user-friendly command line shell with great defaults, and uses [Starship](https://starship.rs/) for a minimal, blazing-fast, and infinitely customizable prompt. It includes configurations for:

- Fish shell environment and customizations
- Starship cross-shell prompt
- Development tools
- Neovim with LazyVim
- Application configurations
- And more

Note: While the repository uses Fish as the primary shell, the `.zshrc` is maintained as a fallback. The Fish shell and Starship will be automatically installed via Brew Bundle.

## Prerequisites

Before you begin, ensure you have the following installed on your macOS system:

- [Homebrew](https://brew.sh/) - The package manager for macOS
- [chezmoi](https://chezmoi.io/) - The dotfiles manager

## Installation

### 1. Install Homebrew

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

### 2. Install chezmoi

```bash
brew install chezmoi
```

### 3. Initialize with this dotfiles repository

```bash
# Initialize chezmoi with this repository
chezmoi init https://github.com/YOURUSERNAME/dotfiles.git

# Preview what changes chezmoi would make to your system
chezmoi diff

# Apply the changes if you're happy with them
chezmoi apply -v
```

## Brew Bundle

This repository includes a Brewfile which manages all the applications and tools needed. To install all dependencies:

```bash
# Navigate to the Brewfile location
cd ~/.config/brewfile

# Install all dependencies (apps, tools, etc.)
brew bundle
```

The Brewfile includes:
- CLI tools (git, asdf, fzf, neovim, etc.) - installed in `/opt/homebrew/bin/`
- Applications (casks like Alacritty, Brave, VSCode, etc.) - installed in `/Applications/`
- Development dependencies

Note: Casks (GUI applications) are installed in your system's `/Applications` directory, while CLI tools are installed in Homebrew's directory.

## Neovim Configuration

This repository includes a custom Neovim setup powered by [LazyVim](https://www.lazyvim.org/), a modern Neovim configuration framework. The configuration is automatically managed by chezmoi and will be installed in `~/.config/nvim`.

### Features

- Modern IDE-like features
- Lazy-loaded plugins for fast startup
- Built-in LSP configuration
- Telescope for fuzzy finding
- Which-key for keybinding discovery
- And many more features from LazyVim's starter template

### Usage

Once the dotfiles are installed, you can start Neovim with:

```bash
nvim
```

On first launch, LazyVim will automatically:
1. Install all configured plugins
2. Set up LSP servers for your programming languages
3. Configure treesitter for syntax highlighting

### Common Commands

- `<Space>` - Leader key, shows available commands
- `<Space>ff` - Find files
- `<Space>fg` - Live grep
- `<Space>e` - File explorer
- `<Space>gg` - Lazygit
- `<Space>l` - Lazy plugin manager

### Customizing Neovim

The Neovim configuration can be customized by editing files in `~/.config/nvim/lua/`:

```bash
# Edit Neovim config with chezmoi
chezmoi edit ~/.config/nvim/lua/config/lazy.lua  # Plugin configuration
chezmoi edit ~/.config/nvim/lua/config/keymaps.lua  # Custom keymaps
chezmoi edit ~/.config/nvim/lua/config/options.lua  # Neovim options
```

After making changes:
1. Apply them with `chezmoi apply`
2. Restart Neovim for changes to take effect

## Key Components

- **Shell Configuration**: Fish shell configuration with custom functions and aliases
- **Prompt**: Starship cross-shell prompt with custom configuration
- **Tool Versions**: Managed with `.tool-versions` for asdf
- **Brewfile**: All applications and tools managed with Homebrew
- **Application Configs**: In the `.config` directory
- **Neovim Setup**: LazyVim-based configuration with custom plugins and settings

## Daily Usage

### Adding New Files to Your Dotfiles

When you want to add new configuration files to your dotfiles:

```bash
# Add a single file
chezmoi add ~/.config/some-config

# Add multiple files
chezmoi add ~/.config/fish/functions/*

# Add and edit a file immediately
chezmoi add --template ~/.ssh/config

# Add a private file (will be encrypted)
chezmoi add --encrypt ~/.ssh/id_rsa

# Add a directory and its contents recursively
chezmoi add ~/.config/fish
```

Note: When adding files, chezmoi will automatically:
- Convert the file path to its managed equivalent (e.g., `.config/fish` becomes `dot_config/fish`)
- Preserve the file's permissions and attributes
- Handle templates and private files appropriately when specified

### Updating Your Dotfiles

When you make changes to your configuration:

```bash
# Edit a file managed by chezmoi
chezmoi edit ~/.zshrc

# See what changes you made
chezmoi diff

# Apply the changes
chezmoi apply

# Commit and push the changes to your repository
chezmoi cd
git add .
git commit -m "Update configuration"
git push
```

### Updating on Another Machine

```bash
# Pull the latest changes
chezmoi update
```

### Managing Homebrew Dependencies

To update your Brewfile after installing new software:

```bash
# Dump all currently installed Homebrew packages to Brewfile
brew bundle dump --force --file=~/.config/brewfile/Brewfile

# Apply changes from your Brewfile
brew bundle --file=~/.config/brewfile/Brewfile
```

## Customizing

To customize this setup for your own use:

1. Fork this repository
2. Update the `.chezmoi.toml.tmpl` file with your preferences
3. Modify the dotfiles to match your needs
4. Update the Brewfile to include your preferred applications 