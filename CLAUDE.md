# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This repository implements an automated, declarative MacBook configuration system using Nix, nix-darwin, and Home Manager. The goal is to transform a fresh macOS install into a fully configured development environment in <30 minutes with zero manual intervention (except license activations).

**Target User**: FX manages 3 MacBooks (1x MacBook Pro M3 Max, 2x MacBook Air) with periodic reinstalls. Split usage between Office 365 work and weekend Python development.

**Key Philosophy**:
- **Declarative**: Configuration IS the documentation (no drift)
- **Reproducible**: Same config → identical system state
- **Atomic**: All-or-nothing updates with instant rollback capability
- **No Auto-Updates**: All app updates controlled via `rebuild` command only

## Architecture

### Two-Tier Installation Profiles

1. **Standard Profile** (MacBook Air targets):
   - Core apps, single Ollama model (`gpt-oss:20b`)
   - No virtualization
   - ~35GB disk usage

2. **Power Profile** (MacBook Pro M3 Max target):
   - All Standard apps + Parallels Desktop
   - 4 Ollama models (`gpt-oss:20b`, `qwen2.5-coder:32b`, `llama3.1:70b`, `deepseek-r1:32b`)
   - ~120GB disk usage

### Package Management Strategy (Priority Order)

1. **Nix First** (via nixpkgs-unstable): CLI tools, dev tools, Python 3.12, uv, ruff, Podman, etc.
2. **Homebrew Casks**: GUI apps (Zed, Ghostty, Arc, Firefox, Claude Desktop, etc.)
3. **Mac App Store (mas)**: Only when no alternative (Kindle, WhatsApp)
4. **Manual**: Licensed software (Office 365)

**Why nixpkgs-unstable**: Latest packages, better macOS arm64 support, faster updates. Flake lock provides reproducibility despite "unstable" name.

### Theming System

**Stylix** manages system-wide theming:
- **Theme**: Catppuccin (Latte for light mode, Mocha for dark mode)
- **Font**: JetBrains Mono Nerd Font with ligatures
- **Auto-switch**: Follows macOS system appearance (light/dark)
- **Applies to**: Ghostty (terminal), Zed (editor), shell, and other Stylix-supported apps
- **Goal**: Visual consistency when switching between terminal and editor

### Shell Environment

- **Zsh** with **Oh My Zsh** (plugins: git, fzf, zsh-autosuggestions, z)
- **Starship** prompt (NOT Oh My Zsh themes - `ZSH_THEME=""`)
- **FZF** integration (Ctrl+R history, Ctrl+T files, Alt+C directories)
- **Ghostty** terminal with config from `config/config.ghostty`

### Update Control Philosophy

**Critical**: All app updates ONLY via `rebuild` or `update` commands:
- `rebuild`: Apply config changes (uses versions from flake.lock)
- `update`: Update flake.lock (gets latest versions) + rebuild
- Auto-updates disabled via: `HOMEBREW_NO_AUTO_UPDATE=1`, app configs, system defaults

Apps requiring auto-update disable: Homebrew, Zed, VSCode, Arc, Firefox, Dropbox, 1Password, Zoom, Webex, Raycast, Ghostty, macOS system updates.

## Development Workflow

### Testing Strategy (CRITICAL)

**⚠️ CLAUDE DOES NOT PERFORM TESTING ⚠️**

Claude's role: Write code, configuration, and documentation ONLY.
FX's role: ALL testing, execution, and validation.

**Testing sequence (performed by FX manually)**:

1. **VM Testing (Required)**: FX tests in Parallels macOS VM first
   - Create fresh macOS VM (4+ CPU cores, 8+ GB RAM, 100+ GB disk)
   - Test Power profile (matches MacBook Pro M3 Max complexity)
   - Iterate until bootstrap succeeds with zero manual intervention
   - Final validation: Destroy VM, rebuild from scratch (must be flawless)

