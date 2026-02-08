# ABOUTME: Epic-06 Feature 06.5 (Email Notification System) implementation details
# ABOUTME: Contains story implementation, testing results, and validation for Feature 06.5

# Epic-06 Feature 06.5: Email Notification System

## Feature Overview

**Feature ID**: Feature 06.5
**Feature Name**: Email Notification System
**Epic**: Epic-06
**Status**: Not Started

### Feature 06.5: Email Notification System
**Feature Description**: Email notifications for maintenance failures and weekly digest summaries using msmtp with Gandi SMTP and macOS Keychain for secure credential storage
**User Value**: FX receives proactive notifications when maintenance issues occur and weekly visibility into system health without manual checking
**Story Count**: 3
**Story Points**: 16
**Priority**: Should Have (P1)
**Complexity**: Medium

#### Stories in This Feature

##### Story 06.5-001: msmtp Email Infrastructure Setup
**User Story**: As FX, I want msmtp configured with secure Gandi email credentials so that my system can send automated email notifications

**Priority**: Must Have
**Story Points**: 5
**Sprint**: Sprint 9

**Acceptance Criteria**:
- **Given** darwin-rebuild completes successfully
- **When** I check msmtp configuration
- **Then** msmtp is installed via Home Manager
- **And** configuration uses Gandi SMTP (mail.gandi.net:587 with STARTTLS)
- **And** password is retrieved from macOS Keychain via `security` command
- **And** no passwords are stored in config files (security requirement)
- **And** I can manually test with `echo "test" | msmtp recipient@example.com`

**Additional Requirements**:
- Provider: Gandi (mail.gandi.net:587)
- Security: STARTTLS encryption
- Credentials: macOS Keychain via `passwordeval`
- Logging: ~/.local/log/msmtp.log

**Technical Notes**:
- Home Manager module: `home-manager/modules/msmtp.nix`
- Keychain setup script: `scripts/setup-msmtp-keychain.sh`
- Keychain entry: `security add-generic-password -a "${email}" -s "msmtp-gandi" -w`
- Password retrieval: `security find-generic-password -a "${email}" -s "msmtp-gandi" -w`

**Implementation**:
```nix
# home-manager/modules/msmtp.nix
programs.msmtp = {
  enable = true;
  accounts.default = {
    host = "mail.gandi.net";
    port = 587;
    tls = true;
    tls_starttls = "on";
    from = userConfig.email;
    user = userConfig.email;
    passwordeval = "security find-generic-password -a '${userConfig.email}' -s 'msmtp-gandi' -w 2>/dev/null";
    logfile = "${config.home.homeDirectory}/.local/log/msmtp.log";
  };
};
```

**Definition of Done**:
- [ ] msmtp.nix module created with Gandi configuration
- [ ] Home Manager imports msmtp module
- [ ] bootstrap.sh downloads msmtp.nix
- [ ] Keychain setup script created
- [ ] Manual email test succeeds
- [ ] No passwords in config files (verified)
- [ ] Documentation for Keychain setup added

**Dependencies**:
- Epic-01, Story 01.5-001 (nix-darwin installed)
- Epic-04, Story 04.1-001 (shell configuration)

**Risk Level**: Low
**Risk Mitigation**: Keychain provides native macOS security integration

---

##### Story 06.5-002: Error Notification Integration
**User Story**: As FX, I want email notifications when maintenance jobs fail so that I can address issues promptly

**Priority**: Must Have
**Story Points**: 5
**Sprint**: Sprint 9

**Acceptance Criteria**:
- **Given** GC, optimization, or health check jobs run
- **When** an error occurs (non-zero exit code)
- **Then** an email is sent to my configured address
- **And** email includes job name, timestamp, exit code, and error output
- **And** normal successful runs do NOT send emails (issues only)
- **And** I can verify notification by forcing a failure

**Additional Requirements**:
- Trigger: Non-zero exit code only
- Content: Job name, timestamp, exit code, error log (last 100 lines)
- No spam: Successful runs are silent
- Testable: Can force failure to verify

