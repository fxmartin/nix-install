# ABOUTME: AI and LLM desktop applications configuration guide
# ABOUTME: Covers Claude Desktop, ChatGPT Desktop, Perplexity, Ollama (CLI), Open WebUI, and Qwen3-TTS

# AI & LLM Tools

## Claude Desktop

**Status**: Installed via Homebrew cask `claude` (Story 02.1-001)

**First Launch**:
1. Launch Claude Desktop from Spotlight or Raycast
2. Sign in with your Anthropic account
3. Complete the onboarding flow

**Auto-Update Configuration**:
- **Current Status**: ⚠️ **Requires Manual Check**
- **Steps to Disable** (if available):
  1. Open Claude Desktop
  2. Navigate to **Preferences** (Cmd+,) or **Settings**
  3. Look for **General** or **Updates** section
  4. Disable automatic update checking if option exists
  5. Document actual steps after first VM test

**Testing**:
- [ ] Launch Claude Desktop successfully
- [ ] Sign-in flow completes
- [ ] Accessible from Spotlight/Raycast
- [ ] Check for auto-update setting in preferences

---

## ChatGPT Desktop

**Status**: Installed via Homebrew cask `chatgpt` (Story 02.1-001)

**First Launch**:
1. Launch ChatGPT Desktop from Spotlight or Raycast
2. Sign in with your OpenAI account
3. Complete the onboarding flow

**Auto-Update Configuration**:
- **Current Status**: ⚠️ **Requires Manual Check**
- **Steps to Disable** (if available):
  1. Open ChatGPT Desktop
  2. Navigate to **Preferences** (Cmd+,) or **Settings**
  3. Look for **General** or **Updates** section
  4. Disable automatic update checking if option exists
  5. Document actual steps after first VM test

**Testing**:
- [ ] Launch ChatGPT Desktop successfully
- [ ] Sign-in flow completes
- [ ] Accessible from Spotlight/Raycast
- [ ] Check for auto-update setting in preferences

---

## Perplexity

**Status**: Installed via **Mac App Store** (App ID: 6714467650) - Story 02.1-001

**⚠️ CRITICAL - FRESH MACHINE REQUIREMENT**: On brand new Macs, Perplexity MUST be installed manually via App Store GUI first, then darwin-rebuild can manage it.