2. **Physical Hardware**: Only after VM testing successful
   - First: MacBook Pro M3 Max (Power profile)
   - Then: MacBook Air #1 and #2 (Standard profile)

**Claude must NEVER**:
- Run bootstrap.sh, setup.sh, or any installation scripts
- Execute nix-darwin, darwin-rebuild, or Nix commands that modify the system
- Test configurations on any machine (VM or physical)
- Assume code works without FX's manual testing

### Key Files

**Currently Implemented**:
- `REQUIREMENTS.md`: Comprehensive PRD (1600+ lines) - **THE SOURCE OF TRUTH** for requirements
- `DEVELOPMENT.md`: Implementation log and progress tracking - **CHECK THIS FIRST** for:
  - Story completion status and implementation details
  - Current progress (stories completed, points tracked)
  - Multi-agent workflow documentation
  - Testing results and code quality metrics
  - Next story to implement
- `README.md`: Quick start guide
- `config/config.ghostty`: Ghostty terminal configuration (Catppuccin theme)
- `setup.sh`: Legacy setup script (will be replaced by new bootstrap)
- `mlgruby-repo-for-reference/`: Reference implementation to learn from

**To Be Implemented** (per REQUIREMENTS.md):
- `flake.nix`: System definition with Standard/Power profiles
- `user-config.nix`: User personal info (created during bootstrap)
- `darwin/`: System-level configs (nix-darwin)
  - `configuration.nix`, `homebrew.nix`, `macos-defaults.nix`, `system-monitoring.nix`, `nix-settings.nix`
- `home-manager/`: User-level configs (dotfiles)
  - `modules/zsh.nix`, `modules/git.nix`, `modules/starship.nix`, `modules/aliases.nix`, etc.
- `bootstrap.sh`: Bootstrap script in main directory (10-phase installation)
- `docs/`: User documentation (quick-start, troubleshooting, customization)

### Implementation Phases (8-Week Plan)

**Phase 0-2** (Week 1-2): Foundation + bootstrap script
**Phase 3-5** (Week 3-4): Apps, system config, dev environment
**Phase 6-8** (Week 5-6): Theming, monitoring, documentation
**Phase 9** (Week 6): **VM Testing** (required before hardware)
**Phase 10** (Week 7): MacBook Pro M3 Max migration
**Phase 11** (Week 8): MacBook Air migrations

See REQUIREMENTS.md Implementation Plan section for detailed checklists.

## Working with This Codebase

### Understanding the mlgruby Reference

`mlgruby-repo-for-reference/dotfile-nix/` is a **production-grade reference implementation** to learn from:
- Proven architecture (nix-darwin + Home Manager + Stylix)
- 35+ Nix files showing modular design patterns
- Comprehensive documentation (50+ markdown files)
- **Do not copy blindly** - it has AWS-specific config, different app choices
- **Do copy patterns**: Module structure, flake setup, Stylix integration, Home Manager patterns

### Key Architectural Decisions

1. **No Homebrew Pre-Installation**: Bootstrap installs Nix first, then nix-darwin manages Homebrew declaratively
2. **Profile-Based Flake**: Single flake.nix with `darwinConfigurations.standard` and `darwinConfigurations.power`
3. **SSH Key Before Clone**: Generate SSH key, display to user, wait for GitHub upload, test connection, then clone repo
4. **Stylix for Consistency**: System-wide theming ensures Ghostty and Zed match visually
5. **Modular Home Manager**: One concern per file (zsh.nix, git.nix, etc.) not monolithic config

### Common Nix Patterns

**Flake structure**:
```nix
inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
inputs.nix-darwin.inputs.nixpkgs.follows = "nixpkgs";  # Pin to same nixpkgs
```

**Profile differentiation**:
```nix
darwinConfigurations.power = {
  homebrew.casks = [ "parallels" ];  # Power-only
  system.activationScripts.pullOllamaModels = ''...'';  # Power-only
};
```

