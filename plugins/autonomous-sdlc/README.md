# Autonomous SDLC Codex Plugin

## cmux Progress

Codex SDLC skills use `scripts/codex-sdlc-bridge.sh` as their progress API.
The bridge always appends a local log entry to `${CODEX_SDLC_LOG_DIR:-/tmp}/codex-sdlc.log`
and forwards to `~/.claude/hooks/cmux-bridge.sh` only when `CMUX_SOCKET_PATH`
is set. This keeps skill workflows correct outside cmux while enabling rich
sidebar state inside cmux.

Supported subcommands:

- `status <key> <text> [--icon name] [--color #hex]`
- `progress <0.0-1.0> [--label text]`
- `log <level> <message> [--source name]`
- `notify <title> <body>`
- `telegram <title> <body>`
- `clear [key]`

Long-running skills should emit deterministic phase updates from the main
Codex agent. Worker agents must not update shared sidebar or progress state.
