# ABOUTME: Configuration guide for Brave Browser
# Post-installation setup, Shields configuration, privacy features, and troubleshooting

### Brave Browser

**Status**: Installed via Homebrew cask `brave-browser` (Story 02.3-001)

**Purpose**: Privacy-focused browser with built-in ad/tracker blocking via Brave Shields. No extensions needed for ad blocking.

**First Launch**:
1. Launch Brave Browser from Spotlight, Raycast, or `/Applications/Brave Browser.app`
2. Welcome screen appears with onboarding wizard
3. Follow onboarding steps (optional):
   - Choose Brave as default browser (optional)
   - Import bookmarks and settings from other browsers (optional - Chrome, Safari, Firefox, Edge)
   - Choose search engine (DuckDuckGo default, can change to Google, Brave Search, etc.)
4. No sign-in required (optional: Sync across devices with Brave Sync)

**Update Management** (IMPORTANT):

Brave updates are **controlled by Homebrew**, not by in-app settings.

**How Brave Updates Work**:
- ✅ Brave updates are managed by Homebrew (installed via `brave-browser` cask)
- ✅ Updates ONLY occur when you run `darwin-rebuild switch` (rebuild command)
- ✅ Version is controlled by the Homebrew cask formula (managed by nix-darwin)
- ⚠️ **No in-app auto-update setting available** - Homebrew-managed apps don't expose this setting
- ⚠️ **Do NOT use "Check for updates" in Brave's About menu** - This is disabled for Homebrew installations

**Why No In-App Auto-Update Control?**:
- Homebrew-installed applications receive updates through Homebrew, not the app's built-in updater
- The app's auto-update mechanism is typically disabled or non-functional for Homebrew cask installations
- This is the **correct behavior** - it ensures updates are controlled via your declarative configuration

**Update Process**:
```bash
# To update Brave (along with all other apps):
darwin-rebuild switch  # Uses current flake.lock versions

# OR to get latest versions first:
nix flake update      # Updates flake.lock with latest package versions
darwin-rebuild switch # Applies the updates
```

**Brave Shields Configuration**:

Brave Shields is the built-in ad/tracker blocker. It's **enabled by default** and requires no configuration.

**How to Verify Shields is Working**:
1. Look for the **Brave Shields icon** (lion logo) in the address bar (right side)
2. Click the Shields icon to see:
   - **Trackers & ads blocked** (count)
   - **Upgrade connections to HTTPS** (on by default)
   - **Block scripts** (off by default, can enable for stricter blocking)
   - **Block fingerprinting** (Standard by default)
   - **Block cookies** (Cross-site by default)
3. Test on an ad-heavy website (e.g., news sites, YouTube):
   - Ads should be blocked automatically
   - Shield icon will show count of blocked items
   - Page loads faster with fewer trackers

**Per-Site Shields Settings**:
- Click Shields icon on any website to adjust settings for that specific site
- **Advanced View** button shows detailed controls:
  - Trackers & ads blocking (Aggressive/Standard/Allow)
  - Upgrade connections to HTTPS (On/Off)
  - Block scripts (On/Off - may break some sites)
  - Block fingerprinting (Strict/Standard/Allow)
  - Block cookies (All/Cross-site/Allow)

**Privacy Features**:

Brave includes several privacy features by default:

1. **HTTPS Everywhere** (Built-in):
   - Automatically upgrades HTTP connections to HTTPS
   - Enabled by default via Brave Shields
   - No extension needed

2. **Anti-Fingerprinting**:
   - Prevents websites from tracking you via browser fingerprinting
   - Randomizes browser attributes
   - Set to "Standard" by default (Settings → Shields → Fingerprinting blocking)

3. **Tracker/Ad Blocking via Shields**:
   - Blocks ads and trackers using built-in filter lists
   - Updates automatically (separate from browser updates)
   - More efficient than extension-based blockers

4. **Additional Privacy Settings**:
   - Navigate to **Settings** → **Privacy and security**
   - **WebRTC IP Handling**: Default Public IP only (prevents IP leak)
   - **Safe Browsing**: Standard protection (warns about dangerous sites)
   - **Send a "Do Not Track" request**: Can be enabled (optional)
   - **Clear browsing data on exit**: Can be configured (optional)

**Setting Brave as Default Browser** (Optional):

If you want Brave as your default browser:

1. Open **Brave** → **Settings** (Cmd+,)
2. Navigate to **Get started** or **Appearance** section
3. Click **Make Brave the default browser** button
4. macOS will prompt: "Do you want to change your default web browser?"
5. Click **Use "Brave"**

**Alternative Method**:
1. Open **System Settings** → **Desktop & Dock**
2. Scroll down to **Default web browser**
3. Select **Brave Browser** from dropdown

**Brave Sync** (Optional):

Brave Sync allows syncing bookmarks, extensions, history, and settings across devices:

1. Open **Brave** → **Settings** (Cmd+,)
2. Navigate to **Sync** (in left sidebar)
3. Click **Start a new Sync Chain**
4. Choose what to sync: Bookmarks, Extensions, History, Settings, Themes, Open Tabs, Passwords, Addresses
5. Use QR code or sync code to connect other devices
6. No account required (uses blockchain-based sync)

