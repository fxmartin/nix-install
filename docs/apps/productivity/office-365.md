# ABOUTME: Microsoft Office 365 post-installation configuration guide
# ABOUTME: Covers subscription requirement, one-time sign-in, auto-update disable, all 6 Office apps, and troubleshooting

# Microsoft Office 365 - Productivity Suite

**Status**: Installed via Homebrew cask `microsoft-office-businesspro` (Story 02.9-001)

**Purpose**: Complete productivity suite including Word (documents), Excel (spreadsheets), PowerPoint (presentations), Outlook (email/calendar), OneNote (notes), and Teams (collaboration/meetings).

---

## Installation Method

- **Homebrew Cask**: `microsoft-office-businesspro`
- **Story**: 02.9-001
- **Apps Location**: `/Applications/Microsoft [App].app`
- **Version**: Latest (managed by Homebrew)

---

## What's Included

**All Apps Installed** (6 apps):
- **Microsoft Word** - Word processing and document creation
- **Microsoft Excel** - Spreadsheets and data analysis
- **Microsoft PowerPoint** - Presentation creation
- **Microsoft Outlook** - Email, calendar, and contacts
- **Microsoft OneNote** - Digital note-taking and organization
- **Microsoft Teams** - Chat, meetings, and collaboration

**Installation Location**: `/Applications/Microsoft [Word/Excel/PowerPoint/Outlook/OneNote/Teams].app`

---

## Subscription Requirement (CRITICAL)

**⚠️ Active Microsoft 365 subscription required (NO perpetual license option)**

Office 365 is subscription-based and requires an active Microsoft 365 account (personal, family, or company/education).

**Subscription Plans**:

1. **Microsoft 365 Personal**: $69.99/year or $6.99/month
   - 1 user
   - 1 TB OneDrive cloud storage
   - Premium Office apps (Word, Excel, PowerPoint, Outlook, OneNote)
   - Advanced security features
   - Works on PC, Mac, tablets, phones

2. **Microsoft 365 Family**: $99.99/year or $9.99/month
   - Up to 6 users
   - 1 TB OneDrive per person (6 TB total)
   - All features from Personal plan
   - Share with family members

3. **Company/Education Account**: Varies by organization
   - Provided by employer or school
   - May include additional apps: Teams, SharePoint, Exchange, OneDrive for Business
   - Managed by IT department

**No Free Tier**: Office 365 does not have a free version. A subscription is required to use all features.

---

## First Launch and Sign-In Process

**⚠️ IMPORTANT**: Sign in to ONE app (e.g., Word) → ALL Office apps activate automatically

### Sign-In Steps (One-Time for All Apps)

1. **Launch any Office app** (e.g., Microsoft Word from Applications or Spotlight)
2. **Click "Sign In"** when the welcome screen appears
3. **Choose account type**:
   - **Personal Microsoft Account**: user@outlook.com, user@hotmail.com, user@live.com
   - **Work or School Account**: user@company.com, user@university.edu
4. **Enter email address** → Click "Next"
5. **Enter password** for your Microsoft account
6. **Complete multi-factor authentication** (2FA) if enabled on your account
   - Enter code from authenticator app or SMS
7. **Accept license terms** when prompted
8. **Choose theme preference**:
   - Colorful (default, colored icons)
   - Dark (dark mode interface)
   - Classic (light mode interface)
9. **App activates** and is ready to use

**Result**: ALL 6 Office apps are now activated (Word, Excel, PowerPoint, Outlook, OneNote, Teams)

### Verify Activation

After signing in to one app, verify all apps are activated:

1. Launch each app (Word, Excel, PowerPoint, Outlook, OneNote, Teams)
2. Should NOT prompt for sign-in (already activated)
3. Check subscription status: Any app → Menu bar → [App Name] → About [App Name]
4. Should show: "Subscription Product" with expiration date

---

## Auto-Update Disable (CRITICAL)

**⚠️ IMPORTANT**: Each Office app has a SEPARATE auto-update setting. You must disable auto-update in ALL 6 apps.