**Technical Notes**:
- Email wrapper: `scripts/send-notification.sh`
- Job wrapper: `scripts/maintenance-wrapper.sh`
- Environment variable: `NOTIFICATION_EMAIL` for recipient
- LaunchAgent module: `darwin/maintenance.nix`

**Implementation**:
```bash
# scripts/maintenance-wrapper.sh
#!/usr/bin/env bash
JOB_NAME="${1:-maintenance}"
COMMAND="${2:-echo 'No command'}"
RECIPIENT="${NOTIFICATION_EMAIL:-}"

if ! eval "${COMMAND}" > /tmp/${JOB_NAME}.log 2>&1; then
    EXIT_CODE=$?
    if [[ -n "${RECIPIENT}" ]]; then
        ./scripts/send-notification.sh "${RECIPIENT}" \
            "[ALERT] ${JOB_NAME} failed" \
            "Exit code: ${EXIT_CODE}" \
            "/tmp/${JOB_NAME}.err"
    fi
    exit ${EXIT_CODE}
fi
```

**Definition of Done**:
- [ ] send-notification.sh script created
- [ ] maintenance-wrapper.sh script created
- [ ] LaunchAgents updated to use wrapper
- [ ] Email sent on job failure (tested)
- [ ] No email on successful run (verified)
- [ ] Error details included in notification
- [ ] Tested by forcing GC failure

**Dependencies**:
- Story 06.5-001 (msmtp configured)
- Story 06.1-001 (GC LaunchAgent exists)
- Story 06.2-001 (Optimization LaunchAgent exists)

**Risk Level**: Low
**Risk Mitigation**: Wrapper script isolates notification logic from job execution

---

##### Story 06.5-003: Weekly Maintenance Digest
**User Story**: As FX, I want a weekly email digest summarizing all maintenance activity so that I have visibility into system health

**Priority**: Should Have
**Story Points**: 6
**Sprint**: Sprint 9

**Acceptance Criteria**:
- **Given** one week of maintenance activity
- **When** Sunday at 8 AM arrives
- **Then** a digest email is sent summarizing:
  - GC runs: count from logs
  - Optimization runs: count from logs
  - System generations: current count
  - Nix store size: current disk usage
  - FileVault status: enabled/disabled
  - Firewall status: enabled/disabled
  - Recommendations: if issues detected
- **And** I can manually trigger digest with `weekly-digest` alias

