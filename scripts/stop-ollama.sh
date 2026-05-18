#!/usr/bin/env bash
# ABOUTME: Stops the manually started Ollama server.
# ABOUTME: Complements start-ollama.sh and avoids login-service management.

set -euo pipefail

LAUNCH_LABEL="${OLLAMA_LAUNCH_LABEL:-org.nixos.ollama-manual}"

stopped=false

if /bin/launchctl print "gui/$UID/$LAUNCH_LABEL" >/dev/null 2>&1; then
  /bin/launchctl remove "$LAUNCH_LABEL"
  stopped=true
fi

if /usr/bin/pgrep -f "[o]llama serve" >/dev/null 2>&1; then
  /usr/bin/pkill -f "[o]llama serve"
  stopped=true
fi

if [[ "$stopped" == true ]]; then
  printf 'Stopped Ollama.\n'
else
  printf 'Ollama is not running.\n'
fi
