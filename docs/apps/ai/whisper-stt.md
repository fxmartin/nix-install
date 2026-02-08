# ABOUTME: Whisper STT local speech-to-text server documentation
# ABOUTME: Covers LaunchAgent setup, health checks, prerequisites, and troubleshooting (Power profile only)

# Whisper STT Server

**Status**: Managed via nix-darwin LaunchAgent (`darwin/stt-serve.nix`) — **Power profile only**

## Overview

Whisper STT is a local speech-to-text server running as a FastAPI/uvicorn service using **mlx-whisper** (Apple's MLX framework implementation of OpenAI Whisper). It starts automatically at login on Power profile machines and is accessible via `localhost:8766` and over Tailscale (`0.0.0.0` binding).

mlx-whisper leverages the MLX framework for native Metal acceleration on Apple Silicon. See [Benchmark Results](#benchmark-results) below for measured performance on M3 Max.

| Property | Value |
|----------|-------|
| **Profile** | Power only (MacBook Pro M3 Max) |
| **Port** | 8766 |
| **Binding** | `0.0.0.0` (localhost + Tailscale) |
| **LaunchAgent label** | `com.whisper-stt.server` |
| **Project directory** | `~/Projects/whisper-stt` |
| **Model** | `large-v3-turbo` (~1.5GB, near large-v3 accuracy at 4-5x speed) |
| **Logs (stdout)** | `/tmp/whisper-stt-serve.log` |
| **Logs (stderr)** | `/tmp/whisper-stt-serve.err` |

---

## Prerequisites

The LaunchAgent expects the following to exist **before** `darwin-rebuild`:

1. **Project directory**: `~/Projects/whisper-stt`
2. **Python virtual environment**: `~/Projects/whisper-stt/.venv` (with uvicorn, FastAPI, mlx-whisper installed)
3. **Server entrypoint**: `~/Projects/whisper-stt/server.py` (FastAPI app exported as `app`)
4. **ffmpeg**: Installed via Nix (`/run/current-system/sw/bin/ffmpeg`) for audio format conversion

### Setting Up the Project

```bash
# Create the project
mkdir -p ~/Projects && cd ~/Projects
git clone <your-whisper-stt-repo> whisper-stt   # or create from scratch

# Create virtual environment and install dependencies
cd ~/Projects/whisper-stt
uv venv .venv
uv pip install --python .venv/bin/python -e .   # installs from pyproject.toml
```

---

## LaunchAgent Configuration

Defined in [`darwin/stt-serve.nix`](../../../darwin/stt-serve.nix):

- **Runs at login** (`RunAtLoad = true`)
- **Auto-restarts on crash** (`KeepAlive.SuccessfulExit = false`)
- **10-second cooldown** between restarts (`ThrottleInterval = 10`)
- **Environment**: `HOME` set to user home, `PATH` includes Nix system path (for ffmpeg) and `/opt/homebrew/bin`

The agent executes:
```bash
cd ~/Projects/whisper-stt && source .venv/bin/activate && exec uvicorn server:app --host 0.0.0.0 --port 8766
```

---

## Health Checks

The STT server is monitored by two health check systems:

### `health-check` CLI (Check 13)

The `health-check` shell command verifies:
1. LaunchAgent is loaded (`com.whisper-stt.server` in `launchctl list`)
2. Server responds on `http://localhost:8766/health`
3. Model status parsed from the `/health` JSON response

### Health HTTP API

The `health-api.py` service also checks the STT server and includes its status in the system-wide health JSON endpoint (used for remote monitoring via Tailscale).

### Health Endpoint Format

The server's `/health` endpoint should return JSON:
```json
{
  "status": "ok",
  "model": "large-v3-turbo",
  "models": {
    "large-v3-turbo": { "status": "ok" }
  }
}
```

---

## API Usage

The server exposes an OpenAI-compatible transcription endpoint:

### Transcribe Audio

```bash
# Transcribe an audio file
curl -X POST http://localhost:8766/v1/audio/transcriptions \
  -F "file=@recording.wav" \
  -F "model=large-v3-turbo"

# Response:
# { "text": "Transcribed text here..." }
```

### Supported Audio Formats

Any format supported by ffmpeg: WAV, MP3, M4A, FLAC, OGG, WEBM, etc.

---

## Common Commands

```bash
# Check if the LaunchAgent is loaded
launchctl list | grep whisper-stt

# Start the server manually
launchctl start com.whisper-stt.server

# Stop the server
launchctl stop com.whisper-stt.server

# Restart the server
launchctl stop com.whisper-stt.server && launchctl start com.whisper-stt.server

# Test the health endpoint
curl -s http://localhost:8766/health | python3 -m json.tool

# Transcribe a file
curl -X POST http://localhost:8766/v1/audio/transcriptions -F "file=@audio.wav"

# View logs
tail -f /tmp/whisper-stt-serve.log
tail -f /tmp/whisper-stt-serve.err
```

---

## Troubleshooting

### Server not responding on port 8766

1. Check if the LaunchAgent is loaded:
   ```bash
   launchctl list | grep whisper-stt
   ```
2. Check error logs:
   ```bash
   cat /tmp/whisper-stt-serve.err
   ```
3. Verify the project directory exists:
   ```bash
   ls ~/Projects/whisper-stt/server.py
   ls ~/Projects/whisper-stt/.venv/bin/uvicorn
   ```
4. Try starting manually:
   ```bash
   cd ~/Projects/whisper-stt && source .venv/bin/activate && uvicorn server:app --host 0.0.0.0 --port 8766
   ```

### Server in restart loop

Check for missing dependencies or import errors:
```bash
cat /tmp/whisper-stt-serve.err
```
The 10-second `ThrottleInterval` prevents rapid restart loops.

### Port 8766 already in use

```bash
lsof -i :8766
# Kill the conflicting process if needed
kill <PID>
launchctl start com.whisper-stt.server
```

### Model load failure

The `large-v3-turbo` model (~1.5GB) is downloaded on first use. If the model fails to load:
1. Check disk space: `df -h ~`
2. Check error logs for download failures
3. Ensure internet connectivity for first model download
4. Try loading the model manually in Python:
   ```python
   import mlx_whisper
   mlx_whisper.transcribe("test.wav", path_or_hf_repo="mlx-community/whisper-large-v3-turbo")
   ```

### Health check shows "degraded"

The model failed to load. Restart the server to reload:
```bash
launchctl stop com.whisper-stt.server && launchctl start com.whisper-stt.server
```

---

## Network Access

- **Localhost**: `http://localhost:8766`
- **Tailscale**: `http://<tailscale-ip>:8766` (bound to `0.0.0.0`)
- **Other devices on Tailscale** can reach the STT API directly

---

## Benchmark Results

Tested on **MacBook Pro M3 Max** (2026-02-08) comparing local mlx-whisper against the OpenAI Whisper API (`whisper-1`). Test audio generated by the companion [Qwen3-TTS server](qwen3-tts.md).

### Performance

| Audio File | Duration | Local (mlx-whisper) | OpenAI API (whisper-1) | Local Speedup |
|------------|----------|--------------------|-----------------------|---------------|
| `preset-long-aiden.wav` | 30.5s | **1.00s** | 6.35s | **6.4x faster** |
| `design-british-newsreader.wav` | 9.0s | **0.65s** | 1.38s | **2.1x faster** |

**Real-time factor (RTF)** = processing time / audio duration:
- 30.5s audio: RTF = **0.033** (transcribes 30x faster than real-time)
- 9.0s audio: RTF = **0.072** (transcribes 14x faster than real-time)

### Accuracy

Both engines produced **identical transcriptions** on both test files (word-for-word match). The only difference was trivial punctuation (a period vs comma placement).

**Sample transcription** (30.5s clip):
> Artificial intelligence is transforming every aspect of our daily lives, from the way we communicate to how we work and create. Large language models can now write code, compose music, and engage in nuanced conversations. Meanwhile, text-to-speech technology has reached a point where synthesized voices are nearly indistinguishable from human speech, opening up new possibilities for accessibility, content creation, and human-computer interaction.

### Summary

| Metric | Local (mlx-whisper) | OpenAI API |
|--------|--------------------|--------------------|
| **Speed** | 2-6x faster | baseline |
| **Accuracy** | Identical | Identical |
| **Cost** | Free (local compute) | $0.006/min |
| **Privacy** | Audio stays on device | Sent to OpenAI servers |
| **Model** | `large-v3-turbo` (1.5GB) | `whisper-1` (hosted) |
| **Startup** | ~134s first run (model download), ~10s cached | N/A |
| **Latency** | <1s for most clips | Network-dependent |

### Test Commands

```bash
# Local mlx-whisper
time curl -s -X POST http://localhost:8766/v1/audio/transcriptions \
  -F "file=@audio.wav" -F "model=large-v3-turbo"

# OpenAI API (requires OPENAI_API_KEY)
time curl -s -X POST https://api.openai.com/v1/audio/transcriptions \
  -H "Authorization: Bearer $OPENAI_API_KEY" \
  -F "file=@audio.wav" -F "model=whisper-1"
```

---

## Related Documentation

- [AI & LLM Tools Overview](ai-llm-tools.md) - Claude Desktop, ChatGPT, Perplexity, Ollama
- [Qwen3-TTS Server](qwen3-tts.md) - Companion TTS service on port 8765
- [`darwin/stt-serve.nix`](../../../darwin/stt-serve.nix) - LaunchAgent definition
- [Main Apps Index](../README.md)