**Auto-update disable**:
```nix
environment.variables.HOMEBREW_NO_AUTO_UPDATE = "1";
programs.vscode.userSettings."update.mode" = "none";
```

### Working with REQUIREMENTS.md

**REQUIREMENTS.md is the single source of truth** for:
- All P0 (must-have), P1 (should-have), P2 (nice-to-have) requirements
- Acceptance criteria for each feature
- App inventory with installation methods
- System preferences to automate (Finder, trackpad, security, etc.)
- Bootstrap flow diagrams
- Profile comparison tables
- Risk analysis and mitigation

**When implementing**: Cross-reference requirements (e.g., REQ-BOOT-001, REQ-APP-002) in code comments and commit messages.

### Requirements Change Control

**Baseline Protection**
Once requirements are approved via `/approve-requirements` command:
- Requirements document is considered baselined
- External integrity file provides tamper-evident validation
- All changes require formal change control process
- Document hash validation prevents unauthorized modifications

**External Integrity Validation**
- **Integrity File**: `requirements-integrity.json` contains validation hashes
- **Verification Script**: `verify-requirements-integrity.sh` validates document integrity
- **Separation of Concerns**: Validation data stored externally to prevent circular dependencies
- **Tamper Detection**: Any modification to requirements invalidates stored hash

**Change Request Process**
1. **Identify Change Need**: Document business justification
2. **Impact Assessment**: Analyze effect on timeline, budget, scope
3. **Stakeholder Review**: Present change to approval stakeholders
4. **Approval Decision**: Formal approval/rejection with rationale
5. **Document Update**: Update REQUIREMENTS.md with change log entry
6. **Integrity Update**: Regenerate external integrity validation
7. **Communication**: Notify all stakeholders of approved changes

**Change Control Authority**
- **Minor Changes** (clarifications, typos): Technical Lead approval
- **Major Changes** (scope, timeline, budget): Stakeholder approval required
- **Critical Changes** (fundamental approach): Full stakeholder committee approval

**Change Tracking**
All changes tracked in the Post-Approval Change Log in REQUIREMENTS.md with:
- Change description and rationale
- Impact assessment results
- Approval authority and date
- Updated document version
- New integrity validation hash

**Integrity Verification Commands**
```bash
# Quick integrity check
./verify-requirements-integrity.sh

# Manual verification
STORED=$(grep '"final_document"' requirements-integrity.json | cut -d'"' -f4)
CURRENT=$(shasum -a 256 REQUIREMENTS.md | cut -d' ' -f1)
echo "Stored: $STORED"
echo "Current: $CURRENT"
[ "$STORED" = "$CURRENT" ] && echo "✅ VERIFIED" || echo "❌ COMPROMISED"
```

## Configuration Preferences

### User Expectations (from ~/.claude/CLAUDE.md)

- Address user as **"FX"** (not "the user" or "the human")
- Simple, maintainable solutions over clever/complex
- **NEVER use --no-verify** when committing
- Match existing code style and formatting
- **NEVER remove code comments** unless provably false
- Test output must be pristine (no exceptions to testing policy)
- Prefer `uv` for Python package management
- Conventional commit format, imperative mood, present tense
- Always add `ABOUTME:` comment at top of new files

### Testing Requirements

- Unit tests, integration tests, AND end-to-end tests required (no exceptions without explicit authorization)
- TDD: Write tests before implementation
- Test output must be pristine - logs/errors must be captured and tested

### Git Commit Template

```
<type>: <subject>

<body>

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>
```

## Important Constraints

1. **CRITICAL - NO AUTOMATED TESTING**: Claude must NEVER execute bootstrap scripts or perform any system configuration changes. ALL testing is done MANUALLY by FX only. This includes:
   - ❌ Do NOT run bootstrap.sh or setup.sh
   - ❌ Do NOT run `nix-darwin` commands
   - ❌ Do NOT run `darwin-rebuild`
   - ❌ Do NOT execute any installation or configuration scripts
   - ✅ Only write code, documentation, and configuration files
   - ✅ FX will test manually in VM and on hardware
   - ✅ **EXCEPTION**: Static analysis tools ARE allowed (safe, read-only):
     - `shellcheck` - Shell script linter (syntax/quality checking)
     - `bats` - Bash test framework (when running read-only static checks)
     - These tools NEVER modify the system or execute bootstrap code

