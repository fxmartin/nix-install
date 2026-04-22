# ABOUTME: Master index for application post-installation configuration guides
# ABOUTME: Organized by category with links to individual app documentation files

# Application Post-Install Configuration Index

This directory contains step-by-step configuration guides for applications installed by nix-darwin.

**Philosophy**: All app updates are controlled via `rebuild` or `update` commands only. Auto-updates must be disabled for all apps that support this setting.

---

## 📋 Prerequisites

**⚠️ CRITICAL - READ FIRST**: Before installing apps via darwin-rebuild:

- [Mac App Store Requirements](mac-app-store-requirements.md) - Sign-in, fresh machine setup, terminal permissions

---

## 🤖 AI & LLM Tools

Desktop applications for AI-powered assistance and local language models.

- [AI & LLM Tools Overview](ai/ai-llm-tools.md) - Claude Desktop, ChatGPT Desktop, Perplexity, Ollama Desktop

**Individual Apps Covered**:
- Claude Desktop (Homebrew cask)
- ChatGPT Desktop (Homebrew cask)
- Perplexity (Mac App Store)
- Ollama Desktop (Homebrew cask)

---

## 💻 Development Environment

Development tools including editors, terminals, containers, and CLI tools.

### Code Editors
- [Zed Editor](dev/zed-editor.md) - Modern, collaborative code editor (Homebrew cask)
- [VSCode](dev/vscode.md) - Visual Studio Code editor (Homebrew cask)

### Terminal & Shell
- [Ghostty Terminal](dev/ghostty-terminal.md) - GPU-accelerated terminal with Catppuccin theming (Homebrew cask)

### Development Tools
- [Python Tools](dev/python-tools.md) - Python 3.12, uv package manager, ruff linter/formatter (Nix packages)
- [Podman](dev/podman.md) - Container engine and CLI tools (Homebrew)

### Advanced Tools
- [Claude Code CLI](dev/claude-code-cli.md) - AI-powered development assistant with MCP servers (npm)

---

## 🌐 Browsers

Web browsers for development and daily use.

- [Brave Browser](browsers/brave.md) - Privacy-focused Chromium browser with Shields (Homebrew cask)
- [Arc Browser](browsers/arc.md) - Modern browser with Spaces workspaces (Homebrew cask)

---

## 🛠️ Productivity & Utilities

Apps for productivity, file management, and system utilities.

### Launchers & Password Management
- [Raycast](productivity/raycast.md) - Keyboard-first launcher and command palette (Homebrew cask)
- [1Password](productivity/1password.md) - Password manager and secure vault (Homebrew cask)

### File & Document Utilities
- [File Utilities](productivity/file-utilities.md) - Calibre (ebook manager), Kindle (ebook reader), Keka (archiver), Marked 2 (markdown previewer)

### File Sync & Cloud Storage
- [Dropbox](productivity/dropbox.md) - Cloud storage and file synchronization (Homebrew cask, account required)

### Office & Productivity Suites
- [Microsoft Office 365](productivity/office-365.md) - Complete productivity suite with Word, Excel, PowerPoint, Outlook, OneNote, Teams (Homebrew cask, subscription required)

### System Utilities
- [System Utilities](productivity/system-utilities.md) - Onyx (system maintenance), f.lux (screen temperature)

---

## 💬 Communication Tools

Apps for messaging, video conferencing, and collaboration.

- [WhatsApp](communication/whatsapp.md) - Messaging app with QR code pairing (Homebrew cask)
- [Zoom](communication/zoom.md) - Video conferencing platform (Homebrew cask)
- [Cisco Webex](communication/cisco-webex.md) - Enterprise collaboration platform (Homebrew cask)

---

## 🎨 Media & Creative Tools

Apps for media playback and image editing.

- [VLC Media Player](media/vlc.md) - Universal media player supporting all formats (Homebrew cask)

---

## 🔒 Security & VPN

