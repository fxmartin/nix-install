# ABOUTME: Epic-02 Feature 02.6 (Media & Creative Tools) implementation details
# ABOUTME: Contains story implementation, testing results, and validation for Feature 02.6

# Epic-02 Feature 02.6: Media & Creative Tools

## Feature Overview

**Feature ID**: Feature 02.6
**Feature Name**: Media & Creative Tools
**Epic**: Epic-02
**Status**: 🔄 In Progress

### Feature 02.6: Media & Creative Tools
**Feature Description**: Install media players and image editing software
**User Value**: Support for media consumption and basic image editing
**Story Count**: 1
**Story Points**: 3
**Priority**: Medium
**Complexity**: Low

#### Stories in This Feature

##### Story 02.6-001: VLC and GIMP Installation
**User Story**: As FX, I want VLC and GIMP installed so that I can play videos and edit images

**Priority**: Must Have
**Story Points**: 3
**Sprint**: Sprint 3

**Acceptance Criteria**:
- **Given** darwin-rebuild completes successfully
- **When** I launch VLC
- **Then** it opens and can play video files
- **And** VLC auto-update is disabled (Preferences → General)
- **When** I launch GIMP
- **Then** it opens and I can edit images
- **And** both apps are accessible from Spotlight/Raycast

**Additional Requirements**:
- VLC: Homebrew Cask (media player)
- GIMP: Homebrew Cask (image editor)
- Auto-update disable for VLC

**Technical Notes**:
- Homebrew casks: `vlc`, `gimp`
- Add to darwin/homebrew.nix casks list
- VLC auto-update: Preferences → General → Uncheck "Automatically check for updates"
- GIMP: No auto-update to disable

**Definition of Done**:
- [ ] Both apps installed via homebrew.nix
- [ ] VLC launches and plays video
- [ ] GIMP launches and edits images
- [ ] VLC auto-update disabled
- [ ] Tested in VM
- [ ] Documentation notes basic usage

**Dependencies**:
- Epic-01, Story 01.5-001 (Homebrew managed)

**Risk Level**: Low
**Risk Mitigation**: N/A

---

## Story 02.6-001 Implementation Details

**Implementation Date**: 2025-01-15

**Changes Made**:

1. **darwin/homebrew.nix**:
   - Added `vlc` Homebrew cask for VLC Media Player
   - Added `gimp` Homebrew cask for GIMP image editor
   - Added "Media & Creative Tools" section with auto-update notes
   - VLC: Auto-update disable required (Preferences → General)
   - GIMP: No auto-update to disable (open source, Homebrew-controlled)