**Brave Rewards** (Optional):

Brave Rewards allows earning BAT cryptocurrency for viewing privacy-respecting ads:

1. Click **Brave Rewards** icon (triangle) in address bar
2. Click **Start using Brave Rewards**
3. Configure ad settings:
   - Ads per hour (0-10)
   - Ad notification preferences
4. Optional: Connect a wallet to withdraw earnings
5. **Note**: Not required for basic browser functionality

**Testing Checklist**:
- [ ] Launch Brave Browser successfully
- [ ] Complete onboarding wizard (import settings optional)
- [ ] Brave Shields icon visible in address bar
- [ ] Verify updates controlled by Homebrew (About Brave shows version, no auto-update toggle)
- [ ] Shields working: Test on ad-heavy site (YouTube, news site)
- [ ] Verify blocked ad/tracker count in Shields icon
- [ ] HTTPS upgrade working (visit HTTP site, check for HTTPS redirect)
- [ ] Privacy settings accessible and configured
- [ ] Can set as default browser (if desired)
- [ ] Accessible from Spotlight/Raycast

**Common Use Cases**:

1. **Daily Browsing with Ad Blocking**:
   - Brave Shields blocks ads and trackers automatically
   - No extension installation needed
   - Faster page loads, less data usage

2. **Privacy-Focused Research**:
   - Enable Private Window (Cmd+Shift+N)
   - Use Brave Search (built-in, privacy-respecting search engine)
   - Strict Shields settings for maximum privacy

3. **YouTube Without Ads**:
   - Brave blocks YouTube ads automatically
   - No YouTube Premium needed
   - Works in both standard and Private windows

4. **Cross-Browser Compatibility**:
   - Chromium-based (same engine as Chrome/Edge)
   - Compatible with Chrome extensions
   - Can import Chrome bookmarks and passwords

**Keyboard Shortcuts** (Same as Chrome):
- `Cmd+T` - New tab
- `Cmd+W` - Close tab
- `Cmd+Shift+T` - Reopen closed tab
- `Cmd+Shift+N` - New private window
- `Cmd+L` - Focus address bar
- `Cmd+R` - Reload page
- `Cmd+Shift+B` - Show/hide bookmarks bar
- `Cmd+,` - Settings

**Troubleshooting**:

1. **Shields breaking a website**:
   - Click Shields icon
   - Toggle "Shields" to **Down** for that specific site
   - Or adjust individual settings (allow scripts, cookies, etc.)
   - Add site to exceptions if permanently needed

2. **Updates not working as expected**:
   - **Expected behavior**: Brave updates are controlled by Homebrew, NOT by in-app settings
   - About Brave menu will show current version but no auto-update toggle (this is correct)
   - To update Brave: Run `darwin-rebuild switch` or `nix flake update && darwin-rebuild switch`
   - Do NOT use "Check for updates" button in About Brave (disabled for Homebrew installations)

3. **Import not working**:
   - Brave → Settings → Get Started → Import bookmarks and settings
   - Choose source browser (Chrome, Safari, Firefox, Edge)
   - Select items to import
   - Click "Import"

4. **Extensions not installing**:
   - Visit Chrome Web Store (Brave is Chromium-based)
   - Install extensions like normal Chrome browser
   - Most Chrome extensions work in Brave

**Integration with Development Workflow**:
- **Web development**: Chromium DevTools (same as Chrome)
- **Extension support**: Install from Chrome Web Store
- **Testing**: Cross-browser testing (Chromium engine)
- **Privacy**: Built-in ad blocking reduces dev noise

**Update Philosophy**:
- ✅ Brave updates ONLY via Homebrew (`rebuild` or `update` commands)
- ✅ In-app auto-update not available (Homebrew-managed installation)
- ✅ Versions controlled by Homebrew (managed by nix-darwin)
- ⚠️ Do NOT use "Check for updates" in About Brave menu (disabled for Homebrew installations)
- ✅ Brave Shields filter lists update automatically (separate from browser updates, this is expected)

**Brave Shields Filter Lists**:
- **Note**: Brave Shields uses ad/tracker filter lists that update independently
- These filter list updates are **separate** from browser updates
- Filter lists update automatically in the background (this is expected and safe)
- Browser version updates are still controlled by Homebrew only

**Known Issues**:
- **Shields too aggressive**: Some sites may break with default Shields settings (disable per-site)
- **Compatibility**: Chromium-based, so Chrome-specific bugs may affect Brave too
- **Memory usage**: Similar to Chrome (can be high with many tabs)

**Resources**:
- Brave Documentation: https://support.brave.com/
- Brave Shields Guide: https://support.brave.com/hc/en-us/articles/360022973471-What-is-Shields-
- Privacy Features: https://brave.com/privacy-features/
- Brave Search: https://search.brave.com/
- Chrome Web Store (extensions): https://chrome.google.com/webstore

---

## Related Documentation

- [Main Apps Index](../README.md) - Overview of all application documentation
- [Arc Browser](arc.md) - Modern workspace-focused browser configuration
- [Parent Document](../../app-post-install-configuration.md) - Full application post-install configuration guide