**Why**: Updates controlled via `darwin-rebuild switch` only (Homebrew-managed)

### Disable Auto-Update in Each App

**For Word, Excel, PowerPoint, Outlook, OneNote** (same process for each):

1. **Open the app** (e.g., Microsoft Word)
2. **Menu bar** → **[App Name]** → **Preferences** (or press `Cmd+,`)
3. Click **Update** or **AutoUpdate** tab
4. **Uncheck** "Automatically download and install updates"
5. **Uncheck** "Check for updates automatically" (if separate option)
6. **Close Preferences**
7. **Repeat for ALL apps**: Word, Excel, PowerPoint, Outlook, OneNote

**For Microsoft Teams** (different location):

1. **Open Teams**
2. **Menu bar** → **Teams** → **Preferences**
3. Click **General** tab
4. **Uncheck** "Auto-start application" (optional, prevents Teams from launching at login)
5. **Uncheck** "On close, keep the application running" (optional, quits Teams when closed)
6. Look for **"Check for updates"** or **"Auto-update"** setting → **Disable** if available
   - Note: Teams may not have user-facing auto-update toggle (controlled by IT or Homebrew)

### Verify Auto-Update Disabled

1. Reopen each app's Preferences → Update tab
2. Verify "Automatically download and install" is UNCHECKED
3. Setting should persist across app restarts

---

## Application Details

### Microsoft Word
**Purpose**: Word processing, document creation, editing

**Key Features**:
- Document creation and editing (letters, reports, resumes, books)
- Templates (professional, academic, personal)
- Real-time collaboration (co-authoring with others)
- Track Changes and comments (review workflow)
- Styles and formatting (headings, fonts, colors)
- Mail merge (personalized letters, labels)
- PDF export and import
- Smart Lookup (research tool)

**Common Tasks**:
- **Create document**: File → New Document
- **Use template**: File → New from Template → Choose category
- **Track Changes**: Review tab → Track Changes
- **Insert table**: Insert tab → Table → Choose size
- **Export PDF**: File → Save As → Format: PDF
- **Check spelling**: Tools → Spelling and Grammar

**Keyboard Shortcuts**:
- `Cmd+N`: New document
- `Cmd+B`: Bold
- `Cmd+I`: Italic
- `Cmd+U`: Underline
- `Cmd+Option+M`: Insert comment

### Microsoft Excel
**Purpose**: Spreadsheets, data analysis, calculations

**Key Features**:
- Spreadsheet creation (budgets, trackers, databases)
- Formulas and functions (350+ built-in: SUM, AVERAGE, VLOOKUP, IF, etc.)
- Charts and graphs (column, bar, line, pie, scatter, etc.)
- PivotTables (data summarization and analysis)
- Data validation and conditional formatting
- Macros and VBA (automation)
- Power Query (data transformation)
- What-If Analysis (Goal Seek, Scenario Manager)

**Common Tasks**:
- **Create spreadsheet**: File → New Workbook
- **Insert formula**: Click cell → Type `=SUM(A1:A10)` → Enter
- **Create chart**: Select data → Insert tab → Chart → Choose type
- **PivotTable**: Insert tab → PivotTable → Configure rows/columns/values
- **Conditional formatting**: Home tab → Conditional Formatting → Choose rule
- **Export PDF**: File → Export → PDF

**Keyboard Shortcuts**:
- `Cmd+T`: Create table
- `Option+Down Arrow`: AutoFill down
- `Cmd+Shift+L`: Toggle filter
- `Cmd+1`: Format Cells dialog

### Microsoft PowerPoint
**Purpose**: Presentation creation, slide shows

**Key Features**:
- Slide presentations (business, education, marketing)
- Templates and themes (professional designs)
- Animations and transitions (slide effects)
- Presenter view (notes, timer, next slide preview)
- Slide master (consistent formatting across slides)
- Embedded media (images, videos, audio)
- Collaboration (co-authoring, comments)
- Export to video or PDF