2. **No auto-updates**: Every app must have auto-update disabled. `rebuild` is the ONLY update mechanism.

3. **VM testing required**: Never test directly on physical MacBooks until VM testing passes. (FX performs this testing, not Claude)

4. **nixpkgs-unstable**: Use unstable channel for latest packages, flake.lock ensures reproducibility.

5. **Stylix theming**: Ghostty and Zed must use matching Catppuccin themes via Stylix.

6. **Two profiles only**: Standard (Air) and Power (Pro M3 Max). Don't create additional profiles without approval.

7. **Public repo**: Configuration is public (exclude secrets, use SOPS/age for P1 phase).

## Story Management Protocol

### Single Source of Truth Declaration
The `/stories/` directory and its epic files constitute the **single source of truth** for:
- All epic, feature, and user story definitions
- Story progress tracking and completion status
- Sprint planning and delivery milestones
- Acceptance criteria and definition of done status
- Cross-epic dependencies and risk management

### Mandatory Usage Requirements
- **Development Teams**: Must reference epic files for story details and acceptance criteria
- **Product Owners**: Must update story status and acceptance in epic files
- **Scrum Masters**: Must track sprint progress and dependencies in epic files
- **Stakeholders**: Must consult epic files for current story status and progress
- **QA Teams**: Must validate against acceptance criteria defined in epic files

### Story File Hierarchy
```
STORIES.md (overview and navigation)
└── stories/
    ├── epic-01-bootstrap-installation.md (detailed epic stories and progress)
    ├── epic-02-application-installation.md (detailed epic stories and progress)
    ├── epic-03-system-configuration.md (detailed epic stories and progress)
    ├── epic-04-development-environment.md (detailed epic stories and progress)
    ├── epic-05-theming-visual-consistency.md (detailed epic stories and progress)
    ├── epic-06-maintenance-monitoring.md (detailed epic stories and progress)
    ├── epic-07-documentation-user-experience.md (detailed epic stories and progress)
    └── non-functional-requirements.md (NFR stories and progress)
```

### Progress Update Protocol
**All story progress MUST be updated in the individual epic files:**

1. **Story Status Updates**: Update story completion checkboxes in epic files
2. **Sprint Progress**: Update sprint breakdown tables in each epic
3. **Acceptance Criteria**: Mark completed criteria in story definitions
4. **Dependency Status**: Update dependency tracking in epic files
5. **Risk Mitigation**: Update risk status and mitigation progress
6. **Story Point Burndown**: Track completed story points in epic progress sections

### Development Workflow Integration
- **Sprint Planning**: Use epic files for detailed story selection and estimation
- **Daily Standups**: Reference story IDs from epic files for progress updates
- **Code Reviews**: Link PRs to specific story IDs in epic files (e.g., "Implements Story 01.2-001")
- **Testing**: Use acceptance criteria from epic files for test validation
- **Deployment**: Update story completion status in epic files post-deployment
- **Retrospectives**: Reference epic file progress for velocity and improvement insights

### Documentation Maintenance
- **Story Updates**: Always update in the source epic file first, then communicate changes
- **Cross-References**: Maintain links between STORIES.md overview and epic files
- **Version Control**: Commit epic file changes with story completion and progress updates
- **Progress Reporting**: Generate stakeholder reports from epic file status data
- **Dependency Tracking**: Update cross-epic dependencies when stories complete

### Integration Points
- **GitHub Issues**: Link to specific Story IDs from epic files in issue descriptions
- **PR Reviews**: Reference epic file story acceptance criteria in pull request descriptions
- **Sprint Reports**: Generate velocity and burndown from epic file completion status
- **Stakeholder Updates**: Source all progress data from epic file metrics
- **Release Planning**: Use epic file story completion for release readiness assessment