VPN and security applications for privacy and secure connections.

- [NordVPN](security/nordvpn.md) - VPN privacy and security service (Homebrew cask, subscription required)

---

## 🖥️ Virtualization & Development Tools

Parallels Desktop was removed from all profiles. On-device virtualization is handled implicitly by Apple Virtualization.framework (used by Claude Desktop's sandbox); orphan VM processes are monitored by the notify-only watchdog at `scripts/virt-vm-orphan-watch.sh`.

For heavier VM workloads, use any Apple-Silicon-capable hypervisor (UTM, VMware Fusion, etc.) manually — those aren't managed declaratively.

---

## 📊 File Organization

```
docs/apps/
├── README.md                           # This file - Master index
├── mac-app-store-requirements.md       # Prerequisites for mas installations
├── ai/
│   └── ai-llm-tools.md                 # 4 AI tools (Claude, ChatGPT, Perplexity, Ollama)
├── dev/
│   ├── zed-editor.md                   # Zed configuration
│   ├── vscode.md                       # VSCode configuration
│   ├── ghostty-terminal.md             # Terminal configuration
│   ├── python-tools.md                 # Python dev stack
│   ├── podman.md                       # Container tools
│   └── claude-code-cli.md              # Claude Code CLI setup
├── browsers/
│   ├── brave.md                        # Brave browser
│   └── arc.md                          # Arc browser
├── productivity/
│   ├── raycast.md                      # Raycast launcher
│   ├── 1password.md                    # Password manager
│   ├── dropbox.md                      # Dropbox cloud storage
│   ├── office-365.md                   # Microsoft Office 365 suite
│   ├── file-utilities.md               # Calibre, Kindle, Keka, Marked 2
│   └── system-utilities.md             # Onyx, f.lux
├── communication/
│   ├── whatsapp.md                     # WhatsApp messaging
│   ├── zoom.md                         # Zoom video conferencing
│   └── cisco-webex.md                  # Cisco Webex collaboration
├── media/
│   └── vlc.md                          # VLC media player
├── security/
│   └── nordvpn.md                      # NordVPN VPN service
└── system/
    └── system-monitoring.md            # iStat Menus, gotop, macmon
```

---

## 📖 How to Use This Documentation

1. **Prerequisites First**: Review [Mac App Store Requirements](mac-app-store-requirements.md) before darwin-rebuild
2. **Category Navigation**: Use sections above to find your app category
3. **App-Specific Guides**: Click links to individual app configuration guides
4. **Testing Checklists**: Each guide includes checkboxes for post-install validation
5. **Auto-Update Disable**: Follow steps in each guide to disable app auto-updates

---

## 🔗 Related Documentation

- [REQUIREMENTS.md](../REQUIREMENTS.md) - Full project requirements and app inventory
- [Development Progress](../development/README.md) - Story implementation status
- [Homebrew Configuration](../../darwin/homebrew.nix) - App installation declarations
- [Licensed Apps Guide](../licensed-apps.md) - Office 365 and licensed-app activation (1Password, iStat Menus, NordVPN, etc.)

---

## 📝 Notes for FX

**File Split from**: `docs/app-post-install-configuration.md` (5,471 lines) was split into focused files for maintainability:

- **23 total files**: 1 index, 1 prerequisites, 21 app documentation files
- **Latest additions**: nordvpn.md (Story 02.7-001, ~900 lines), office-365.md (Story 02.9-001, ~700 lines)
- **Max file size**: ~900 lines (nordvpn.md comprehensive VPN guide)
- **Benefits**: Easier navigation, parallel development, git-friendly diffs, story-aligned
- **Original file**: Archived as `app-post-install-configuration.md.backup`

**Story Alignment**:
- Each complex app (Claude Code CLI, VSCode, Arc, 1Password, etc.) has individual file
- Small related apps (Calibre, Kindle, Keka, Marked 2) grouped logically
- Matches Epic-02 feature structure from development stories
