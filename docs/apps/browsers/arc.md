# ABOUTME: Configuration guide for Arc Browser
# Post-installation setup, Spaces workspaces, command palette, and workspace management

### Arc Browser

**Status**: Installed via Homebrew cask `arc` (Story 02.3-002)

**Purpose**: Modern, workspace-focused browser with unique vertical sidebar UI, Spaces feature for context separation, and innovative command palette for power users.

**First Launch**:
1. Launch Arc from Spotlight, Raycast, or `/Applications/Arc.app`
2. Welcome screen appears with onboarding wizard
3. **Account Required**: Arc requires sign-in for sync features and full functionality
   - Sign in with email (creates Arc account)
   - Or sign in with Google account
4. Complete onboarding steps:
   - Choose your workspace name (e.g., "Work", "Personal")
   - Import bookmarks from other browsers (optional - Chrome, Safari, Firefox, Brave)
   - Watch Arc tutorial (recommended for first-time users)
5. Arc will display sidebar with Spaces and vertical tabs

**Update Management** (IMPORTANT):

Arc updates are **controlled by Homebrew**, not by in-app settings.

**How Arc Updates Work**:
- ✅ Arc updates are managed by Homebrew (installed via `arc` cask)
- ✅ Updates ONLY occur when you run `darwin-rebuild switch` (rebuild command)
- ✅ Version is controlled by the Homebrew cask formula (managed by nix-darwin)
- ⚠️ **No in-app auto-update setting available** - Homebrew-managed apps don't expose this setting
- ⚠️ **Do NOT use "Check for updates" in Arc's About menu** - This is disabled for Homebrew installations

**Why No In-App Auto-Update Control?**:
- Homebrew-installed applications receive updates through Homebrew, not the app's built-in updater
- The app's auto-update mechanism is typically disabled or non-functional for Homebrew cask installations
- This is the **correct behavior** - it ensures updates are controlled via your declarative configuration

**Update Process**:
```bash
# To update Arc (along with all other apps):
darwin-rebuild switch  # Uses current flake.lock versions

# OR to get latest versions first:
nix flake update      # Updates flake.lock with latest package versions
darwin-rebuild switch # Applies the updates
```

**Arc Features**:

Arc introduces several unique features that differentiate it from traditional browsers:

1. **Spaces** (Workspaces for different contexts):
   - Create separate Spaces for Work, Personal, Projects, etc.
   - Each Space has its own set of tabs, favorites, and appearance
   - Switch between Spaces using Cmd+S or sidebar
   - Keeps contexts separate (e.g., Work Gmail vs Personal Gmail)

2. **Vertical Sidebar with Tabs**:
   - Tabs displayed vertically on left side (more screen space for content)
   - Auto-hide sidebar (moves out of the way when not needed)
   - Pin frequently used tabs at top of sidebar
   - Unpinned tabs auto-archive after 12 hours (configurable)

3. **Command Palette** (Cmd+T):
   - Quick access to tabs, history, bookmarks, settings
   - Type to search open tabs, recently closed tabs, bookmarks
   - Perform actions (create new tab, switch Space, etc.)
   - Similar to VSCode/Zed command palette for browsers

4. **Split View**:
   - View multiple tabs side-by-side
   - Drag tabs to split screen horizontally or vertically
   - Resize splits dynamically
   - Great for research, documentation, development

5. **Boosts** (Customize any website):
   - Custom CSS/JavaScript for any website
   - Change appearance, hide elements, add features
   - Share Boosts with others
   - Power user customization

6. **Built-in Note Taking**:
   - Create "Easel" notes directly in Arc
   - Capture screenshots, links, text
   - Organize alongside tabs
   - No external note-taking app needed

7. **Tab Management**:
   - **Pinned Tabs**: Always visible at top of sidebar
   - **Favorites**: Frequently accessed sites (live previews)
   - **Today Tabs**: Unpinned tabs auto-archive after 12 hours (customizable)
   - **Little Arc**: Minimal browser window for quick searches (Cmd+Shift+N)

