# ABOUTME: Documents the rationalised interactive and remote monitoring stack
# ABOUTME: Covers btop, iStat Menus, Beszel, and the macmon telemetry backend

# System Monitoring

The repository deliberately keeps one tool for each monitoring role:

| Role | Tool | Manager |
|---|---|---|
| Terminal diagnostics | btop | Home Manager |
| Native menu-bar overview | iStat Menus | Homebrew cask |
| Remote history and alerts | Beszel agent | nixpkgs/nix-darwin |
| Apple Silicon metrics backend | macmon | nixpkgs/nix-darwin |

`gotop` and `mactop` are intentionally not installed. Their interactive
features overlap with btop and iStat Menus. macmon remains installed only
because the health API uses its JSON output for cached Apple Silicon metrics.

## Data flow

```text
macmon -> health-api /metrics -> vitals sampler / health checks
                              -> Beszel-compatible telemetry consumers
```

The health API runs macmon on a bounded background interval and serves cached
results. Requests never start their own macmon subprocess.

## btop

btop is the default terminal monitor for live CPU, memory, process, disk, and
network diagnostics. Home Manager owns both the package and its Catppuccin
configuration.

```sh
btop
```

Key controls:

- `q`: quit
- `1`–`4`: switch panels
- `f`: filter processes
- `k`: terminate the selected process
- `m`: change process sorting

Configuration is generated at `~/.config/btop/btop.conf`.

## iStat Menus

iStat Menus provides the always-visible native macOS overview. It requires a
license or trial and is installed as the `istat-menus` Homebrew cask.

After installation:

1. Launch iStat Menus and activate the license or trial.
2. Import `config/istat-menus/iStat Menus Settings.ismp7` if desired.
3. Disable automatic update checks so upgrades remain controlled by the repo.
4. Grant requested macOS permissions for the sensors you enable.

See [Licensed Applications](../../licensed-apps.md#istat-menus) for activation
and troubleshooting details.

## Beszel

The Beszel agent supplies remote history and alerting. nix-darwin manages its
LaunchAgent and runs the locked nixpkgs binary at low scheduling priority.

Machine-local configuration lives at:

```text
~/.config/beszel/beszel-agent.env
```

Set the `KEY` supplied by the Beszel hub before expecting the agent to connect.
The agent listens on port `45876`.

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

- [ ] `command -v btop` resolves through the Home Manager user profile.
- [ ] `/Applications/iStat Menus.app` exists and the menu-bar items appear.
- [ ] `gotop` and `mactop` are not found in `PATH`.
- [ ] `/metrics` returns cached CPU, memory, thermal, and process data.
- [ ] The Beszel agent is loaded and connected when a hub key is configured.

## Troubleshooting

If btop is missing, rebuild the active profile and start a new shell.

If `/metrics` reports that macmon is unavailable, confirm the system profile
contains `/run/current-system/sw/bin/macmon` and inspect
`/tmp/health-api.err`.

If Beszel is disconnected, verify its key file, LaunchAgent status, firewall,
and hub reachability. Do not reinstall an additional local monitor as a
workaround; it will not repair the telemetry pipeline.
