# ABOUTME: Python development tools post-installation configuration guide
# ABOUTME: Covers uv package manager, ruff linter/formatter, Python 3.12 setup, and virtual environment management

### Python and Development Tools

**Status**: Installed via Nix packages (Story 02.2-004)

**Installed Tools**:
- **Python 3.12**: Primary Python interpreter
- **uv**: Fast Python package installer and resolver (replaces pip, pip-tools, virtualenv)
- **ruff**: Extremely fast Python linter and formatter (replaces flake8, isort, pyupgrade)
- **black**: Python code formatter
- **isort**: Import statement organizer
- **mypy**: Static type checker for Python
- **pylint**: Comprehensive Python linter

**No Configuration Required**:
These tools are installed globally and automatically available in your PATH. They require no post-install configuration.

**Verification**:

```bash
# Check Python version
python --version
# Expected: Python 3.12.x

# Verify Python path (should be from Nix)
which python
# Expected: /nix/store/.../bin/python

# Check uv
uv --version
# Expected: uv x.y.z

# Check development tools
ruff --version
black --version
isort --version
mypy --version
pylint --version
```

**Creating a New Python Project**:

Using **uv** (recommended):
```bash
# Initialize a new project
uv init my-project
cd my-project

# Add dependencies
uv add requests httpx

# Run Python scripts
uv run python script.py

# Run tests
uv run pytest
```

Traditional approach:
```bash
# Create virtual environment
python -m venv .venv
source .venv/bin/activate

# Install dependencies
pip install requests
```

**Tool Usage Examples**:

1. **Ruff** (Linting and Formatting):
   ```bash
   # Lint your code
   ruff check .

   # Format your code
   ruff format .

   # Fix issues automatically
   ruff check --fix .
   ```

2. **Black** (Code Formatting):
   ```bash
   # Format a file
   black script.py

   # Format entire project
   black .

   # Check formatting without modifying
   black --check .
   ```

3. **isort** (Import Sorting):
   ```bash
   # Sort imports in a file
   isort script.py

   # Sort all imports
   isort .
   ```

4. **mypy** (Type Checking):
   ```bash
   # Type check your code
   mypy script.py

   # Check entire project
   mypy .
   ```

5. **pylint** (Comprehensive Linting):
   ```bash
   # Lint a file
   pylint script.py

   # Lint entire project
   pylint src/
   ```

**Integration with Editors**:

These tools integrate with VSCode and Zed:

- **VSCode**: Extensions available for ruff, black, mypy, pylint
- **Zed**: Built-in support for ruff, black, and other formatters

**uv vs pip**:

We use **uv** instead of pip because:
- ✅ 10-100× faster than pip
- ✅ Built-in virtualenv management
- ✅ Better dependency resolution
- ✅ Compatible with pip requirements.txt
- ✅ No need for pip-tools (compile/sync)

**Update Philosophy**:
- ✅ All tools updated ONLY via `rebuild` or `update` commands
- ✅ Versions controlled by flake.lock (reproducible)
- ⚠️ Do NOT use `pip install --upgrade` or `brew upgrade` for these tools
- ✅ Use nix-darwin for system-wide tool management

**Testing**:
- [ ] Python 3.12 installed and accessible
- [ ] `which python` shows /nix/store path
- [ ] uv works and can create projects
- [ ] All dev tools (ruff, black, isort, mypy, pylint) work
- [ ] Can create a test project with `uv init`
- [ ] Tools integrate with VSCode/Zed

**Known Issues**:
- **Tool not found**: Re-run `darwin-rebuild switch` to ensure environment is updated
- **Wrong Python version**: Verify `which python` points to Nix path (not system Python)

**Resources**:
- uv Documentation: https://docs.astral.sh/uv/
- ruff Documentation: https://docs.astral.sh/ruff/
- black Documentation: https://black.readthedocs.io/
- mypy Documentation: https://mypy.readthedocs.io/

---


---

## Related Documentation

- [Main Apps Index](../README.md)
- [VS Code Configuration](./vscode.md)
- [Zed Editor Configuration](./zed-editor.md)
- [Podman Configuration](./podman.md)