**Common Tasks**:
- **Create presentation**: File → New Presentation
- **Use template**: File → New from Template → Choose design
- **Add slide**: Home tab → New Slide → Choose layout
- **Add animation**: Select object → Animations tab → Add Animation
- **Presenter view**: Slide Show tab → Presenter View (or `Option+Return`)
- **Export PDF**: File → Export → PDF
- **Export video**: File → Export → MP4

**Keyboard Shortcuts**:
- `Cmd+M`: New slide
- `Cmd+D`: Duplicate slide
- `Option+Cmd+P`: Presenter view
- `Cmd+Shift+C`: Copy formatting

### Microsoft Outlook
**Purpose**: Email, calendar, contacts, tasks

**Key Features**:
- **Email**: Multiple account support (IMAP, POP3, Exchange, Office 365)
- **Calendar**: Scheduling, recurring events, meeting invitations
- **Contacts**: Address book with categories and groups
- **Tasks**: To-do lists with due dates and priorities
- **Rules and filters**: Auto-organize incoming mail
- **Search folders**: Smart mailboxes based on criteria
- **Integration with Teams**: Join meetings from calendar
- **Focused Inbox**: Important emails prioritized

**Common Tasks**:
- **Add email account**: Outlook → Preferences → Accounts → Add Account
- **Create event**: Calendar → New Event (or `Cmd+N`)
- **Schedule meeting**: Calendar → New Meeting → Add attendees → Send
- **Create rule**: Outlook → Preferences → Rules → Add Rule
- **Search emails**: `Cmd+Option+F` (advanced search)
- **Set reminder**: Event/Task → Reminder → Choose time

**Keyboard Shortcuts**:
- `Cmd+N`: New email (in Mail view) or New event (in Calendar view)
- `Cmd+R`: Reply
- `Cmd+Shift+R`: Reply All
- `Cmd+J`: Mark as junk

### Microsoft OneNote
**Purpose**: Digital note-taking, organization, collaboration

**Key Features**:
- **Notebooks**: Organize notes into multiple notebooks
- **Sections and pages**: Hierarchical structure (Notebook → Section → Page)
- **Drawing and handwriting**: Apple Pencil or trackpad (with stylus support)
- **Audio/video recording**: Record lectures or meetings (with notes)
- **Web clipping**: Save web pages, articles, receipts
- **Tags**: Categorize notes (To Do, Important, Question, etc.)
- **Search**: Find text in notes, images (OCR), and audio
- **Collaboration**: Share notebooks, co-author notes
- **Cloud sync**: OneDrive sync across devices

**Common Tasks**:
- **Create notebook**: File → New Notebook → Name and choose location (OneDrive or local)
- **Add section**: Right-click notebook → New Section
- **Add page**: `Cmd+N` (in section)
- **Draw**: Draw tab → Start Inking (requires stylus or trackpad)
- **Insert audio**: Insert tab → Audio Recording
- **Web clip**: Share Extension → OneNote (from Safari)
- **Tag note**: Home tab → Tag → Choose tag type

**Keyboard Shortcuts**:
- `Cmd+N`: New page
- `Cmd+Option+N`: New section
- `Cmd+Shift+T`: Insert To Do tag
- `Cmd+Option+D`: Dock to Desktop (quick access)

### Microsoft Teams
**Purpose**: Chat, video meetings, team collaboration

**Key Features**:
- **Team chat**: Channels (topic-based) and direct messages (1-on-1 or group)
- **Video meetings**: Up to 300 participants, HD video, screen sharing
- **Screen sharing**: Share entire screen, window, or PowerPoint
- **File collaboration**: Upload/edit files directly in Teams (Word, Excel, PowerPoint)
- **Calendar integration**: Outlook calendar sync, schedule meetings
- **App integrations**: Planner, OneNote, third-party apps
- **Breakout rooms**: Split meeting into smaller groups
- **Meeting recordings**: Save to OneDrive or SharePoint
- **Whiteboard**: Collaborative digital canvas

