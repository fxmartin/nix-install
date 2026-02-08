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
- [Qwen3-TTS Server](ai/qwen3-tts.md) - Local TTS server on port 8765 (Power profile only)
- [Whisper STT Server](ai/whisper-stt.md) - Local STT server on port 8766 (Power profile only)

**Individual Apps Covered**:
- Claude Desktop (Homebrew cask)
- ChatGPT Desktop (Homebrew cask)
- Perplexity (Mac App Store)
- Ollama Desktop (Homebrew cask)
- Qwen3-TTS Server (LaunchAgent, Power profile only)
- Whisper STT Server (LaunchAgent, Power profile only)

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

Virtualization software for running Windows, Linux, and macOS VMs on Apple Silicon.

- [Parallels Desktop](virtualization/parallels-desktop.md) - Professional VM software for macOS (Homebrew cask, **Power profile only**, subscription required)

**Note**: Parallels Desktop is installed **ONLY on Power profile** (MacBook Pro M3 Max) due to high resource requirements (CPU, RAM, disk). Standard profile (MacBook Air) uses cloud VMs when needed.

---

## 📊 File Organization

```
docs/apps/
├── README.md                           # This file - Master index
├── mac-app-store-requirements.md       # Prerequisites for mas installations
├── ai/
│   ├── ai-llm-tools.md                 # 4 AI tools (Claude, ChatGPT, Perplexity, Ollama)
│   ├── qwen3-tts.md                    # Qwen3-TTS server (Power profile only)
│   └── whisper-stt.md                  # Whisper STT server (Power profile only)
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
├── virtualization/
│   └── parallels-desktop.md            # Parallels Desktop (Power profile only)
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
- [Licensed Apps Guide](../licensed-apps.md) - Office 365, Parallels Desktop manual install

---

## 📝 Notes for FX

**File Split from**: `docs/app-post-install-configuration.md` (5,471 lines) was split into focused files for maintainability:

- **24 total files**: 1 index, 1 prerequisites, 22 app documentation files
- **Latest additions**: parallels-desktop.md (Story 02.8-001, ~1,300 lines), nordvpn.md (Story 02.7-001, ~900 lines), office-365.md (Story 02.9-001, ~700 lines)
- **Max file size**: ~1,300 lines (parallels-desktop.md comprehensive virtualization guide)
- **Benefits**: Easier navigation, parallel development, git-friendly diffs, story-aligned
- **Original file**: Archived as `app-post-install-configuration.md.backup`

**Story Alignment**:
- Each complex app (Claude Code CLI, VSCode, Arc, 1Password, etc.) has individual file
- Small related apps (Calibre, Kindle, Keka, Marked 2) grouped logically
- Matches Epic-02 feature structure from development stories
