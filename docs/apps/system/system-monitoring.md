# ABOUTME: Documents the rationalised interactive and remote monitoring stack
# ABOUTME: Covers mactop, Stats, Beszel, and the macmon telemetry backend

# System Monitoring

The repository deliberately keeps one tool for each monitoring role:

| Role | Tool | Manager |
|---|---|---|
| Terminal diagnostics | mactop | Nix (system packages) |
| Native menu-bar overview | Stats | Homebrew cask |
| Remote history and alerts | Beszel agent | nixpkgs/nix-darwin |
| Apple Silicon metrics backend | macmon | nixpkgs/nix-darwin |

`gotop` and `mactop` are intentionally not installed. Their interactive
features overlap with mactop and Stats. macmon remains installed only
because the health API uses its JSON output for cached Apple Silicon metrics.

## Data flow

```text
macmon -> health-api /metrics -> vitals sampler / health checks
                              -> Beszel-compatible telemetry consumers
```

The health API runs macmon on a bounded background interval and serves cached
results. Requests never start their own macmon subprocess.

## mactop

mactop is the terminal monitor for live Apple Silicon diagnostics: per-cluster
E/P CPU, GPU, ANE, power draw, and thermals. Nix owns the package (Power and
Standard profiles). It replaced btop in v2.3.0 — btop's generic Linux-style
view could not see Apple Silicon's cluster topology or power counters.

```sh
sudo mactop
```

`sudo` is required to read the SMC power and thermal counters.

Key controls:

- `q`: quit
- `l`: change layout
- `c`: change colour scheme
- `/`: search the process list
- `F9`: terminate the selected process

## Stats

Stats provides the always-visible native menu-bar overview. It is open source
(github.com/exelban/stats) and installed as the `stats` Homebrew cask — it
replaced the commercial iStat Menus in v2.11.0, removing a licence key from the
post-install path.

After installation:

1. Launch Stats and choose which modules appear in the menu bar.
2. Grant the macOS permissions requested for the sensors you enable.
3. The cask declares `auto_updates`, so Stats updates itself outside `rebuild`.

## Beszel

The Beszel agent supplies remote history and alerting. nix-darwin manages its
LaunchAgent and runs the locked nixpkgs binary at low scheduling priority.

Machine-local configuration lives at:

```text
~/.config/beszel/beszel-agent.env
```

Set the `KEY` supplied by the Beszel hub before expecting the agent to connect.
The agent listens on port `45876` on all interfaces (tailnet-reachable), so the
env file is created `chmod 600` (owner-only) — key confidentiality is the
compensating control until binding is scoped in a later epic.

Useful checks:

```sh
launchctl print gui/$(id -u)/org.nixos.beszel-agent
tail -f /tmp/beszel-agent.log
tail -f /tmp/beszel-agent.err
```

## macmon telemetry backend

macmon is infrastructure, not an operator-facing monitor. The health API calls
the Nix-managed binary at `/run/current-system/sw/bin/macmon`, parses one JSON
sample, and caches the normalized metrics.

Check the API rather than invoking macmon directly:

```sh
curl --fail --silent http://127.0.0.1:7780/metrics | jq .
health-check
```

Relevant services and scripts:

- `darwin/health-api.nix`
- `scripts/health-api.py`
- `scripts/vitals-sampler.sh`
- `darwin/monitoring.nix`

## Verification checklist

- [ ] `command -v mactop` resolves through the system profile.
- [ ] `/Applications/Stats.app` exists and the menu-bar items appear.
- [ ] `gotop` and `btop` are not found in `PATH`.
- [ ] `/metrics` returns cached CPU, memory, thermal, and process data.
- [ ] The Beszel agent is loaded and connected when a hub key is configured.

## Troubleshooting

If mactop is missing, rebuild the active profile and start a new shell.

If `/metrics` reports that macmon is unavailable, confirm the system profile
contains `/run/current-system/sw/bin/macmon` and inspect
`/tmp/health-api.err`.

If Beszel is disconnected, verify its key file, LaunchAgent status, firewall,
and hub reachability. Do not reinstall an additional local monitor as a
workaround; it will not repair the telemetry pipeline.