**Common Tasks**:
- **Join meeting**: Calendar tab → Click meeting → Join
- **Start chat**: Chat tab → New chat → Enter name
- **Schedule meeting**: Calendar tab → New meeting → Add attendees → Send
- **Share screen**: In meeting → Share button → Choose screen/window
- **Upload file**: Files tab in channel → Upload → Select file
- **Create team**: Teams tab → Join or create team → Create team

**Keyboard Shortcuts**:
- `Cmd+Shift+O`: Show video (toggle camera)
- `Cmd+Shift+M`: Mute/unmute microphone
- `Cmd+Shift+E`: Start screen share
- `Cmd+Shift+H`: Raise hand

---

## Cloud Integration

### OneDrive Sync
**Storage Included**:
- Personal/Family: 1 TB per user
- Company: Typically 1 TB+ (varies by organization)

**What Gets Synced**:
- Documents folder (optional, can enable in OneDrive preferences)
- Desktop folder (optional)
- Pictures folder (optional)
- Specific folders you choose

**Access**:
- Files available offline (downloaded to Mac)
- Online-only files (cloud storage, download on-demand)
- Share links (view-only or edit permissions)

### Real-Time Co-Authoring
- **Collaboration**: Multiple people edit same document simultaneously
- **Live cursors**: See where others are editing (colored cursors with names)
- **Auto-save**: Changes saved automatically to OneDrive
- **Version history**: Restore previous versions (File → Version History)
- **Comments**: Add comments for feedback (@mention others)

---

## Troubleshooting

### Sign-In Issues
- **Can't sign in**: Check internet connection, verify email/password, check Microsoft service status (https://status.office.com)
- **Account not recognized**: Verify subscription is active (check account at account.microsoft.com)
- **Multi-factor authentication not working**: Check authenticator app time sync, use backup codes if available
- **Multiple accounts conflict**: Sign out of all accounts (Preferences → Account → Sign Out), then sign in with correct account

### Activation Issues
- **"Unlicensed Product" message**: Sign in with correct Microsoft account, verify subscription is active
- **Can't activate**: Check internet connection, sign out and sign back in, restart app
- **Wrong subscription showing**: Contact IT admin (company account) or Microsoft support (personal account)

### Auto-Update Issues
- **Update prompts keep appearing**: Verify auto-update disabled in ALL 6 apps (Word, Excel, PowerPoint, Outlook, OneNote, Teams)
- **Update installed automatically**: Re-disable auto-update in each app, check that setting persists
- **Teams updates**: Teams may auto-update via IT policy or Homebrew (check with IT admin)