**First-Time Installation on Fresh Mac** (Issue #25, #26):
1. Open **App Store** app
2. Search for **"Perplexity"** or navigate to your Purchased apps
3. Click the **cloud download icon** (☁️↓) to install manually
4. Wait for installation to complete
5. **Then** run darwin-rebuild (mas CLI will work after first manual install)

**Why Manual Install Required**:
- Fresh macOS installations require the first App Store install to be manual (GUI-based)
- This initializes Mac App Store services and permissions
- The `mas` CLI tool (used by nix-darwin) cannot install apps on completely fresh systems
- Error: `Code=201 "The installation could not be started"`
- After one manual install, `mas` works normally for all subsequent installs

**⚠️ PREREQUISITE**: You must be signed into the Mac App Store BEFORE running darwin-rebuild (see [Mac App Store Requirements](../mac-app-store-requirements.md))

**Important Notes**:
- Perplexity is distributed via Mac App Store, not Homebrew
- Released as native macOS app on October 24, 2024
- **Installation requires**: Mac App Store sign-in (mas authentication)
- **Fresh machines**: Manual GUI install required first (see above)
- Auto-updates managed by App Store preferences (not app-level settings)

**First Launch**:
1. Launch Perplexity from Spotlight or Raycast
2. Sign in with your Perplexity account (optional for basic features)
3. Complete the onboarding flow
4. Free tier: 5 Pro Searches per day
5. Pro tier: $20/month for 600 Pro Searches daily

**Auto-Update Configuration**:
- **Managed by**: macOS App Store (system-level)
- **To disable App Store auto-updates**:
  1. Open **System Settings** → **App Store**
  2. Uncheck **Automatic Updates** for all apps
  3. Or manage per-app: Right-click app in Launchpad → **Options** → **Turn Off Automatic Updates**
- **Note**: App Store updates are system-wide, not per-app for Mac App Store installations

**Testing**:
- [ ] Launch Perplexity successfully (installed from App Store)
- [ ] Sign-in flow completes (optional, not required)
- [ ] Accessible from Spotlight/Raycast
- [ ] Verify App Store update settings are disabled system-wide

**Features**:
- Pro Search with advanced AI models (GPT-4, Claude 3)
- Voice input for hands-free queries
- Threaded conversations with context
- Library feature for archived searches
- All responses include cited sources

---

## Ollama (CLI + LaunchAgent)

**Status**: Installed via Homebrew formula `ollama` (in Nix system PATH) — **CLI only, no GUI app**

The Ollama GUI app (`ollama-app` cask) has been removed to eliminate the port conflict where two Ollama servers competed for port 11434. The nix-darwin LaunchAgent `ollama-serve` (defined in `darwin/maintenance.nix`) now runs Ollama bound to `0.0.0.0:11434` for Tailscale access.

**Daemon Management**:
- Managed by nix-darwin LaunchAgent `ollama-serve` (starts at login)
- Bound to `0.0.0.0:11434` (accessible via Tailscale)
- OLLAMA_ORIGINS restricts API access to localhost and Tailscale IPs (100.x.x.x)
- The LaunchAgent kills any existing Ollama process before starting to avoid conflicts

**CLI Verification**:
```bash
# Verify Ollama CLI is available
ollama --version

# List installed models
ollama list

# Test API access
curl http://localhost:11434/api/version
```

**Model Storage**:
- Models stored in: `~/.ollama/models`
- Can be large (12GB-70GB per model)
- Models are pulled automatically during `darwin-rebuild` via activation scripts

**Web Interface**: Use **Open WebUI** (see below) for a browser-based chat interface.

---

## Open WebUI (Podman Container)

**Status**: Managed via nix-darwin LaunchAgent — **Both profiles**

A web-based chat interface for Ollama models, running as a Podman container. Started automatically at login. Accessible at `http://localhost:3000` and via Tailscale.

**Configuration** (`darwin/open-webui.nix`):
- **Container image**: `ghcr.io/open-webui/open-webui:main`
- **Port**: `3000` (host) → `8080` (container)
- **Ollama connection**: `http://host.containers.internal:11434`
- **Data persistence**: `open-webui` named Podman volume
- **Auth**: Disabled (`WEBUI_AUTH=false`) — single-user setup

**First Launch**:
1. Ensure Podman machine is running: `podman machine start`
2. Wait for the LaunchAgent to pull the image and start the container
3. Browse to `http://localhost:3000`
4. No sign-in required (auth disabled)

**Remote Access via Tailscale**:
- `http://<tailscale-ip>:3000` — Open WebUI chat interface
- `http://<tailscale-ip>:11434` — Ollama API (direct)

**Logs**:
```bash
# View container logs
tail -f /tmp/open-webui.log
tail -f /tmp/open-webui.err

# Check container status
podman ps -a --filter name=open-webui
```

**Manual Container Management**:
```bash
# Stop Open WebUI
podman stop open-webui

# Start Open WebUI manually
podman start open-webui

# Restart with latest image
podman stop open-webui && podman rm open-webui
podman pull ghcr.io/open-webui/open-webui:main
podman run --name open-webui --rm -p 3000:8080 \
  -v open-webui:/app/backend/data \
  -e OLLAMA_BASE_URL=http://host.containers.internal:11434 \
  -e WEBUI_AUTH=false \
  ghcr.io/open-webui/open-webui:main
```

**Testing**:
- [ ] Container starts automatically after login
- [ ] `http://localhost:3000` loads the chat interface
- [ ] Can select and chat with Ollama models
- [ ] Accessible via Tailscale: `http://<tailscale-ip>:3000`
- [ ] Data persists across container restarts (named volume)

---

## Qwen3-TTS Server (Power Profile Only)

**Status**: Managed via nix-darwin LaunchAgent — **Power profile only**

A local text-to-speech FastAPI server running on port 8765, started automatically at login. Accessible via localhost and Tailscale.

For full documentation (prerequisites, setup, troubleshooting), see the dedicated guide:

- **[Qwen3-TTS Server Guide](qwen3-tts.md)**

---

## Whisper STT Server (Power Profile Only)

**Status**: Managed via nix-darwin LaunchAgent — **Power profile only**

A local speech-to-text FastAPI server running on port 8766 using **mlx-whisper** (Apple MLX framework, 2-3x faster than whisper.cpp on M3 Max). Started automatically at login. Accessible via localhost and Tailscale.

Exposes an OpenAI-compatible `/v1/audio/transcriptions` endpoint for audio file transcription using the `large-v3-turbo` model.

For full documentation (prerequisites, setup, troubleshooting), see the dedicated guide:

- **[Whisper STT Server Guide](whisper-stt.md)**

---

## Related Documentation

- [Main Apps Index](../README.md)
- [Mac App Store Requirements](../mac-app-store-requirements.md)
- [Development Apps](../dev/)
