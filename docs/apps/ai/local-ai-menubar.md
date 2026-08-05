# ABOUTME: Local AI menubar app — install, Ollama ownership, and troubleshooting
# ABOUTME: The app supervises ollama serve; this repo deliberately does not

# Local AI Menubar

**Status**: Built from source during activation by
`home-manager/modules/local-ai-menubar.nix` — Power profile only (needs full
Xcode). Source: [fxmartin/local-ai-menubar-app](https://github.com/fxmartin/local-ai-menubar-app).

A SwiftUI `MenuBarExtra` control centre for the local Ollama stack: start/stop
the server, warm models into memory, watch RAM and which runner (MLX vs
llama.cpp) is serving, search and pull models MLX-first, benchmark tokens/s,
and launch Open WebUI in its Apple container.

## Who owns Ollama

**The app does.** This repo used to start `ollama serve` during activation, pull
a per-profile model list, and optionally run an always-on `ollama-serve`
LaunchAgent. All of that is gone, because it cannot coexist with an app that
supervises the same server:

- A `KeepAlive` LaunchAgent makes the app's Stop button impossible to honour —
  launchd resurrects the server the app just stopped.
- An activation `pkill` kills a server the app is supervising, which its crash
  detection reports as an unexpected exit.
- Rebuild-time model pulls duplicate what the app's search does on demand, and
  start a daemon behind the app's back to do it.

`tests/flake_ollama_activation.bats` fails if any of that returns.

What this repo still owns, and the app inherits:

| Setting | Where | Note |
|---------|-------|------|
| `OLLAMA_HOST` (loopback) | `darwin/maintenance.nix` → `environment.variables` | The app overrides it per-launch when its "Expose Ollama to containers" setting is on — so Open WebUI's container can reach the host gateway |
| `OLLAMA_KEEP_ALIVE`, `OLLAMA_MAX_LOADED_MODELS`, `OLLAMA_NUM_PARALLEL`, `OLLAMA_CONTEXT_LENGTH` | same | Defaults for any server; the app sends `keep_alive` per request, which wins for models it warms |
| `ollama-pressure-guard` LaunchAgent | `darwin/maintenance.nix` | Unloads models under swap pressure — the app's polling reflects that within a tick |
| `ollama-lru` (opt-in) | `darwin/maintenance.nix` | Monthly prune of idle models; protected families listed in `scripts/ollama-lru.sh` |
| The `ollama` CLI itself | `darwin/homebrew.nix` formula | `/opt/homebrew/bin/ollama` |

## How it is installed

The module searches `~/dev`, `~`, and `~/Documents` for a
`local-ai-menubar-app` checkout, then runs that repo's
`scripts/install-app.sh`, which builds the Release configuration with
`xcodebuild` and copies the bundle to `~/Applications`.

Why an activation build rather than a Nix derivation: the `.app` bundle's asset
catalog is compiled by `xcodebuild`, which cannot run in a Nix sandbox, and
`pkgs.swift` on Darwin is broken in the current nixpkgs pin. Same bargain as
`sdlc-controller.nix` and `mlx-lm.nix` — the artifact lives outside the Nix
store, so it is **not atomic and not rolled back by a generation switch**;
`rebuild` is what keeps it current.

Profiles without full Xcode (Standard, AI-Assistant) log a skip line rather than
failing — a missing optional app must never abort a rebuild.

## Verification

```bash
ls ~/Applications/LocalAIMenubar.app     # installed bundle
pgrep -x LocalAIMenubar                  # running
```

Then click the menubar icon: the dropdown should show the server state, and
the footer the detected Ollama version.

## Troubleshooting

**"no source checkout found"** — clone the app repo to `~/dev/local-ai-menubar-app`,
or one of the other searched locations, then `rebuild`.

**"full Xcode not available"** — expected on Standard and AI-Assistant. Install
Xcode from the App Store (Power profile does this via `homebrew.masApps`), then
`sudo xcodebuild -license accept` and `sudo xcodebuild -runFirstLaunch`.

**The app is ad-hoc signed**, so a network filter such as Little Snitch reports
"the program has been modified" after every rebuild — the checksum changes
because there is no stable signing identity. Accepting the modification is
correct; the alternative is signing with a stable identity.

**Ollama connections attributed to the app** — a filter shows
`LocalAIMenubar via ollama` reaching ollama.com. That is the supervised child
process making its own version/registry calls, not the app's own HTTP client
(which is allowlist-gated). Supervising a process is not sandboxing it.
