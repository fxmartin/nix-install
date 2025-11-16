# ABOUTME: Podman container engine post-installation configuration guide
# ABOUTME: Covers VM setup, network configuration, volume management, and rootless container operations

### Podman and Container Tools

**Status**: Installed via Homebrew (Story 02.2-005)

**Installed Tools**:
- **Podman CLI**: Container engine (Docker alternative) - via Homebrew
- **podman-compose**: Docker Compose compatibility for Podman - via Homebrew
- **Podman Desktop**: GUI application for managing containers - via Homebrew cask

**Note**: All Podman tools installed via Homebrew (not Nix) for better GUI integration. Podman Desktop requires podman CLI in standard PATH, which Homebrew provides but Nix installations may not (GUI apps don't inherit shell PATH).

**✅ CRITICAL: Podman Machine Initialization Required**

Before running containers, you must initialize and start a Podman machine (VM):

```bash
# Initialize the default Podman machine with Docker compatibility (one-time setup)
# The --now flag starts the machine immediately after initialization
podman machine init --now --rootful=false

# If already initialized without --now, start manually:
# podman machine start

# Verify machine is running
podman machine list
# Expected: NAME        VM TYPE     CREATED      LAST UP          CPUS        MEMORY      DISK SIZE
#           podman-machine-default  qemu      X minutes ago  Currently running  2           2GiB        10GiB
```

**Important Flags Explained**:
- `--now`: Starts the machine immediately after initialization
- `--rootful=false`: Runs containers in rootless mode (better security, default behavior)

**If You See "Docker socket is not disguised correctly" Error**:
```bash
# Remove the misconfigured machine
podman machine stop
podman machine rm podman-machine-default

# Re-initialize with correct flags
podman machine init --now --rootful=false
```

**Why Machine Initialization is Needed**:
- Podman on macOS runs containers inside a lightweight Linux VM
- The VM provides the Linux kernel required for container execution
- First-time initialization creates the VM and configures networking
- This is a one-time setup per machine

**Verification**:

```bash
# Check Podman version
podman --version
# Expected: podman version 4.x.x or higher

# Check podman-compose version
podman-compose --version
# Expected: podman-compose version x.y.z

# Test container execution
podman run --rm hello-world
# Expected: "Hello from Docker!" message (Podman is Docker-compatible)

# Test with a more complex example
podman run --rm -it alpine:latest echo "Podman works!"
# Expected: "Podman works!" output
```

**Podman Desktop First Launch**:

1. Launch **Podman Desktop** from Applications folder or Spotlight
2. If prompted, allow Podman Desktop to manage machines
3. Desktop app will show machine status and running containers
4. No sign-in required (open source application)

**Podman Desktop Features**:
- Visual container management (start, stop, remove)
- Image management (pull, build, push)
- Pod management (Kubernetes-style pod support)
- Volume and network management
- Machine status and configuration
- Logs and shell access to running containers

**Basic Usage Examples**:

1. **Running a Container**:
   ```bash
   # Run a simple container
   podman run --rm -d --name nginx -p 8080:80 nginx:latest

   # Check running containers
   podman ps

   # Stop the container
   podman stop nginx
   ```

2. **Using podman-compose**:
   ```bash
   # Create docker-compose.yml (or compose.yaml)
   cat > docker-compose.yml <<EOF
   version: '3'
   services:
     web:
       image: nginx:latest
       ports:
         - "8080:80"
   EOF

   # Start services
   podman-compose up -d

   # Stop services
   podman-compose down
   ```

3. **Building Images**:
   ```bash
   # Create a Containerfile (or Dockerfile)
   cat > Containerfile <<EOF
   FROM alpine:latest
   RUN apk add --no-cache curl
   CMD ["curl", "--version"]
   EOF

   # Build the image
   podman build -t myimage:latest .

   # Run the built image
   podman run --rm myimage:latest
   ```

4. **Managing Machines**:
   ```bash
   # List machines
   podman machine list

   # Stop machine (when not needed)
   podman machine stop

   # Start machine again
   podman machine start

   # Remove machine (careful - deletes all containers/images!)
   podman machine rm podman-machine-default
   ```

**Podman vs Docker**:
- ✅ Rootless by default (better security)
- ✅ Daemonless architecture (no background daemon)
- ✅ Drop-in Docker CLI replacement (docker → podman)
- ✅ Fully Docker-compatible (can use Dockerfiles, docker-compose.yml)
- ✅ Built-in pod support (Kubernetes-style)
- ✅ Free and open source (no licensing concerns)

**Common Workflows**:

1. **Docker Compose Replacement**:
   ```bash
   # Most docker-compose commands work with podman-compose
   alias docker-compose='podman-compose'

   # Use existing docker-compose.yml files
   podman-compose up -d
   podman-compose logs -f
   podman-compose down
   ```

2. **Docker CLI Alias**:
   ```bash
   # Add to ~/.zshrc for Docker compatibility
   alias docker='podman'

   # Now docker commands work with Podman
   docker run nginx
   docker ps
   docker images
   ```

**Machine Management**:
- Machine starts automatically on first `podman` command
- Stop machine to free resources: `podman machine stop`
- Machine uses ~2GB RAM when running
- Disk space configured during init (default: 10GB, expandable)

**Troubleshooting**:

1. **"Cannot connect to Podman" error**:
   ```bash
   # Start the machine
   podman machine start
   ```

2. **"Docker socket is not disguised correctly" error** (Podman Desktop):
   ```bash
   # Remove the misconfigured machine
   podman machine stop
   podman machine rm podman-machine-default

   # Re-initialize with correct flags
   podman machine init --now --rootful=false

   # Verify
   podman machine list
   # Restart Podman Desktop
   ```

3. **Machine won't start**:
   ```bash
   # Check machine status
   podman machine list

   # If machine is corrupted, recreate it
   podman machine stop
   podman machine rm podman-machine-default
   podman machine init --now --rootful=false
   ```

3. **Port conflicts**:
   ```bash
   # Check what's using the port
   lsof -i :8080

   # Use different port mapping
   podman run -p 8081:80 nginx
   ```

4. **Disk space issues**:
   ```bash
   # Clean up unused images and containers
   podman system prune -a

   # Check disk usage
   podman system df
   ```

**Integration with Development**:
- **Epic-04**: Will add Podman configuration to shell (aliases, completion)
- **Epic-05**: Podman Desktop may receive Catppuccin theming
- **Projects**: Use Containerfiles instead of Dockerfiles (OCI-compliant)

**Update Philosophy**:
- ✅ All Podman tools updated via Homebrew (`rebuild` or `update` commands)
- ✅ Versions controlled by Homebrew (auto-update disabled globally)
- ⚠️ Do NOT use `brew upgrade podman` or `brew upgrade podman-desktop` manually
- ✅ Updates ONLY via darwin-rebuild (Homebrew managed by nix-darwin)

**Testing Checklist**:
- [ ] Podman CLI installed and version shows
- [ ] podman-compose installed and version shows
- [ ] Podman Desktop installed and launches
- [ ] Podman machine initialized successfully
- [ ] Podman machine starts and shows as "Currently running"
- [ ] Can run `podman run hello-world` successfully
- [ ] Podman Desktop GUI shows machine status
- [ ] Can manage containers from Desktop app
- [ ] podman-compose can start/stop services

**Known Issues**:
- **Machine initialization required**: First-time setup needs manual `podman machine init --now --rootful=false`
- **Docker socket error**: If you see "Docker socket is not disguised correctly", reinitialize machine with correct flags (see Troubleshooting)
- **Resource usage**: Machine consumes ~2GB RAM when running (stop with `podman machine stop` if not needed)
- **Slow first pulls**: Initial image downloads may be slow depending on network

**Resources**:
- Podman Documentation: https://podman.io/docs
- Podman Desktop: https://podman-desktop.io/
- podman-compose: https://github.com/containers/podman-compose
- Containerfile Spec: https://github.com/containers/common/blob/main/docs/Containerfile.5.md

---

## Claude Code CLI and MCP Servers


---

## Related Documentation

- [Main Apps Index](../README.md)
- [Python Tools Configuration](./python-tools.md)
- [VS Code Configuration](./vscode.md)
- [Claude Code CLI](./claude-code-cli.md)