**Additional Requirements**:
- Schedule: Sunday 8:00 AM (launchd)
- Content: Aggregate metrics from /tmp/*.log files
- Recommendations: Based on health check logic
- Manual trigger: `weekly-digest` alias

**Technical Notes**:
- Digest script: `scripts/weekly-maintenance-digest.sh`
- LaunchAgent: weekly-digest (Weekday=0, Hour=8, Minute=0)
- Alias: `weekly-digest` in shell.nix

**Implementation**:
```bash
# scripts/weekly-maintenance-digest.sh
#!/usr/bin/env bash
RECIPIENT="${1:-${NOTIFICATION_EMAIL:-}}"
HOSTNAME=$(hostname)

# Gather metrics
GC_RUNS=$(grep -c "Starting nix-gc" /tmp/nix-gc.log 2>/dev/null || echo "0")
OPT_RUNS=$(grep -c "Starting nix-optimize" /tmp/nix-optimize.log 2>/dev/null || echo "0")
GENERATIONS=$(darwin-rebuild --list-generations 2>/dev/null | wc -l | tr -d ' ')
NIX_STORE_SIZE=$(du -sh /nix/store 2>/dev/null | cut -f1 || echo "unknown")

# Build and send digest
cat <<EOF | msmtp "${RECIPIENT}"
Subject: Weekly Maintenance Digest - ${HOSTNAME}

=== Weekly Maintenance Digest ===
Generated: $(date)

MAINTENANCE ACTIVITY
- GC Runs: ${GC_RUNS}
- Optimization Runs: ${OPT_RUNS}

SYSTEM STATE
- Nix Store Size: ${NIX_STORE_SIZE}
- System Generations: ${GENERATIONS}

---
Automated digest from nix-install
EOF
```

**Definition of Done**:
- [ ] weekly-maintenance-digest.sh script created
- [ ] Weekly digest LaunchAgent configured (Sunday 8 AM)
- [ ] Digest includes all required metrics
- [ ] Recommendations included for issues
- [ ] Manual trigger via `weekly-digest` alias works
- [ ] Tested by running manually
- [ ] Digest email received and formatted correctly

**Dependencies**:
- Story 06.5-001 (msmtp configured)
- Story 06.5-002 (Error notification integration - for log file patterns)
- Story 06.4-001 (Health check script - for metric gathering logic)

**Risk Level**: Low
**Risk Mitigation**: Log aggregation is read-only; digest is informational

---

## Feature Dependencies

### Dependencies on Other Features
- **Feature 06.1**: GC LaunchAgent must exist before wrapping with notifications
- **Feature 06.2**: Optimization LaunchAgent must exist before wrapping with notifications
- **Feature 06.4**: Health check metrics logic reused in weekly digest

### Internal Story Dependencies
```
Story 06.5-001 (msmtp Infrastructure)
         │
         ├──────────────────────┐
         ▼                      ▼
Story 06.5-002             Story 06.5-003
(Error Notifications)      (Weekly Digest)
```

## Files to Create

| File | Purpose | Story |
|------|---------|-------|
| `home-manager/modules/msmtp.nix` | msmtp Home Manager module | 06.5-001 |
| `scripts/setup-msmtp-keychain.sh` | Keychain credential setup | 06.5-001 |
| `scripts/send-notification.sh` | Email sending wrapper | 06.5-002 |
| `scripts/maintenance-wrapper.sh` | Job wrapper with notifications | 06.5-002 |
| `scripts/weekly-maintenance-digest.sh` | Weekly digest generator | 06.5-003 |
| `darwin/maintenance.nix` | LaunchAgent definitions | 06.5-002, 06.5-003 |

## Files to Modify

| File | Modification | Story |
|------|--------------|-------|
| `home-manager/home.nix` | Add msmtp.nix import | 06.5-001 |
| `home-manager/modules/shell.nix` | Add weekly-digest alias | 06.5-003 |
| `bootstrap.sh` | Add new files to Phase 4 download | All |
| `flake.nix` | Import darwin/maintenance.nix | 06.5-002 |

## Post-Install Setup Required

After `darwin-rebuild switch`, user must:

1. **Store Gandi password in Keychain**:
   ```bash
   ./scripts/setup-msmtp-keychain.sh
   # Or manually:
   security add-generic-password -a "your@email.com" -s "msmtp-gandi" -w "your-password"
   ```

2. **Test email sending**:
   ```bash
   echo "Test from nix-install" | msmtp your@email.com
   ```

3. **Verify LaunchAgents loaded**:
   ```bash
   launchctl list | grep -E "nix-gc|nix-optimize|weekly-digest"
   ```

## Security Considerations

- **No cleartext passwords**: All passwords stored in macOS Keychain
- **passwordeval**: msmtp retrieves password at runtime, never stored in config
- **Keychain access**: Only user can access their Keychain passwords
- **Log files**: Exclude sensitive info from logs (no passwords, minimal PII)
- **Script permissions**: Scripts chmod 755 (executable, not world-writable)

## Testing Strategy (Performed by FX)

1. **Keychain setup test**: Run setup script, verify password stored
2. **Manual email test**: `echo "test" | msmtp recipient@example.com`
3. **Force failure test**: `./scripts/maintenance-wrapper.sh "test" "false"`
4. **Manual digest test**: Run `weekly-digest` alias
5. **LaunchAgent verification**: `launchctl list | grep weekly-digest`