2. **docs/apps/media/** (VLC, GIMP):
   - Added "Media & Creative Tools" section to Table of Contents
   - **VLC Media Player** documentation (~275 lines):
     - **Auto-Update Disable** (CRITICAL - documented prominently with verification)
     - Overview: Universal media player, 100+ format support
     - First Launch: Privacy dialog, interface customization
     - Core Features: Format support, playback controls, audio/video adjustments, subtitle management, playlist management, network streaming
     - Common Use Cases: Playing videos, DVDs, loading subtitles, audio/video sync, streaming online, setting as default player
     - Advanced Features: Video conversion, screen recording, audio visualization, screenshots, audio passthrough
     - Keyboard Shortcuts: Essential playback shortcuts (15 shortcuts)
     - Configuration Tips: Interface, resume playback, file association, performance, subtitle font
     - Troubleshooting: Video playback, subtitles, sync issues, performance, DVD encryption, streams
     - Testing Checklist: 14 items
   - **GIMP** documentation (~315 lines):
     - No Auto-Update to Disable (open source, Homebrew-managed)
     - Overview: Free image editor, Photoshop alternative
     - First Launch: Interface layout (toolbox, canvas, docks), single-window mode
     - Interface Layout: Toolbox panel, canvas area, docks panel
     - Core Features: Layer management, selection tools, painting/drawing, filters/effects, color correction, text tools
     - File Format Support: Native XCF, import/export formats, export vs save
     - Common Use Cases: Editing photos, cropping, resizing, removing background, adding text, color adjustment, new image creation, batch processing
     - Interface Customization: Single-window mode, dark theme, toolbox customization, keyboard shortcuts
     - Essential Keyboard Shortcuts: 13 shortcuts
     - Learning Resources: Built-in help, official tutorials, third-party resources
     - Troubleshooting: Performance, text quality, export issues, layers, color picker, brush problems
     - Testing Checklist: 15 items
   - Total documentation: 590+ lines for both apps

3. **Key Implementation Decisions**:
   - Verified cask names: `vlc` and `gimp` confirmed in Homebrew
   - VLC auto-update strategy: Disable in preferences (MANDATORY)
   - GIMP auto-update strategy: None required (Homebrew-controlled)
   - Free apps with no licensing requirements
   - Both accessible from Spotlight/Raycast after installation

**VM Testing Checklist** (25 items):

**Pre-Testing Setup**:
- [ ] VM snapshot created (restore point before testing)
- [ ] darwin-rebuild completed successfully
- [ ] No build errors or warnings

**VLC Media Player Testing** (13 items):
1. **Installation & Launch**:
   - [ ] VLC installed via Homebrew cask
   - [ ] VLC launches from Spotlight (`Cmd+Space`, type "VLC")
   - [ ] VLC accessible from `/Applications/VLC.app`
   - [ ] First launch privacy dialog appears (decline update check)

2. **Auto-Update Disable (CRITICAL)**:
   - [ ] Open VLC Preferences (`Cmd+,`)
   - [ ] Navigate to General or Interface tab
   - [ ] Locate "Automatically check for updates" checkbox
   - [ ] Verify checkbox is UNCHECKED (or uncheck it manually)
   - [ ] Restart VLC to confirm setting persists

3. **Core Functionality**:
   - [ ] Can play video file (drag and drop .mp4 or .mov file)
   - [ ] Video plays with audio and video in sync
   - [ ] Can play audio file (drag and drop .mp3 file)
   - [ ] Audio plays correctly
   - [ ] Subtitle loading works (create test.srt file, drag into player)
   - [ ] Subtitles appear on video

4. **Feature Testing**:
   - [ ] Volume controls work (up/down, including >100% boost)
   - [ ] Fullscreen mode works (press `F` or `Cmd+F`)
   - [ ] Playback speed control works (`[` slower, `]` faster)
   - [ ] Can stream online video (File → Open Network → paste URL)
   - [ ] Keyboard shortcuts functional (Space, arrows, volume controls)
   - [ ] Can take screenshot (Video → Take Snapshot or `Cmd+Alt+S`)

5. **Configuration & Performance**:
   - [ ] Hardware acceleration enabled (Preferences → Input/Codecs → Hardware-accelerated decoding)
   - [ ] Resume playback works (stop video, reopen, continues from last position)
   - [ ] No performance issues or stuttering during 4K video playback
   - [ ] Documentation matches actual VLC interface and features

**GIMP Testing** (12 items):
1. **Installation & Launch**:
   - [ ] GIMP installed via Homebrew cask
   - [ ] GIMP launches from Spotlight (`Cmd+Space`, type "GIMP")
   - [ ] GIMP accessible from `/Applications/GIMP.app`
   - [ ] First launch completes (plugin initialization ~10 seconds)
   - [ ] Main interface appears (Toolbox, Canvas, Docks)

2. **Interface & Configuration**:
   - [ ] Single-window mode works (Windows → Single-Window Mode)
   - [ ] Dark theme enabled (Edit → Preferences → Interface → Theme: Dark)
   - [ ] All three panels visible (Toolbox left, Canvas center, Docks right)

3. **Core Functionality**:
   - [ ] Can create new image (File → New)
   - [ ] Can open existing image (File → Open → select .jpg or .png)
   - [ ] Can select and use basic tools (brush, eraser, crop, text)
   - [ ] Layers panel visible and functional (create layer, adjust opacity)
   - [ ] Can apply filters (Filters → Blur → Gaussian Blur)
   - [ ] Can adjust colors (Colors → Brightness-Contrast)

4. **File Operations**:
   - [ ] Can save as XCF (File → Save → test.xcf)
   - [ ] Can export as PNG (File → Export As → test.png)
   - [ ] Can export as JPEG (File → Export As → test.jpg)
   - [ ] Exported files open correctly in Preview/Finder

5. **Advanced Testing**:
   - [ ] Undo/Redo works (`Cmd+Z` / `Cmd+Y`)
   - [ ] Can add text to image (Text tool `T`, click, type text)
   - [ ] Can remove background (Layer → Transparency → Add Alpha Channel → Fuzzy Select → Delete)
   - [ ] Help system accessible (Help → User Manual)
   - [ ] No performance issues during basic editing operations
   - [ ] Documentation matches actual GIMP interface and features

**General Testing**:
- [ ] Both apps accessible from Spotlight search
- [ ] Both apps accessible from Raycast (if installed)
- [ ] VLC auto-update disabled (re-verify after full testing)
- [ ] No conflicts with other installed apps
- [ ] System performance stable with both apps installed

**Documentation Accuracy**:
- [ ] VLC documentation matches actual app interface and features
- [ ] GIMP documentation matches actual app interface and features
- [ ] All testing checklist items in documentation are accurate
- [ ] Troubleshooting guides reflect actual issues and solutions

---

