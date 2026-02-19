# ABOUTME: Epic-06 Feature 06.4 (Health Check Command) implementation details
# ABOUTME: Contains story implementation, testing results, and validation for Feature 06.4

# Epic-06 Feature 06.4: Health Check Command

## Feature Overview

**Feature ID**: Feature 06.4
**Feature Name**: Health Check Command
**Epic**: Epic-06
**Status**: 🔄 In Progress


  # FileVault
  if fdesetup status | grep -q "FileVault is On"; then
    echo "✅ FileVault enabled"
  else
    echo "⚠️  FileVault disabled (encryption recommended)"
  fi

  # Firewall
  if /usr/libexec/ApplicationFirewall/socketfilterfw --getglobalstate | grep -q "enabled"; then
    echo "✅ Firewall enabled"
  else
    echo "❌ Firewall disabled"
  fi

  # Generations
  GENS=$(darwin-rebuild --list-generations | wc -l)
  echo "🔄 System generations: $GENS"
  if [ $GENS -gt 50 ]; then
    echo "⚠️  Many generations, consider running 'gc'"
  fi

  echo "=== Health check complete ==="
  ```
- Add to darwin/system-monitoring.nix or scripts/
- Alias in Epic-04 points to this script

**Definition of Done**:
- [ ] health-check.sh script created
- [ ] All checks implemented
- [ ] Clear ✅/⚠️/❌ output
- [ ] Actionable recommendations
- [ ] Script executable
- [ ] Alias functional
- [ ] Tested in VM

**Dependencies**:
- Epic-04, Story 04.5-001 (health-check alias)

**Risk Level**: Low
**Risk Mitigation**: N/A

---

##### Story 06.4-002: Health Check Alias Integration
**User Story**: As FX, I want the `health-check` alias to work from any directory so that I can run it quickly

**Priority**: Must Have
**Story Points**: 1
**Sprint**: Sprint 8

**Acceptance Criteria**:
- **Given** darwin-rebuild completes successfully
- **When** I run `health-check` from any directory
- **Then** it executes the health check script
- **And** displays system health status
- **And** completes quickly (<10 seconds)

**Additional Requirements**:
- Alias: `health-check` → path to script
- Global availability: Works from any directory
- Fast execution: <10 seconds

**Technical Notes**:
- Alias already defined in Epic-04, Story 04.5-001:
  ```nix
  health-check = "~/Documents/nix-install/scripts/health-check.sh";
  ```
- Or use absolute path in Nix store if script is managed by nix-darwin
- Verify: Run `health-check` from ~ and from random directory
- Test: Check output is correct

**Definition of Done**:
- [ ] Alias functional (from Epic-04)
- [ ] Works from any directory
- [ ] Executes health check script
- [ ] Fast execution
- [ ] Tested in VM

**Dependencies**:
- Epic-04, Story 04.5-001 (health-check alias)
- Story 06.4-001 (Health check script)

**Risk Level**: Low
**Risk Mitigation**: N/A

---

## Epic Dependencies

### Dependencies on Other Epics
- **Epic-01 (Bootstrap)**: Requires nix-darwin installed for launchd agents
- **Epic-02 (Applications)**: Requires btop, iStat Menus, macmon installed
- **Epic-03 (System Config)**: FileVault and firewall checks reference security settings
- **Epic-04 (Dev Environment)**: gc, cleanup, health-check aliases defined
- **Epic-07 (Documentation)**: Licensed apps documentation for iStat Menus

### Stories This Epic Enables
- Epic-07, Story 07.2-001: iStat Menus activation documented
- Epic-07, Story 07.3-001: Health check command usage in troubleshooting

### Stories This Epic Blocks
- None (maintenance is enhancement, not blocker)