### Performance Issues
- **App slow to launch**: Disable "Resume windows when quitting and reopening apps" in macOS System Settings → General
- **High memory usage**: Quit unused Office apps (don't keep all 6 running), restart app
- **OneDrive sync issues**: Pause and resume sync, check available storage, verify internet connection

### Teams-Specific Issues
- **Can't join meeting**: Update Teams (via `darwin-rebuild switch`), check permissions (camera, microphone)
- **No audio/video**: System Settings → Privacy & Security → Camera/Microphone → Allow Teams
- **Screen sharing not working**: System Settings → Privacy & Security → Screen Recording → Allow Teams
- **Notifications not appearing**: System Settings → Notifications → Teams → Allow notifications

### File Issues
- **Can't open file**: Check file format compatibility, update Office (via Homebrew), try opening in another app
- **AutoSave not working**: Verify file is saved to OneDrive (not local folder), check OneDrive connection
- **Version history missing**: File must be saved to OneDrive for version history (local files don't have versioning)

---

## Security Notes

- **Encryption**: Microsoft 365 data encrypted in transit (TLS 1.2+) and at rest (BitLocker)
- **Two-factor authentication**: Recommended - enable at account.microsoft.com → Security
- **Sensitivity labels**: Classify documents (Confidential, Internal, Public) - company accounts only
- **Data Loss Prevention (DLP)**: Prevent sharing of sensitive data - company accounts only
- **Information Rights Management (IRM)**: Protect documents with permissions (prevent copy/print/forward)
- **Safe Links**: Email link scanning for phishing (Exchange Online Protection)

---

## License Verification

**Check Subscription Status**:

1. Open any Office app (e.g., Word)
2. Menu bar → **[App Name]** → **About [App Name]**
3. Look for:
   - **"Subscription Product"** (confirms active subscription)
   - **Expiration date** or **"Active until [date]"**
4. Or: Menu bar → **[App]** → **Preferences** → **Account** → View subscription details

**Manage Subscription**:
- Personal/Family: https://account.microsoft.com/services
- Company: Contact IT admin

---

## Testing Checklist

**Installation Verification**:
- [ ] Run `darwin-rebuild switch --flake ~/nix-install#power`
- [ ] Verify all 6 Office apps installed:
  - [ ] `/Applications/Microsoft Word.app`
  - [ ] `/Applications/Microsoft Excel.app`
  - [ ] `/Applications/Microsoft PowerPoint.app`
  - [ ] `/Applications/Microsoft Outlook.app`
  - [ ] `/Applications/Microsoft OneNote.app`
  - [ ] `/Applications/Microsoft Teams.app`

**Sign-In and Activation**:
- [ ] Launch Microsoft Word
- [ ] Click "Sign In" when prompted
- [ ] Enter Microsoft 365 account email
- [ ] Enter password
- [ ] Complete multi-factor authentication (if enabled)
- [ ] Accept license terms
- [ ] Choose theme preference
- [ ] Word activates successfully

**Verify All Apps Activated**:
- [ ] Launch Excel - should NOT prompt for sign-in (already activated)
- [ ] Launch PowerPoint - should NOT prompt for sign-in
- [ ] Launch Outlook - should NOT prompt for sign-in (can add email account)
- [ ] Launch OneNote - should NOT prompt for sign-in
- [ ] Launch Teams - should NOT prompt for sign-in

**Check Subscription**:
- [ ] Word → About Microsoft Word → Shows "Subscription Product"
- [ ] Excel → About Microsoft Excel → Shows "Subscription Product"
- [ ] PowerPoint → About Microsoft PowerPoint → Shows "Subscription Product"

**Auto-Update Disable** (CRITICAL):
- [ ] Word → Preferences → Update → Uncheck "Automatically download and install"
- [ ] Excel → Preferences → Update → Uncheck "Automatically download and install"
- [ ] PowerPoint → Preferences → Update → Uncheck "Automatically download and install"
- [ ] Outlook → Preferences → Update → Uncheck "Automatically download and install"
- [ ] OneNote → Preferences → Update → Uncheck "Automatically download and install"
- [ ] Teams → Preferences → General → Uncheck "Auto-start application" (optional)
- [ ] Verify all settings persist after app restart

**Functionality Testing**:
- [ ] Word: Create and save test document
- [ ] Excel: Create and save test spreadsheet with formula
- [ ] PowerPoint: Create and save test presentation
- [ ] Outlook: Add email account (if applicable)
- [ ] OneNote: Create test notebook and page
- [ ] Teams: Join test meeting or start chat (if applicable)

**Cloud Integration** (if applicable):
- [ ] OneDrive sync working (check OneDrive app or Finder sidebar)
- [ ] Co-authoring test: Share document, edit simultaneously with another user
- [ ] Version history: File → Version History (for OneDrive files)

---

## Additional Resources

**Microsoft Support**:
- Office for Mac support: https://support.microsoft.com/office-mac
- Microsoft 365 help: https://support.microsoft.com/microsoft-365
- Community forums: https://answers.microsoft.com

**Account Management**:
- Personal/Family account: https://account.microsoft.com
- Subscription management: https://account.microsoft.com/services
- OneDrive: https://onedrive.live.com

**Company Accounts**:
- Contact your IT department or Office 365 admin
- Self-service portal: https://portal.office.com
