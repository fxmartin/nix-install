# ABOUTME: Qwen3-TTS local text-to-speech server documentation
# ABOUTME: Covers LaunchAgent setup, health checks, prerequisites, and troubleshooting (Power profile only)

# Qwen3-TTS Server

**Status**: Managed via nix-darwin LaunchAgent (`darwin/tts-serve.nix`) — **Power profile only**

## Overview

Qwen3-TTS is a local text-to-speech server running as a FastAPI/uvicorn service. It starts automatically at login on Power profile machines and is accessible via `localhost:8765` and over Tailscale (`0.0.0.0` binding).

| Property | Value |
|----------|-------|
| **Profile** | Power only (MacBook Pro M3 Max) |
| **Port** | 8765 |
| **Binding** | `0.0.0.0` (localhost + Tailscale) |
| **LaunchAgent label** | `com.qwen3tts.server` |
| **Project directory** | `~/Projects/qwen3-tts` |
| **Logs (stdout)** | `/tmp/qwen3-tts-serve.log` |
| **Logs (stderr)** | `/tmp/qwen3-tts-serve.err` |

---

## Prerequisites

The LaunchAgent expects the following to exist **before** `darwin-rebuild`:

1. **Project directory**: `~/Projects/qwen3-tts`
2. **Python virtual environment**: `~/Projects/qwen3-tts/.venv` (with uvicorn, FastAPI, and model dependencies installed)
3. **Server entrypoint**: `~/Projects/qwen3-tts/server.py` (FastAPI app exported as `app`)

### Setting Up the Project

```bash
# Clone or create the project
mkdir -p ~/Projects && cd ~/Projects
git clone <your-qwen3-tts-repo> qwen3-tts   # or create from scratch

# Create virtual environment and install dependencies
cd ~/Projects/qwen3-tts
python3 -m venv .venv
source .venv/bin/activate
pip install fastapi uvicorn   # plus model-specific dependencies
```

---

## LaunchAgent Configuration

Defined in [`darwin/tts-serve.nix`](../../../darwin/tts-serve.nix):

- **Runs at login** (`RunAtLoad = true`)
- **Auto-restarts on crash** (`KeepAlive.SuccessfulExit = false`)
- **10-second cooldown** between restarts (`ThrottleInterval = 10`)
- **Environment**: `HOME` set to user home, `PATH` includes `/opt/homebrew/bin`

The agent executes:
```bash
cd ~/Projects/qwen3-tts && source .venv/bin/activate && exec uvicorn server:app --host 0.0.0.0 --port 8765
```

---

## Health Checks

The TTS server is monitored by two health check systems:

### `health-check` CLI (Check 12)

The `health-check` shell command verifies:
1. LaunchAgent is loaded (`com.qwen3tts.server` in `launchctl list`)
2. Server responds on `http://localhost:8765/health`
3. Model status parsed from the `/health` JSON response

### Health HTTP API

The `health-api.py` service also checks the TTS server and includes its status in the system-wide health JSON endpoint (used for remote monitoring via Tailscale).

### Health Endpoint Format

The server's `/health` endpoint should return JSON:
```json
{
  "models": {
    "model-name": { "status": "ok" },
    "model-name-2": { "status": "ok" }
  }
}
```

---

## Common Commands

```bash
# Check if the LaunchAgent is loaded
launchctl list | grep qwen3tts

# Start the server manually
launchctl start com.qwen3tts.server

# Stop the server
launchctl stop com.qwen3tts.server

# Restart the server
launchctl stop com.qwen3tts.server && launchctl start com.qwen3tts.server

# Test the health endpoint
curl -s http://localhost:8765/health | python3 -m json.tool

# View logs
tail -f /tmp/qwen3-tts-serve.log
tail -f /tmp/qwen3-tts-serve.err
```

---

## Troubleshooting

### Server not responding on port 8765

1. Check if the LaunchAgent is loaded:
   ```bash
   launchctl list | grep qwen3tts
   ```
2. Check error logs:
   ```bash
   cat /tmp/qwen3-tts-serve.err
   ```
3. Verify the project directory exists:
   ```bash
   ls ~/Projects/qwen3-tts/server.py
   ls ~/Projects/qwen3-tts/.venv/bin/uvicorn
   ```
4. Try starting manually:
   ```bash
   cd ~/Projects/qwen3-tts && source .venv/bin/activate && uvicorn server:app --host 0.0.0.0 --port 8765
   ```

### Server in restart loop

Check for missing dependencies or import errors:
```bash
cat /tmp/qwen3-tts-serve.err
```
The 10-second `ThrottleInterval` prevents rapid restart loops.

### Port 8765 already in use

```bash
lsof -i :8765
# Kill the conflicting process if needed
kill <PID>
launchctl start com.qwen3tts.server
```

### Health check shows "degraded"

One or more models failed to load. Restart the server to reload:
```bash
launchctl stop com.qwen3tts.server && launchctl start com.qwen3tts.server
```

---

## Network Access

- **Localhost**: `http://localhost:8765`
- **Tailscale**: `http://<tailscale-ip>:8765` (bound to `0.0.0.0`)
- **Other devices on Tailscale** can reach the TTS API directly

---

## Related Documentation

- [AI & LLM Tools Overview](ai-llm-tools.md) - Claude Desktop, ChatGPT, Perplexity, Ollama
- [`darwin/tts-serve.nix`](../../../darwin/tts-serve.nix) - LaunchAgent definition
- [Main Apps Index](../README.md)
