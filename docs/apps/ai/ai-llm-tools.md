# ABOUTME: AI and LLM desktop applications configuration guide
# ABOUTME: Covers Claude Desktop, ChatGPT Desktop, Ollama (CLI), OpenCode's local model, and Open WebUI

# AI & LLM Tools

## Claude Desktop

**Status**: Installed via Homebrew cask `claude` (Story 02.1-001)

**First Launch**:
1. Launch Claude Desktop from Spotlight
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
- [ ] Accessible from Spotlight
- [ ] Check for auto-update setting in preferences

---

## ChatGPT Desktop

**Status**: Installed via Homebrew cask `chatgpt` (Story 02.1-001)

**First Launch**:
1. Launch ChatGPT Desktop from Spotlight
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
- [ ] Accessible from Spotlight
- [ ] Check for auto-update setting in preferences

---


## Ollama (CLI + Optional LaunchAgent)

**Status**: Installed via Homebrew formula `ollama` (in Nix system PATH) — **CLI only, no GUI app**

The Ollama GUI app (`ollama-app` cask) has been removed to eliminate the port conflict where two Ollama servers competed for port 11434. This repo also disables Homebrew's `homebrew.mxcl.ollama` LaunchAgent during rebuilds so the formula does not auto-start a background daemon.

**Daemon Management**: owned by the **Local AI menubar app**, not this repo.
The app starts, stops, and crash-recovers `ollama serve` as a supervised child
process — see [local-ai-menubar](local-ai-menubar.md).

- No Ollama daemon is ever auto-started by a rebuild, and no always-on
  LaunchAgent exists. A rebuild that killed or resurrected the server would
  fight the app's supervision (its Stop button could not be honoured, and its
  crash detection would see phantom restarts). `tests/flake_ollama_activation.bats`
  pins this.
- Homebrew LaunchAgent `homebrew.mxcl.ollama` is unloaded and disabled by activation
- Manual control without the app: `start-ollama` and `stop-ollama`
- `OLLAMA_HOST` defaults to loopback via `environment.variables`; the app
  overrides it per-launch when its "Expose Ollama to containers" setting is on
- OLLAMA_ORIGINS permits only local browser clients; remote access requires an authenticated proxy and explicit ACL

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
- Models are pulled on demand from the Local AI menubar app's search; a `darwin-rebuild` never downloads models

**Web Interface**: Use **Open WebUI** (see below) for a browser-based chat interface.

---

## OpenCode → Local Ollama Model (Power profile)

**Status**: On the Power profile, OpenCode defaults to a local model served by Ollama — coding sessions never leave the machine.