### Prohibited Actions
❌ **DO NOT**:
- Update story details outside of the epic files
- Track progress in separate spreadsheets or project management tools
- Create duplicate story documentation in other formats
- Update STORIES.md overview with detailed story changes (only update metrics/summaries)
- Maintain story status in external systems without updating epic files first

✅ **DO**:
- Use epic files as the authoritative source for all story information
- Update story status directly in epic files immediately upon completion
- Reference story IDs from epic files in all project communications
- Maintain story history through git commits on epic files
- Generate all reports and metrics from epic file data

### Quality Assurance
- **Story Integrity**: Regular audits to ensure epic files reflect actual development status
- **Cross-Reference Validation**: Verify all story dependencies are accurately tracked
- **Progress Accuracy**: Ensure story completion status matches deployed functionality
- **Documentation Currency**: Keep epic files updated within 24 hours of story completion

**CRITICAL**: This story structure is now the project's single source of truth for all epic, feature, and story information. All progress tracking, status updates, detailed planning, and stakeholder communication must reference and update these files directly. Violation of this protocol undermines project tracking integrity and delivery predictability.

## GitHub Labels

### Available Labels for Issue Tracking

The project uses a comprehensive labeling system to categorize and track issues. All labels are managed via `scripts/setup-github-labels.sh`.

**🔴 Severity Levels** (4 labels)
- `critical` - Critical issues requiring immediate attention
- `high` - High priority issues, fix soon
- `medium` - Medium priority issues, normal timeline
- `low` - Low priority issues, fix when convenient

**🟠 Issue Types** (7 labels)
- `bug` - Something isn't working correctly
- `enhancement` - New feature or improvement
- `performance` - Performance optimization needed
- `security` - Security vulnerability or concern
- `documentation` - Documentation needs update
- `refactor` - Code refactoring needed
- `code-quality` - Code quality improvements (linting, style)

**🔵 Technology Stack** (6 labels)
- `bash/shell` - Bash/Shell scripting related
- `nix` - Nix package manager related
- `nix-darwin` - nix-darwin system configuration
- `homebrew` - Homebrew package management
- `macos` - macOS system preferences/settings
- `testing` - BATS tests, shellcheck, testing framework

**🎯 Epic Tracking** (8 labels)
- `epic-01` - Epic 01: Bootstrap & Installation System
- `epic-02` - Epic 02: Application Installation & Configuration
- `epic-03` - Epic 03: System Configuration & macOS Preferences
- `epic-04` - Epic 04: Development Environment & Shell
- `epic-05` - Epic 05: Theming & Visual Consistency
- `epic-06` - Epic 06: Maintenance & Monitoring
- `epic-07` - Epic 07: Documentation & User Experience
- `epic-nfr` - Non-Functional Requirements

**🟢 Component Areas** (7 labels)
- `bootstrap` - Bootstrap script and pre-flight checks
- `system-config` - macOS system preferences (Finder, security, etc.)
- `dev-environment` - Development tools (Zsh, Git, Python, Podman)
- `theming` - Stylix, Catppuccin, visual consistency
- `monitoring` - Health checks, garbage collection, optimization
- `apps` - Application installation (GUI, CLI, Mac App Store)
- `dotfiles` - Home Manager dotfiles configuration

**🟣 Agent Assignment** (4 labels)
- `bash-zsh-macos` - For bash-zsh-macos-engineer agent
- `code-review` - For senior-code-reviewer agent
- `qa-expert` - For qa-expert agent (testing strategy)
- `multi-agent` - Requires multiple agents

**🟡 Workflow Status** (5 labels)
- `in-progress` - Currently being worked on
- `blocked` - Blocked by dependencies or external factors
- `needs-review` - Ready for code review
- `vm-testing` - Ready for VM testing by FX
- `needs-info` - More information required

