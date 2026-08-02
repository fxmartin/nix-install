# Epic 11: Cloud Archive Tier

## Epic Overview
**Epic ID**: Epic-11
**Epic Description**: Add a cloud cold-storage tier (Backblaze B2 via rclone) below the NAS, so irreplaceable data gets an offsite copy (3-2-1) and cold data can be evicted from the NAS/SSD with confidence. Born from the 2026-08-02 storage audit: the NAS held 9.0TB of which 7.8TB was unmanaged Time Machine growth, and `Data/Archives/LTIMindtree-OneDrive-final-copy-2025-11` (186GB of FX's ex-employer OneDrive/SharePoint data, account access gone) exists as a **single copy on a single device**.
**Business Value**: Eliminates the single-point-of-failure risk on irreplaceable personal/professional archives for <$3/month; unlocks guilt-free deletion of cold data from the warm tiers.
**User Impact**: FX gets a verified, checksummed offsite copy of anything declared "archive", a repeatable bundle→upload→verify pipeline runnable over SSH against the NAS, and a written ledger of what lives in the cloud.
**Success Metrics**:
- LTIMindtree archive (186GB) and Outlook 2014 archive (~4GB) exist in B2 with verified SHA256 checksums
- Every archive bundle has a manifest entry (source path, date, size, SHA256, B2 object) in the archive ledger
- A test restore of at least one bundle has been performed and checksum-verified
- Total monthly cloud cost ≤ $3 at current volumes

## Epic Scope
**Total Stories**: 4
**Total Story Points**: 13
**MVP Stories**: 4 (100% — single feature)
**Priority Level**: Must Have (data-loss risk mitigation)
**Target Release**: v2.2.0
**Status**: 📋 Planned

## Features in This Epic

> **Note**: Detailed story implementations live in `stories/features/` following the Epic-06 pattern.

### Feature 11.1: B2 Archive Pipeline 📋
**Feature Description**: rclone + B2 remote setup, `nas-archive.sh` bundling script (tar.zst + SHA256 manifest, runs on the NAS over SSH), upload+verify workflow with archive ledger, and execution of the first two archives (LTIMindtree, Outlook 2014)
**Story Count**: 4 | **Story Points**: 13 | **Priority**: Must Have (P0) | **Complexity**: Medium
**Status**: 📋 0/4
👉 **[View detailed implementation](features/epic-11-feature-11.1.md)**

## Epic Dependencies

### Dependencies on Other Epics
- **Epic-06/08 (Maintenance)**: Reuses `send-notification.sh` failure-email pattern if archive jobs are later scheduled
- **NAS access**: Requires the TNAS SSH access established 2026-08-02 (port 2222, `id_ed25519`; see session memory `tnas-ssh-access-via-nas-lux`)

### Stories This Epic Enables
- Future retention policy for the rsync archive-mode mirrors (deletions age out to B2 instead of accumulating forever on the NAS)
- Future NAS-side scheduled archive sweeps (e.g. `Backup/nyx`, old Photos exports)

### Stories This Epic Blocks
- Deletion of the NAS `LTIMindtree-OneDrive-final-copy-2025-11` "only copy" status — nothing may delete that tree until 11.1-004 is verified complete

## Epic Delivery Planning

### Sprint Breakdown
| Sprint | Stories | Story Points | Sprint Goal |
|--------|---------|--------------|-------------|
| Sprint 15 | 11.1-001 to 11.1-004 | 13 | Verified offsite copies of all declared-irreplaceable data |

### Risk Assessment
**Low Risk Items**:
- All operations are additive (uploads); no source data is modified or deleted by any story
- rclone is mature and idempotent (`copy` never deletes)

**Medium Risk Items**:
- **Large upload (186GB)**: home upstream bandwidth may make the first upload multi-day. Mitigation: rclone resumes cleanly; run in `tmux` on the NAS; `--bwlimit` schedule to avoid saturating the line.
- **Credential handling**: B2 keys must never enter git. Mitigation: follow the existing untracked-file pattern (`~/.config/rclone/rclone.conf` on the NAS, chmod 600, documented in the feature file).

## Epic Progress Tracking

### Completion Status _(as of 2026-08-02)_
- **Stories Completed**: 0 of 4 (0%)
- **Story Points Completed**: 0 of 13 (0%)
