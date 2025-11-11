# ABOUTME: Post-installation configuration steps for installed applications
# ABOUTME: Documents manual settings that cannot be automated (auto-update disable, preferences, etc.)

# Application Post-Install Configuration Guide

This document provides step-by-step instructions for configuring applications after nix-darwin installation completes.

**Philosophy**: All app updates are controlled via `rebuild` or `update` commands only. Auto-updates must be disabled for all apps that support this setting.

---

## Table of Contents

- [AI & LLM Tools](#ai--llm-tools)
  - [Claude Desktop](#claude-desktop)
  - [ChatGPT Desktop](#chatgpt-desktop)
  - [Perplexity](#perplexity)

---

## AI & LLM Tools

### Claude Desktop

**Status**: Installed via Homebrew cask `claude` (Story 02.1-001)

**First Launch**:
1. Launch Claude Desktop from Spotlight or Raycast
2. Sign in with your Anthropic account
3. Complete the onboarding flow

**Auto-Update Configuration**:
- **Current Status**: ⚠️ **Requires Manual Check**
- **Steps to Disable** (if available):
  1. Open Claude Desktop
  2. Navigate to **Preferences** (Cmd+,) or **Settings**
  3. Look for **General** or **Updates** section
  4. Disable automatic update checking if option exists
  5. Document actual steps after first VM test

**Testing**:
- [ ] Launch Claude Desktop successfully
- [ ] Sign-in flow completes
- [ ] Accessible from Spotlight/Raycast
- [ ] Check for auto-update setting in preferences

---

### ChatGPT Desktop

**Status**: Installed via Homebrew cask `chatgpt` (Story 02.1-001)

**First Launch**:
1. Launch ChatGPT Desktop from Spotlight or Raycast
2. Sign in with your OpenAI account
3. Complete the onboarding flow

**Auto-Update Configuration**:
- **Current Status**: ⚠️ **Requires Manual Check**
- **Steps to Disable** (if available):
  1. Open ChatGPT Desktop
  2. Navigate to **Preferences** (Cmd+,) or **Settings**
  3. Look for **General** or **Updates** section
  4. Disable automatic update checking if option exists
  5. Document actual steps after first VM test

**Testing**:
- [ ] Launch ChatGPT Desktop successfully
- [ ] Sign-in flow completes
- [ ] Accessible from Spotlight/Raycast
- [ ] Check for auto-update setting in preferences

---

### Perplexity

**Status**: Installed via Homebrew cask `perplexity` (Story 02.1-001)

**First Launch**:
1. Launch Perplexity from Spotlight or Raycast
2. Sign in with your Perplexity account (if required)
3. Complete the onboarding flow

**Auto-Update Configuration**:
- **Current Status**: ⚠️ **Requires Manual Check**
- **Steps to Disable** (if available):
  1. Open Perplexity
  2. Navigate to **Preferences** (Cmd+,) or **Settings**
  3. Look for **General** or **Updates** section
  4. Disable automatic update checking if option exists
  5. Document actual steps after first VM test

**Testing**:
- [ ] Launch Perplexity successfully
- [ ] Sign-in flow completes (if required)
- [ ] Accessible from Spotlight/Raycast
- [ ] Check for auto-update setting in preferences

---

## Notes for FX

**VM Testing Workflow**:
1. After `darwin-rebuild switch`, verify all apps are installed in `/Applications`
2. Launch each app and complete the first-run setup
3. Check preferences for auto-update settings
4. Document actual steps found during testing
5. Update this file with confirmed steps

**Update Control Philosophy**:
- ✅ All app updates ONLY via `rebuild` or `update` commands
- ✅ Homebrew auto-update disabled globally (`HOMEBREW_NO_AUTO_UPDATE=1`)
- ⚠️ Some apps may not expose auto-update toggle (document as "no setting available")
- ✅ Apps without auto-update settings will still be controlled via Homebrew version pinning

**Common Auto-Update Locations**:
- Preferences → General → Updates
- Settings → Advanced → Auto-update
- Menu Bar → App Name → Preferences → Updates
- Some apps use system Sparkle updater (check "Check for updates" menu item)

---

## Story Tracking

**Story 02.1-001**: Claude Desktop, ChatGPT, Perplexity - ✅ Installation implemented, ⚠️ Auto-update configuration pending VM test

---
