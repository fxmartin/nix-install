#!/bin/bash
# ABOUTME: GitHub Labels Setup for Nix-Darwin macOS Bootstrap System
# ABOUTME: Multi-Agent Development Workflow Compatible for declarative macOS configuration

echo "🏷️  Setting up GitHub labels for Nix-Darwin Bootstrap project..."

# SEVERITY LABELS (Red family - urgent attention)
echo "📊 Creating severity labels..."
gh label create "critical" --description "Critical issues - immediate attention required" --color "B60205" || true
gh label create "high" --description "High priority issues - fix soon" --color "D93F0B" || true
gh label create "medium" --description "Medium priority issues - normal timeline" --color "FBCA04" || true
gh label create "low" --description "Low priority issues - fix when convenient" --color "0E8A16" || true

# TYPE/CATEGORY LABELS (Orange/Red family - issue classification)
echo "🐛 Creating type/category labels..."
gh label create "bug" --description "Something isn't working correctly" --color "D73A4A" || true
gh label create "enhancement" --description "New feature or improvement" --color "A2EEEF" || true
gh label create "performance" --description "Performance optimization needed" --color "FF6B6B" || true
gh label create "security" --description "Security vulnerability or concern" --color "B60205" || true
gh label create "documentation" --description "Documentation needs update" --color "0075CA" || true
gh label create "refactor" --description "Code refactoring needed" --color "E99695" || true
gh label create "code-quality" --description "Code quality improvements (linting, style)" --color "FEF2C0" || true

# TECHNOLOGY STACK LABELS (Blue family - for agent assignment)
echo "💻 Creating technology stack labels..."
gh label create "bash/shell" --description "Bash/Shell scripting related" --color "4EAA25" || true
gh label create "nix" --description "Nix package manager related" --color "5277C3" || true
gh label create "nix-darwin" --description "nix-darwin system configuration" --color "7EBAE4" || true
gh label create "homebrew" --description "Homebrew package management" --color "FBB040" || true
gh label create "macos" --description "macOS system preferences/settings" --color "000000" || true
gh label create "testing" --description "BATS tests, shellcheck, testing framework" --color "C5DEF5" || true

# EPIC LABELS (Gradient - story epic tracking)
echo "🎯 Creating epic labels..."
gh label create "epic-01" --description "Epic 01: Bootstrap & Installation System" --color "0052CC" || true
gh label create "epic-02" --description "Epic 02: Application Installation & Configuration" --color "0747A6" || true
gh label create "epic-03" --description "Epic 03: System Configuration & macOS Preferences" --color "6554C0" || true
gh label create "epic-04" --description "Epic 04: Development Environment & Shell" --color "00875A" || true
gh label create "epic-05" --description "Epic 05: Theming & Visual Consistency" --color "FF5630" || true
gh label create "epic-06" --description "Epic 06: Maintenance & Monitoring" --color "FF8B00" || true
gh label create "epic-07" --description "Epic 07: Documentation & User Experience" --color "5243AA" || true
gh label create "epic-nfr" --description "Non-Functional Requirements" --color "8777D9" || true

# COMPONENT LABELS (Green family - project areas)
echo "🏗️  Creating component labels..."
gh label create "bootstrap" --description "Bootstrap script and pre-flight checks" --color "28A745" || true
gh label create "system-config" --description "macOS system preferences (Finder, security, etc.)" --color "2DA44E" || true
gh label create "dev-environment" --description "Development tools (Zsh, Git, Python, Podman)" --color "2F7F3F" || true
gh label create "theming" --description "Stylix, Catppuccin, visual consistency" --color "57AB5A" || true
gh label create "monitoring" --description "Health checks, garbage collection, optimization" --color "1F6E43" || true
gh label create "apps" --description "Application installation (GUI, CLI, Mac App Store)" --color "3FB950" || true
gh label create "dotfiles" --description "Home Manager dotfiles configuration" --color "26A641" || true

# AGENT ASSIGNMENT LABELS (Purple family - for multi-agent workflow)
echo "🤖 Creating agent assignment labels..."
gh label create "bash-zsh-macos" --description "For bash-zsh-macos-engineer agent" --color "7B68EE" || true
gh label create "code-review" --description "For senior-code-reviewer agent" --color "8A2BE2" || true
gh label create "qa-expert" --description "For qa-expert agent (testing strategy)" --color "9932CC" || true
gh label create "multi-agent" --description "Requires multiple agents" --color "6A0DAD" || true

# WORKFLOW STATUS LABELS (Yellow/Orange family - process tracking)
echo "🔄 Creating workflow status labels..."
gh label create "in-progress" --description "Currently being worked on" --color "FEF2C0" || true
gh label create "blocked" --description "Blocked by dependencies or external factors" --color "B60205" || true
gh label create "needs-review" --description "Ready for code review" --color "FBCA04" || true
gh label create "vm-testing" --description "Ready for VM testing by FX" --color "C5DEF5" || true
gh label create "needs-info" --description "More information required" --color "D4C5F9" || true