**First-Time Setup**:

After launching Arc for the first time:

1. **Create Account** (Required):
   - Sign in with email or Google account
   - Account enables sync across devices
   - No paid tier required for core features

2. **Set Up First Space**:
   - Name your first Space (e.g., "Work", "Personal")
   - Choose a color/icon for the Space
   - Add favorite websites to sidebar

3. **Import from Other Browsers** (Optional):
   - Arc → Settings → Import
   - Select source browser (Chrome, Safari, Firefox, Brave)
   - Choose what to import: Bookmarks, Passwords, History
   - Click "Import"

4. **Configure Tab Auto-Archive** (Optional):
   - Arc → Settings → General → Archive Tabs
   - Default: Archive unpinned tabs after 12 hours
   - Options: Never, 1 day, 7 days, 30 days
   - Pinned tabs never auto-archive

5. **Set as Default Browser** (Optional):
   - Arc → Settings → General
   - Click "Set Arc as Default Browser"
   - macOS will prompt for confirmation
   - Click "Use Arc"

**Using Spaces (Workspaces)**:

Spaces are Arc's killer feature - separate workspaces for different contexts:

**Creating a New Space**:
1. Click **+** button at bottom of sidebar
2. Or press **Cmd+S** → "Create New Space"
3. Name the Space (e.g., "Personal", "Side Projects", "Learning")
4. Choose color and icon
5. Add favorite sites to the Space

**Switching Spaces**:
- Press **Cmd+S** → Select Space from list
- Or click Space icon at bottom of sidebar
- Each Space maintains its own tabs and favorites

**Use Cases for Spaces**:
- **Work vs Personal**: Separate professional and personal browsing
- **Projects**: Dedicated Space for each client or project
- **Learning**: Space for courses, documentation, tutorials
- **Shopping**: Temporary Space for research and comparisons
- **Banking/Finance**: Isolated Space for sensitive sites

**Command Palette** (Power User Feature):

Press **Cmd+T** to open the command palette:

**What You Can Do**:
- **Search open tabs**: Type tab title to switch instantly
- **Search history**: Access recently closed or visited tabs
- **Search bookmarks**: Find saved sites quickly
- **Quick actions**: "New Space", "New Incognito Window", "Settings"
- **URL entry**: Type URL or search query directly