**⭐ Special Labels** (4 labels)
- `good-first-issue` - Good for newcomers or quick wins
- `help-wanted` - Extra attention needed
- `breaking-change` - Introduces breaking changes to config
- `hotfix` - Urgent fix needed

**📏 Story Points** (6 labels - matching REQUIREMENTS.md estimation)
- `points/1` - 1 story point (Trivial complexity)
- `points/2` - 2 story points (Simple complexity)
- `points/3` - 3 story points (Medium complexity)
- `points/5` - 5 story points (Complex)
- `points/8` - 8 story points (Very Complex)
- `points/13` - 13 story points (Highly Complex)

**🚀 Implementation Phases** (6 labels)
- `phase-0-2` - Phase 0-2: Foundation + Bootstrap (Week 1-2)
- `phase-3-5` - Phase 3-5: Apps, System Config, Dev Env (Week 3-5)
- `phase-6-8` - Phase 6-8: Theming, Monitoring, Docs (Week 5-6)
- `phase-9` - Phase 9: VM Testing (Week 6)
- `phase-10-11` - Phase 10-11: Hardware Migration (Week 7-8)
- `mvp` - Minimum viable product - Must have for P0

**💻 Profile Targets** (3 labels)
- `profile/standard` - MacBook Air - Standard profile (~35GB)
- `profile/power` - MacBook Pro M3 Max - Power profile (~120GB)
- `profile/both` - Affects both Standard and Power profiles

### Label Usage Guidelines

**Issue Creation Examples**:
```bash
# Bootstrap bug
gh issue create --title "[Story 01.1-001] Fix pre-flight checks" \
  --label "bug,high,bootstrap,epic-01,bash-zsh-macos,points/5,phase-0-2"

# System configuration enhancement
gh issue create --title "Add Finder preferences automation" \
  --label "enhancement,medium,system-config,epic-03,points/3"

# Testing/QA issue
gh issue create --title "Add integration test suite" \
  --label "testing,qa-expert,points/8,code-quality"

# VM testing ready
gh issue create --title "Bootstrap ready for VM validation" \
  --label "vm-testing,phase-9,profile/both,epic-01"
```

**Story Tracking Pattern**:
- Use story ID in issue title: `[Story 01.1-001]` or `[Story 04.2-003]`
- Tag with corresponding epic: `epic-01` through `epic-07` or `epic-nfr`
- Add story points: `points/1` through `points/13`
- Include phase label: `phase-0-2`, `phase-3-5`, etc.
- Tag appropriate agent: `bash-zsh-macos`, `code-review`, `qa-expert`
- Add profile if relevant: `profile/standard`, `profile/power`, `profile/both`

**Multi-Agent Story Example**:
```bash
# Full-stack feature requiring multiple agents
gh issue create --title "[Story 04.3-002] Configure Zsh with Starship" \
  --label "epic-04,dev-environment,multi-agent,bash-zsh-macos,code-review,points/8,phase-3-5"
```

### Label Maintenance

To recreate or update all labels:
```bash
bash scripts/setup-github-labels.sh
```

The script is idempotent - safe to run multiple times. It uses `|| true` to ignore errors if labels already exist.

## Reference Documentation

- **Primary**: `REQUIREMENTS.md` (comprehensive PRD)
- **Progress**: `DEVELOPMENT.md` (implementation log, story progress, multi-agent workflow)
- **Stories**: `STORIES.md` (epic overview) + `/stories/epic-*.md` (detailed stories)
- **Reference**: `mlgruby-repo-for-reference/dotfile-nix/` (production example)
- **User preferences**: `~/.claude/CLAUDE.md`, `~/.claude/docs/*.md`
- **Ghostty config**: `config/config.ghostty` (template for Home Manager)

**⚠️ IMPORTANT**: Always read `DEVELOPMENT.md` at the start of a session to check:
- What stories have been completed
- Current progress percentage (stories/points completed)
- Implementation details and lessons learned
- Which story to work on next