# PRIORITY/SPECIAL LABELS (Mixed colors - special handling)
echo "⭐ Creating priority and special labels..."
gh label create "good-first-issue" --description "Good for newcomers or quick wins" --color "7057FF" || true
gh label create "help-wanted" --description "Extra attention needed" --color "008672" || true
gh label create "breaking-change" --description "Introduces breaking changes to config" --color "B60205" || true
gh label create "hotfix" --description "Urgent fix needed" --color "FF0000" || true

# STORY POINT LABELS (Blue gradient - estimation matching REQUIREMENTS.md)
echo "📏 Creating story point labels..."
gh label create "points/1" --description "1 story point - Trivial complexity" --color "E6F3FF" || true
gh label create "points/2" --description "2 story points - Simple complexity" --color "D1E9FF" || true
gh label create "points/3" --description "3 story points - Medium complexity" --color "B3D9FF" || true
gh label create "points/5" --description "5 story points - Complex" --color "80BFFF" || true
gh label create "points/8" --description "8 story points - Very Complex" --color "4D9FFF" || true
gh label create "points/13" --description "13 story points - Highly Complex" --color "1A7FFF" || true

# PHASE/MILESTONE LABELS (Teal family - implementation phases)
echo "🚀 Creating phase/milestone labels..."
gh label create "phase-0-2" --description "Phase 0-2: Foundation + Bootstrap (Week 1-2)" --color "20B2AA" || true
gh label create "phase-3-5" --description "Phase 3-5: Apps, System Config, Dev Env (Week 3-5)" --color "48D1CC" || true
gh label create "phase-6-8" --description "Phase 6-8: Theming, Monitoring, Docs (Week 5-6)" --color "00CED1" || true
gh label create "phase-9" --description "Phase 9: VM Testing (Week 6)" --color "40E0D0" || true
gh label create "phase-10-11" --description "Phase 10-11: Hardware Migration (Week 7-8)" --color "00CED1" || true
gh label create "mvp" --description "Minimum viable product - Must have for P0" --color "5DADE2" || true

# PROFILE LABELS (Orange family - deployment profiles)
echo "💻 Creating profile labels..."
gh label create "profile/standard" --description "MacBook Air - Standard profile (~35GB)" --color "FF9800" || true
gh label create "profile/power" --description "MacBook Pro M3 Max - Power profile (~120GB)" --color "FF5722" || true
gh label create "profile/both" --description "Affects both Standard and Power profiles" --color "FF6F00" || true

echo ""
echo "✅ GitHub labels setup complete!"
echo ""
echo "📋 LABEL SUMMARY:"
echo "🔴 Severity: critical, high, medium, low"
echo "🟠 Types: bug, enhancement, performance, security, documentation, refactor, code-quality"
echo "🔵 Tech: bash/shell, nix, nix-darwin, homebrew, macos, testing"
echo "🎯 Epics: epic-01 through epic-07, epic-nfr"
echo "🟢 Components: bootstrap, system-config, dev-environment, theming, monitoring, apps, dotfiles"
echo "🟣 Agents: bash-zsh-macos, code-review, qa-expert, multi-agent"
echo "🟡 Workflow: in-progress, blocked, needs-review, vm-testing, needs-info"
echo "⭐ Special: good-first-issue, help-wanted, breaking-change, hotfix"
echo "📏 Points: points/1, points/2, points/3, points/5, points/8, points/13"
echo "🚀 Phases: phase-0-2, phase-3-5, phase-6-8, phase-9, phase-10-11, mvp"
echo "💻 Profiles: profile/standard, profile/power, profile/both"
echo ""
echo "🎯 Usage examples:"
echo "- Bootstrap issue: bug, high, bootstrap, epic-01, bash-zsh-macos, points/5"
echo "- System config: enhancement, medium, system-config, epic-03, points/3"
echo "- Testing issue: code-quality, testing, qa-expert, points/2"
echo "- VM ready: vm-testing, phase-9, profile/both"
echo ""
echo "💡 Story tracking examples:"
echo "- Story 01.1-001: epic-01, bootstrap, points/5, phase-0-2, bash-zsh-macos"
echo "- Story 04.2-003: epic-04, dev-environment, points/8, phase-3-5, code-review"
echo "- Story 05.1-001: epic-05, theming, points/3, phase-6-8, profile/both"
echo ""
echo "📝 Next steps:"
echo "1. Test label creation: gh issue create --title 'Test' --label 'bug,medium,bootstrap'"
echo "2. Use story IDs in issue titles for tracking: '[Story 01.1-001] Fix...'"
echo "3. Tag issues with appropriate epic, component, and agent labels"
echo "4. Use vm-testing label when ready for FX manual testing"