**Keyboard Shortcuts**:
- `Cmd+T` - Open command palette (tabs, history, bookmarks)
- `Cmd+S` - Switch Spaces
- `Cmd+Option+N` - New Space
- `Cmd+Shift+N` - Little Arc (minimal browser window)
- `Cmd+W` - Close tab
- `Cmd+Shift+T` - Reopen closed tab
- `Cmd+L` - Focus address bar
- `Cmd+Shift+D` - Split view (horizontal)
- `Cmd+Shift+\` - Split view (vertical)
- `Cmd+1/2/3...` - Switch to pinned tab 1, 2, 3, etc.
- `Cmd+Option+Up/Down` - Navigate between tabs
- `Cmd+,` - Settings

**Setting Arc as Default Browser** (Optional):

If you want Arc as your default browser:

**Method 1: Via Arc Settings**:
1. Open **Arc** → **Settings** (Cmd+,)
2. Navigate to **General** section
3. Click **Set Arc as Default Browser** button
4. macOS will prompt: "Do you want to change your default web browser to Arc?"
5. Click **Use "Arc"**

**Method 2: Via macOS System Settings**:
1. Open **System Settings** → **Desktop & Dock**
2. Scroll down to **Default web browser**
3. Select **Arc** from dropdown

**Arc Sync** (Automatic):

Arc Sync is built-in and automatic (requires account sign-in):

**What Syncs**:
- Spaces and their configurations
- Tabs (pinned and unpinned)
- Favorites
- Boosts (custom website modifications)
- Settings and preferences
- Browsing history
- Passwords (via iCloud Keychain integration)

**How to Verify Sync**:
1. Arc → Settings → Account
2. Shows: "Syncing to [your email]"
3. Sync happens automatically when changes are made

**Privacy and Security**:

Arc includes several privacy features:

1. **Tracking Prevention**:
   - Blocks third-party trackers by default
   - Similar to Safari's Intelligent Tracking Prevention
   - Arc → Settings → Privacy → Tracking Prevention (on by default)

2. **Ad Blocking**:
   - **Note**: Arc does NOT have built-in ad blocking like Brave
   - Use extensions: uBlock Origin, AdGuard, etc. (from Chrome Web Store)
   - Arc is Chromium-based, so Chrome extensions work

3. **HTTPS Enforcement**:
   - Automatically upgrades to HTTPS when available
   - Warns about insecure connections

4. **Incognito Mode**:
   - Press **Cmd+Shift+N** for Little Arc (minimal private window)
   - Or create Incognito Space: Arc → New Incognito Space
   - No browsing history or cookies saved

**Extension Support**:

Arc is Chromium-based and supports Chrome extensions:

1. Visit **Chrome Web Store**: https://chrome.google.com/webstore
2. Search for extension (e.g., "uBlock Origin", "1Password", "Grammarly")
3. Click "Add to Chrome" (works for Arc)
4. Extension appears in Arc toolbar

**Recommended Extensions for Privacy**:
- **uBlock Origin**: Ad and tracker blocking
- **Privacy Badger**: Automatic tracker blocking
- **HTTPS Everywhere**: Force HTTPS (Arc has this built-in, but extension adds more)
- **Bitwarden** or **1Password**: Password management

**Testing Checklist**:
- [ ] Launch Arc successfully
- [ ] Account sign-in completes (email or Google)
- [ ] Onboarding wizard completes
- [ ] Create first Space (name, color, icon)
- [ ] Add pinned tabs to sidebar
- [ ] Test Command Palette (Cmd+T) - search tabs, history
- [ ] Create second Space to test workspace switching
- [ ] Test Split View (Cmd+Shift+D or Cmd+Shift+\)
- [ ] Verify updates controlled by Homebrew (About Arc shows version, no auto-update toggle)
- [ ] Import bookmarks from another browser (optional test)
- [ ] Test tab auto-archive (unpinned tabs archived after 12 hours)
- [ ] Verify accessible from Spotlight/Raycast
- [ ] Set as default browser (optional)

**Common Use Cases**:

1. **Work and Personal Separation**:
   - **Work Space**: Gmail (work), Slack, GitHub, AWS Console
   - **Personal Space**: Gmail (personal), YouTube, Reddit, Social Media
   - Switch with Cmd+S, keep contexts completely separate

2. **Multi-Project Development**:
   - **Client A Space**: Jira, GitHub repos, documentation, staging site
   - **Client B Space**: Different repos, tools, production sites
   - **Side Project Space**: Personal GitHub, localhost, docs
   - No tab confusion, instant context switching

3. **Research and Learning**:
   - **Learning Space**: Course platform, documentation, tutorials, notes
   - Split view for video + code editor (or notes)
   - Archive tabs automatically after completing lessons

4. **Content Creation**:
   - **Writing Space**: Google Docs, research tabs, references
   - **Design Space**: Figma, inspiration sites, resources
   - Boosts to customize tools (hide distractions, custom CSS)

**Troubleshooting**:

1. **Tabs disappearing (auto-archived)**:
   - Default: Unpinned tabs auto-archive after 12 hours
   - **Fix**: Pin important tabs (drag to "Pinned" section at top of sidebar)
   - **Or change setting**: Arc → Settings → General → Archive Tabs → Never (or longer duration)
   - **Access archived tabs**: Command Palette (Cmd+T) → Search history

2. **Updates not working as expected**:
   - **Expected behavior**: Arc updates are controlled by Homebrew, NOT by in-app settings
   - About Arc menu will show current version but no auto-update toggle (this is correct)
   - To update Arc: Run `darwin-rebuild switch` or `nix flake update && darwin-rebuild switch`
   - Do NOT use "Check for updates" button in About Arc (disabled for Homebrew installations)

3. **Sync not working**:
   - Verify signed in: Arc → Settings → Account (should show email)
   - Check internet connection
   - Sign out and sign back in: Arc → Settings → Account → Sign Out → Sign In

4. **Extensions not working**:
   - Arc is Chromium-based - use Chrome Web Store
   - Some Firefox-only extensions won't work
   - Most Chrome extensions are compatible

5. **Sidebar auto-hiding too aggressively**:
   - Arc → Settings → Appearance → Sidebar → "Always show sidebar" (optional)
   - Or hover over left edge to reveal sidebar
   - Pinned: Cmd+S (keeps sidebar visible)

6. **Account sign-in required (cannot skip)**:
   - Arc requires account for full functionality
   - Unlike Brave/Chrome, no anonymous mode for main browser
   - Use Little Arc (Cmd+Shift+N) for quick anonymous browsing

**Integration with Development Workflow**:
- **Web development**: Chromium DevTools (same as Chrome/Brave)
- **Spaces for environments**: Dev Space, Staging Space, Production Space
- **Split view**: Code + preview side-by-side
- **Boosts**: Custom CSS for local development sites
- **Extension support**: React DevTools, Vue DevTools, Redux DevTools (from Chrome Web Store)

**Update Philosophy**:
- ✅ Arc updates ONLY via Homebrew (`rebuild` or `update` commands)
- ✅ In-app auto-update not available (Homebrew-managed installation)
- ✅ Versions controlled by Homebrew (managed by nix-darwin)
- ⚠️ Do NOT use "Check for updates" in About Arc menu (disabled for Homebrew installations)
- ✅ Account sync happens automatically (separate from app updates, this is expected)

**Arc vs Other Browsers**:

**Arc vs Brave**:
- **Privacy**: Brave has stronger built-in privacy (Shields, ad blocking) | Arc requires extensions
- **Workspaces**: Arc Spaces are superior | Brave has traditional tab groups
- **UI**: Arc has unique vertical sidebar | Brave is traditional Chrome-like
- **Updates**: Both controlled by Homebrew (no in-app settings)
- **Account**: Arc requires sign-in | Brave is optional

**Arc vs Chrome**:
- **UI**: Arc vertical sidebar + Spaces | Chrome traditional horizontal tabs
- **Privacy**: Arc has better default privacy | Chrome tracks more
- **Features**: Arc has Boosts, Easel, Little Arc | Chrome is minimal
- **Performance**: Both Chromium-based (similar performance)
- **Extensions**: Both support Chrome Web Store

**Arc vs Safari**:
- **Privacy**: Safari has superior privacy (Apple's ITP) | Arc is good but not Safari-level
- **Features**: Arc has Spaces, Boosts, Split View | Safari is simpler
- **Performance**: Safari better battery life | Arc uses more resources
- **Cross-platform**: Arc (Mac, Windows, iOS, Android) | Safari (Apple only)

**Known Issues**:
- **Account required**: Cannot use Arc without signing in (unlike other browsers)
- **Tab auto-archive**: Unpinned tabs disappear after 12 hours (pin important tabs to prevent)
- **Resource usage**: Chromium-based, similar memory usage to Chrome (can be high with many tabs)
- **Learning curve**: Unique UI takes adjustment (vertical sidebar, Spaces concept)
- **No built-in ad blocking**: Requires extensions (unlike Brave Shields)

**Resources**:
- Arc Documentation: https://resources.arc.net/
- Arc Keyboard Shortcuts: https://resources.arc.net/en/articles/6680315-keyboard-shortcuts-and-hotkeys
- Arc Community: https://community.arc.net/
- Chrome Web Store (extensions): https://chrome.google.com/webstore
- Arc Feature Guides: https://resources.arc.net/en/collections/3125050-features

---

## Related Documentation

- [Main Apps Index](../README.md) - Overview of all application documentation
- [Brave Browser](brave.md) - Privacy-focused browser with built-in ad blocking
- [Parent Document](../../app-post-install-configuration.md) - Full application post-install configuration guide
