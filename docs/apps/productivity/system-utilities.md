# ABOUTME: Stream Deck post-installation configuration guide
# ABOUTME: Covers the retained hardware macro controller companion app

## Stream Deck

**Status**: Installed via Homebrew cask `elgato-stream-deck`

**Purpose**: Elgato Stream Deck companion app for configuring hardware keys, profiles, actions, plugins, and device firmware.

**First Launch**:

1. Connect the Stream Deck device via USB.
2. Launch Stream Deck from Spotlight (`Cmd+Space`, type "Stream Deck") or from `/Applications/Stream Deck.app`.
3. Grant only the macOS permissions required by enabled actions, such as Accessibility for system controls or Automation for app integrations.
4. Create or import profiles and assign actions to hardware keys.

**Auto-Update Configuration**:

- Stream Deck declares Homebrew `auto_updates`, so the app may manage its own updates.
- Prefer updates through this repo's normal `rebuild` or `update` flow when possible.
- If the app exposes an auto-update preference, disable it to keep updates controlled with the rest of the system.

**Testing Checklist**:

- [ ] Stream Deck installed and launches
- [ ] Device is detected when connected
- [ ] Can create or select a profile
- [ ] Can assign an action to a key
- [ ] Key press triggers the assigned action
- [ ] Required macOS permissions are granted only for actions that need them

**Documentation**:

- Official Downloads: https://www.elgato.com/ww/en/s/downloads
- Help Center: https://help.elgato.com/

---

## Related Documentation

- [Main Apps Index](../README.md) - Overview of all application documentation
- [Raycast Configuration](./raycast.md) - Productivity launcher setup
- [1Password Configuration](./1password.md) - Password manager setup
- [File Utilities Configuration](./file-utilities.md) - Calibre, Kindle, Keka, Marked 2
