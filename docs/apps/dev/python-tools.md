# ABOUTME: Python development tooling and uv-first project workflow guide
# ABOUTME: Documents the minimal global Ruff and Pyright baseline

## Python Development Tools

**Status**: Python 3.12, uv, Ruff, and Pyright are installed via Nix.

The global baseline has intentionally narrow responsibilities:

- **Python 3.12**: Runtime for scripts and project environments.
- **uv**: Project creation, dependency management, locking, and command execution.
- **Ruff**: Linting, import sorting, automatic fixes, and formatting.
- **Pyright**: Static type checking and Zed language-server integration.

Projects that require different or additional tools declare them in their own `pyproject.toml` and uv environment rather than expanding the global profile.

### Verification

```bash
python --version
uv --version
ruff --version
pyright --version
```

### Create a Project

```bash
uv init my-project
cd my-project
uv add requests httpx
uv run python main.py
uv run pytest
```

### Quality Checks

```bash
# Lint and validate import order
ruff check .

# Apply safe lint and import fixes
ruff check . --fix

# Format or check formatting
ruff format .
ruff format . --check

# Type-check the project
pyright
```

The shell aliases `lint`, `lintfix`, `fmt`, `fmtcheck`, `typecheck`, `qa`, and `fix` map to this baseline.

### Update Policy

- Global tool versions update only through this repository's `update` and `rebuild` flow.
- Project dependencies and exceptions belong in the project's uv lockfile.
- Avoid installing project tooling into the system Python environment.

### Testing Checklist

- [ ] Python 3.12, uv, Ruff, and Pyright resolve from the active Nix profile
- [ ] uv can initialise and sync a project
- [ ] Ruff can lint, sort imports, and format the project
- [ ] Pyright can type-check the project and serve Zed

### Resources

- [uv documentation](https://docs.astral.sh/uv/)
- [Ruff documentation](https://docs.astral.sh/ruff/)
- [Pyright documentation](https://microsoft.github.io/pyright/)

---

## Related Documentation

- [Main Apps Index](../README.md)
- [Zed Editor Configuration](./zed-editor.md)
- [Podman Configuration](./podman.md)
