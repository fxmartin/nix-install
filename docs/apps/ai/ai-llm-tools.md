# ABOUTME: AI and LLM desktop applications configuration guide
# ABOUTME: Covers Claude Desktop, ChatGPT Desktop, Perplexity, Ollama (CLI), and Open WebUI

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

## Privacy Filter (Local PII Redaction)

**Status**: Always-on LaunchAgent on `127.0.0.1:7790` — Epic-09, branch `claude/add-openai-privacy-filter-EOYR7`, tracker [#303](https://github.com/fxmartin/nix-install/issues/303).

**What it is**: A native MLX port of OpenAI's open-weight Privacy Filter (`OpenMed/privacy-filter-mlx`) wrapped by the [`openmed`](https://pypi.org/project/openmed/) FastAPI service. Runs entirely on Apple Silicon — PII never leaves the host.

**Architecture**:
- `darwin/privacy-filter.nix` — LaunchAgent runs `uvicorn openmed.service.app:app` on `127.0.0.1:7790` (never bound to `0.0.0.0` or Tailscale; PII is by definition sensitive)
- `home-manager/modules/privacy-filter.nix` — provisions a uv venv at `~/.local/share/privacy-filter/venv`, pins `openmed[mlx,service]==1.2.0` + `mlx-lm==0.21.0`, pre-pulls HF weights
- Shell helpers `redact`, `redact-clip`, `redact-spans` defined in `home-manager/modules/shell.nix`

**Profile policy**:

| Profile | Variant | Cache | Steady-state RSS budget |
|---|---|---|---|
| Power (M3 Max) | `OpenMed/privacy-filter-mlx` (BF16) | ~3 GB | ≤ 4 GB |
| Standard (Air) | `OpenMed/privacy-filter-mlx-8bit` | ~1.4 GB | ≤ 2 GB |
| AI-Assistant | `OpenMed/privacy-filter-mlx-8bit` | ~1.4 GB | ≤ 2 GB |

**PII categories** (BIOES + Viterbi over 55 span classes; see [model card](https://cdn.openai.com/pdf/c66281ed-b638-456a-8ce1-97e9f5264a90/OpenAI-Privacy-Filter-Model-Card.pdf)):
names, addresses, emails, phone numbers, URLs, dates, account numbers, secrets (API keys / passwords), and finer-grained subclasses thereof.

**HTTP endpoints**:
- `GET /health` — liveness probe
- `POST /pii/extract` — `{text}` → `{entities:[{label,word,start,end}]}`
- `POST /pii/deidentify` — `{text, method:"mask"|"replace"}` → redacted text

**Typical workflows**:

```bash
# 1. Inline redaction
echo "Email me at fx@example.com or call 555-1234" | redact

# 2. Clipboard round-trip (the "paste safely into Claude/ChatGPT" path)
#    Copy text in any app → run → paste cleaned text
redact-clip

# 3. Inspect what would be masked, without redacting
pbpaste | redact-spans

# 4. Direct HTTP
curl -s -X POST http://127.0.0.1:7790/pii/deidentify \
  -H 'content-type: application/json' \
  -d '{"text":"Email me at fx@example.com","method":"mask"}' | jq .
```

**Performance** (per upstream MLX port benchmarks):
- ~14 ms per ~10-token input on M-series GPU after warmup
- 8-bit variant ~1.7× faster than BF16
- First request after boot triggers MLX model load (~1–3 s); subsequent requests are warm

**Auto-update**: Disabled by design. The model variant + `openmed` + `mlx-lm` versions are pinned in `home-manager/modules/privacy-filter.nix`. Updates flow only through `rebuild` / `update`.

**License**: Apache 2.0 (both upstream `openai/privacy-filter` and the OpenMed MLX wrapper).

**Verification**:
- [ ] `curl 127.0.0.1:7790/health` returns 200 within 30 s of login
- [ ] `echo "Email me at fx@example.com" | redact` prints redacted text
- [ ] `audit-launchagents` confirms steady-state RSS within budget
- [ ] HF cache size visible in weekly maintenance digest under `privacy_filter` row

**Known follow-ups** (tracked in [#302](https://github.com/fxmartin/nix-install/issues/302)):
- `OPENMED_PII_MODEL` env var name is a best-guess from convention; verify against `openmed/service/app.py` after first boot
- `/pii/deidentify` response field parsed as `.redacted // .text`; adjust if upstream uses a different field name

---

## Related Documentation

- [Main Apps Index](../README.md)
- [Mac App Store Requirements](../mac-app-store-requirements.md)
- [Development Apps](../dev/)
