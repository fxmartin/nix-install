# Code Improvements

## Declarative Claude Codex Plugin Install

`nix-install` now treats the OpenAI Codex Claude Code plugin as part of the managed MacBook setup rather than a manual Claude Code action.

Implementation notes:

- `config/claude-code-config/settings.json` remains the durable Claude settings source and declares `codex@openai-codex` plus the `openai-codex` marketplace.
- `home-manager/modules/claude-code.nix` completes the runtime installation during Home Manager activation by checking Claude's plugin marketplace and installed-plugin registry before running `claude plugin marketplace add` or `claude plugin install`.
- `darwin/configuration.nix` installs `nodejs` for every profile because the Codex plugin hooks run through Node, while the heavier TypeScript and JavaScript language-server stack remains excluded from `ai-assistant`.

Verification after activation:

```bash
claude plugin marketplace list
claude plugin list --json
codex --version
node --version
```

Expected result: `openai-codex` is listed as a marketplace, `codex@openai-codex` is listed as an installed plugin, and `/codex:setup` is available in Claude Code.