**How it is wired**:
- `home-manager/modules/claude-code.nix` writes an `ollama` provider into `~/.config/opencode/opencode.json`, using `@ai-sdk/openai-compatible` against `http://127.0.0.1:11434/v1` (loopback only, matching the daemon's bind)
- The default model is `ollama/qwen3.6-coding:opencode` — set **only** on Power. Standard and AI-Assistant get the provider definition but keep their own default, since the 21GB model needs the M3 Max's 48GB of unified memory
- Do not hand-edit `~/.config/opencode/opencode.json`; activation rewrites it on every rebuild

**Why a derived model** (`config/ollama/qwen3.6-coding.Modelfile`):

Qwen publishes recommended sampling parameters for the Qwen3.6 family, but Ollama's
OpenAI-compatible endpoint can only express `temperature` and `top_p`. The remaining
parameters must be baked into a model of their own. A rebuild no longer builds it —
create it by hand once, after pulling the base model from the menubar app:

```bash
ollama create qwen3.6-coding:opencode -f config/ollama/qwen3.6-coding.Modelfile
```


| Parameter | Value | Why |
|-----------|-------|-----|
| `repeat_penalty` | 1.0 | **The important one.** Ollama defaults to 1.1, penalising the repetition source code is made of (closing braces, repeated identifiers, boilerplate) |
| `top_k` | 20 | Qwen3.6 recommendation (Ollama default is 40) |
| `min_p` | 0.0 | Disabled, per Qwen |
| `num_ctx` | 48000 | Repository-level reasoning; Ollama's default truncates tool-call chains |
| `temperature` / `top_p` | 0.6 / 0.95 | Qwen recommendation — **also** pinned in `opencode.json`, because absent explicit config OpenCode sends its own Qwen default of 0.55, which would override the model's own value |

`ollama create` reuses the base model's blobs, so the derived model costs a manifest
and a small parameter layer — not a second 21GB copy.

**Context window**: `OLLAMA_CONTEXT_LENGTH` is set to 48000 on Power (8192 elsewhere) via
`environment.variables` in `darwin/maintenance.nix`, so any Ollama server inherits it —
including the one the menubar app supervises. Override with `ollamaContextLength` in
`user-config.nix`. A larger window grows the KV cache — watch memory pressure if you raise it.

**Verification**:
```bash
ollama ps                              # expect 100% GPU, CONTEXT 48000
ollama show qwen3.6-coding:opencode    # confirm the Parameters block
opencode                               # no --model flag needed on Power
```

**Not portable from llama.cpp setups**: speculative decoding (`--spec-type draft-mtp`) is not
exposed by Ollama, `--tensor-split` is meaningless on unified memory, flash attention is
automatic, and `--host 0.0.0.0` must **never** be copied — Ollama has no authentication.

---

## MLX-LM (Apple-Native Runtime)

**Status**: MLX-LM 0.21.0 is provisioned on Apple Silicon by Home Manager in an isolated uv environment at `~/.local/share/mlx-lm/venv`.

The supported local inference stack is deliberately limited to Ollama and MLX-LM. Home Manager exposes these MLX-LM commands through `~/.local/bin`:

- `mlx_lm.generate`
- `mlx_lm.chat`
- `mlx_lm.server`
- `mlx_lm.convert`
- `mlx_lm.manage`

**Verification**:

```bash
echo "$MLX_LM_VENV"
command -v mlx_lm.generate
command -v mlx_lm.chat
mlx_lm.generate --help
```

---

## Privacy Filter (Local PII Redaction)

**Status**: Always-on LaunchAgent on `127.0.0.1:7790` — Epic-09, branch `claude/add-openai-privacy-filter-EOYR7`, tracker [#303](https://github.com/fxmartin/nix-install/issues/303).

**What it is**: The [`openmed`](https://pypi.org/project/openmed/) FastAPI PII service running locally with registry-backed OpenMed PII models. OpenMed uses MLX when possible and falls back to its Hugging Face/PyTorch path when needed; PII never leaves the host except for one-time model downloads from Hugging Face.

**Architecture**:
- `darwin/privacy-filter.nix` — LaunchAgent runs `uvicorn openmed.service.app:app` on `127.0.0.1:7790` (never bound to `0.0.0.0` or Tailscale; PII is by definition sensitive)
- `home-manager/modules/privacy-filter.nix` — provisions a uv venv at `~/.local/share/privacy-filter/venv`, pins `openmed[mlx,service]==1.2.0`, `mlx-lm==0.21.0`, and `torch==2.11.0`, pre-pulls HF weights
- Shell helpers `redact`, `redact-clip`, `redact-spans` defined in `home-manager/modules/shell.nix`

**Profile policy**:

| Profile | Variant | Cache | Steady-state RSS budget |
|---|---|---|---|
| Power (M3 Max) | `OpenMed/OpenMed-PII-SuperClinical-Large-434M-v1` | larger clinical PII model | ≤ 4 GB |
| Standard (Air) | `OpenMed/OpenMed-PII-SuperClinical-Small-44M-v1` | small clinical PII model | ≤ 2 GB |
| AI-Assistant | `OpenMed/OpenMed-PII-SuperClinical-Small-44M-v1` | small clinical PII model | ≤ 2 GB |

**PII categories**:
names, addresses, emails, phone numbers, URLs, dates, account numbers, secrets (API keys / passwords), and finer-grained subclasses thereof.

**HTTP endpoints**:
- `GET /health` — liveness probe
- `POST /pii/extract` — `{text, model_name}` → `{entities:[{label,text,start,end}]}`
- `POST /pii/deidentify` — `{text, method:"mask"|"replace", model_name}` → `{deidentified_text, pii_entities, ...}`

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

**Performance**:
- First request after boot may download and load/convert the selected model; subsequent requests are warm
- Power uses a larger model for quality; Standard and AI-Assistant use the smaller model for lower memory use

**Auto-update**: Disabled by design. The model variant + `openmed` + `mlx-lm` versions are pinned in `home-manager/modules/privacy-filter.nix`. Updates flow only through `rebuild` / `update`.

**License**: Apache 2.0 (both upstream `openai/privacy-filter` and the OpenMed MLX wrapper).

**Verification**:
- [ ] `curl 127.0.0.1:7790/health` returns 200 within 30 s of login
- [ ] `echo "Email me at fx@example.com" | redact` prints redacted text
- [ ] `audit-launchagents` confirms steady-state RSS within budget
- [ ] HF cache size visible in weekly maintenance digest under `privacy_filter` row

**Runtime notes**:
- OpenMed 1.2.0 does not read `OPENMED_PII_MODEL`; shell helpers pass `model_name` explicitly
- `/pii/deidentify` returns `deidentified_text`; shell helpers parse that field first

---

## Related Documentation

- [Main Apps Index](../README.md)
- [Mac App Store Requirements](../mac-app-store-requirements.md)
- [Development Apps](../dev/)
