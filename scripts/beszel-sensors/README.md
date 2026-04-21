# Custom telemetry sensors (Story 08.4-002)

Small wrappers that fetch values from the local `health-api` `/metrics`
endpoint and print a single float to stdout. Designed to be consumed by
any time-series backend or log pipeline that can exec an external program.

## Available sensors

| Script | Output | Source |
|--------|--------|--------|
| `power.sh` | total system power in watts | `.power.total_watts` |
| `temp.sh` | hottest silicon temp in °C | `max(.thermal.cpu_temp_c, .thermal.gpu_temp_c)` |
| `temp_gpu.sh` | GPU temp alone | `.thermal.gpu_temp_c` |

All sensors print a single line on stdout (e.g. `23.4`) and exit 0
on success, or exit 1 with no stdout on failure. This makes them
safe to use in pipelines that want to distinguish missing data from
a legitimate zero reading.

## Design goals

- **Zero steady-state cost**: sensors are pull-based; they only run when
  their consumer polls them.
- **Reuse the 2s /metrics cache**: health-api already collects macmon
  data on a 2s TTL, so frequent sensor polls (sub-second) are cheap.
- **Silent-failure**: never print noise on error — callers can re-try
  without filtering stderr.

## Beszel integration — deferred

At time of writing, the upstream `beszel-agent` doesn't expose a generic
custom-metric plugin interface on macOS (it supports `EXTRA_FS` and
`SYS_SENSORS` for Linux lm-sensors). When Beszel adds a program-sensor
hook, wire the scripts via `darwin/monitoring.nix` by extending the
agent's `EnvironmentVariables` to point at this directory.

Until then these sensors work as standalone utilities — pipe them into
anything: Prometheus textfile collector, a cron job writing CSV, a tail
script shipping to InfluxDB, etc.
