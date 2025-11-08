# nix-install
Repository for automated declarative deployment for my machines

## Quick Start

### Option 1: One-Command Setup (Automatic)

For a quick setup that proceeds automatically after 5 seconds:

```bash
curl -sSL https://raw.githubusercontent.com/fxmartin/nix-install/main/setup.sh | bash
```

### Option 2: Download and Run (Interactive)

For full interactive control with confirmation prompts:

```bash
curl -o setup.sh https://raw.githubusercontent.com/fxmartin/nix-install/main/setup.sh
chmod +x setup.sh
./setup.sh
```

This will automatically:

- Download the full installation script
- Perform system checks
- Ask for your preferred directory name (defaults to dotfile)
- Guide you through the complete setup process
