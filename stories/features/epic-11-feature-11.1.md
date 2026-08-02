# ABOUTME: Epic-11 Feature 11.1 (B2 Archive Pipeline) implementation details
# ABOUTME: rclone/B2 setup, NAS-side bundling script, upload+verify workflow, first archive executions

# Epic-11 Feature 11.1: B2 Archive Pipeline

## Feature Overview

**Feature ID**: Feature 11.1
**Feature Name**: B2 Archive Pipeline
**Epic**: Epic-11
**Status**: 📋 Planned

### Feature 11.1: B2 Archive Pipeline
**Feature Description**: Stand up a Backblaze B2 bucket with rclone access from the NAS, build a bundling script that turns any NAS directory into a checksummed `tar.zst` archive, define the upload+verify+ledger workflow, and execute it for the two archives identified in the 2026-08-02 audit.
**User Value**: Irreplaceable data gains a verified offsite copy; cold data becomes safely deletable from warm tiers
**Story Count**: 4
**Story Points**: 13
**Priority**: Must Have (P0)
**Complexity**: Medium

#### Stories in This Feature

---

##### Story 11.1-001: rclone + B2 Remote Setup
**User Story**: As FX, I want rclone installed on the NAS and configured against a new B2 bucket so that archives can upload directly from the NAS without transiting the Mac

**Priority**: Must Have
**Story Points**: 3
**Sprint**: Sprint 15

**Acceptance Criteria**:
- **Given** a B2 account with a new private bucket (e.g. `fxm-archive`) and an application key scoped to that bucket
- **When** `rclone lsd b2-archive:` runs on the NAS over SSH
- **Then** it lists the bucket without error
- **And** `~/.config/rclone/rclone.conf` on the NAS is chmod 600 and never enters git
- **And** the bucket has default encryption enabled and no lifecycle rule that auto-deletes

**Technical Notes**:
- NAS is x86_64 Linux (TOS 6, kernel 6.1) — install the static rclone binary to `~/bin/rclone` on the NAS (no TOS package needed); document the install command in the story PR
- SSH access: `ssh -i ~/.ssh/id_ed25519 -o IdentitiesOnly=yes -p 2222 fxmartin@tnas.local`
- Consider `rclone config` crypt overlay later; NOT in scope (B2 server-side encryption + private bucket suffices for v1)
- Decision recorded 2026-08-02: **B2 over S3 Glacier Deep Archive** — instant access, free egress up to 3× stored, `rclone check` verification; at ≤400GB total the ~$6/TB/mo premium is negligible vs restore ergonomics

---

##### Story 11.1-002: `nas-archive.sh` Bundling Script
**User Story**: As FX, I want a script that bundles any NAS directory into a `tar.zst` + SHA256 manifest so that archives are single objects with verifiable integrity

**Priority**: Must Have
**Story Points**: 5
**Sprint**: Sprint 15

**Acceptance Criteria**:
- **Given** `nas-archive.sh bundle <source-dir> <archive-name>` run on the NAS
- **When** it completes
- **Then** `/Volume1/Data/Archives/_staging/<archive-name>.tar.zst` exists
- **And** `<archive-name>.sha256` contains the bundle checksum
- **And** `<archive-name>.filelist.txt.zst` contains the full file listing (so contents are searchable without a restore)
- **And** the script refuses to run if staging free space < source size
- **And** re-running with an existing bundle name aborts (no silent overwrite)

**Additional Requirements**:
- `set -euo pipefail` with the pipeline guards documented in CLAUDE.md (Shell & Script Gotchas)
- Progress output suitable for `tmux` sessions (multi-hour runs on 186GB)
- Lives in `scripts/nas-archive.sh` in this repo; synced to NAS `~/bin/` manually or via the story PR's documented step

**Technical Notes**:
- `tar -I 'zstd -T0 -10' -cf` — zstd level 10 multithread; F8 SSD NAS has cycles to spare
- Checksum with `sha256sum` (Linux) — do not reuse macOS `shasum` syntax
- bats tests for argument validation / refusal paths run against a temp dir (safe suite)

---

##### Story 11.1-003: Upload + Verify + Ledger Workflow
**User Story**: As FX, I want `nas-archive.sh upload <archive-name>` to push a bundle to B2, verify it, and record it in a ledger so that "archived" always means "verified offsite"

**Priority**: Must Have
**Story Points**: 3
**Sprint**: Sprint 15

**Acceptance Criteria**:
- **Given** a staged bundle from 11.1-002
- **When** `nas-archive.sh upload <archive-name>` completes
- **Then** the bundle + `.sha256` + `.filelist.txt.zst` exist in `b2-archive:fxm-archive/<archive-name>/`
- **And** `rclone check` (or `rclone sha1sum`/size comparison) confirms integrity and is logged
- **And** `/Volume1/Data/Archives/LEDGER.md` gains a row: date, archive name, source path, size, SHA256, B2 path
- **And** the workflow prints an explicit reminder that source deletion is a separate, manual decision

**Technical Notes**:
- `rclone copy --transfers 4 --checkers 8 --bwlimit "08:00,2M 23:00,off"` — tune to home upstream; resumable
- Ledger is markdown on the NAS **and** mirrored into `docs/archives/LEDGER.md` in this repo (repo copy is the durable index; no secrets in it)
- Failure → non-zero exit; email integration via `send-notification.sh` only if/when scheduled (not in scope)

---

##### Story 11.1-004: Execute First Archives (LTIMindtree + Outlook 2014)
**User Story**: As FX, I want the LTIMindtree OneDrive copy and the 2014 Outlook archives bundled, uploaded, verified, and test-restored so that no irreplaceable data has a single copy

**Priority**: Must Have
**Story Points**: 2
**Sprint**: Sprint 15

**Acceptance Criteria**:
- **Given** stories 11.1-001..003 complete
- **When** the pipeline runs for both sources
- **Then** B2 contains verified bundles for:
  - `/Volume1/Data/Archives/LTIMindtree-OneDrive-final-copy-2025-11` (~186GB source)
  - `/Volume1/icloud/Documents/00. Archives` (Outlook 2014 mbox + `OffLineArchive.pst`, ~4GB)
- **And** one bundle (the small one) is downloaded back, checksum-verified, and opened as a restore test
- **And** LEDGER.md records both archives and the restore test
- **And** the `README.txt` in the LTIMindtree folder is updated: "only remaining copy" → "offsite copy verified <date>, B2 <path>"

**Additional Requirements**:
- The NAS source trees are NOT deleted in this story — eviction decisions are explicitly out of scope
- Multi-day upload acceptable; run in `tmux` on the NAS

**Technical Notes**:
- 186GB at typical 20–50 Mbit/s upstream ≈ 9–20 hours minimum; `--bwlimit` daytime throttle recommended
- After this story, monthly B2 cost ≈ $1.20 at ~200GB
