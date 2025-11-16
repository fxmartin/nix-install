# ABOUTME: File utilities post-installation configuration guide
# ABOUTME: Covers Calibre (ebook manager), Kindle (ebook reader), Keka (archive tool), Marked 2 (markdown previewer)

## Calibre

### Calibre

**Status**: Installed via Homebrew cask `calibre` (Story 02.4-003)

**Purpose**: Comprehensive ebook library manager and converter. Manages ebook collections, converts between formats (EPUB, MOBI, AZW3, PDF, etc.), reads ebooks, syncs to ebook readers, and edits metadata.

**First Launch**:
1. Launch Calibre from Spotlight (`Cmd+Space`, type "Calibre") or from `/Applications/calibre.app`
2. Welcome wizard appears on first launch
3. Follow setup steps:
   - **Choose Library Location**: Select or create folder for ebook library (default: `~/Calibre Library`)
   - **Choose E-reader Device** (Optional): Select if you have a Kindle, Kobo, or other e-reader
   - **Complete Setup**: Calibre creates library database

**Auto-Update Configuration** (REQUIRED):

Calibre updates must be disabled to maintain declarative configuration control.

**Steps to Disable Auto-Update**:
1. Launch Calibre
2. Click **Calibre** in menu bar → **Preferences**
3. Navigate to **Miscellaneous** section (bottom of sidebar)
4. Find **Updates** section
5. **Uncheck** "Automatically check for updates"
6. Click **Apply** → **Close**

**Verification**:
- Open Calibre Preferences → Miscellaneous
- Confirm "Automatically check for updates" is **unchecked**
- Updates will now only occur via `darwin-rebuild switch` (controlled by Homebrew)

**Update Process** (Controlled by Homebrew):
```bash
# To update Calibre (along with all other apps):
darwin-rebuild switch  # Uses current flake.lock versions

# OR to get latest versions first:
nix flake update      # Updates flake.lock with latest package versions
darwin-rebuild switch # Applies the updates
```

**Core Features**:

Calibre is a powerful ebook management suite with comprehensive features:

1. **Library Management**:
   - Organize unlimited ebooks in searchable library
   - Support for all major formats (EPUB, MOBI, AZW3, PDF, TXT, HTML, etc.)
   - Metadata editing (title, author, series, tags, cover, description)
   - Smart collections and saved searches
   - Duplicate detection
   - Virtual libraries (filtered views)

2. **Format Conversion**:
   - Convert between any ebook formats
   - Batch conversion support
   - Preserve metadata during conversion
   - Custom conversion settings per format
   - Common conversions: PDF → EPUB, MOBI → EPUB, EPUB → AZW3

3. **Ebook Reading**:
   - Built-in ebook reader with customizable display
   - Annotations and highlights
   - Dictionary lookup
   - Table of contents navigation
   - Bookmarks and reading position sync

4. **Device Sync**:
   - Sync library to Kindle, Kobo, Nook, and other e-readers
   - USB device detection and automatic sync
   - Wireless sync support (for compatible devices)
   - Send books via email to Kindle

5. **Metadata Editing**:
   - Download metadata from online sources (Amazon, Google Books, etc.)
   - Bulk metadata editing
   - Custom cover download and editing
   - Series management with reading order
   - Tag and category organization

6. **News Download**:
   - Download news from websites as ebooks
   - Schedule automatic news downloads
   - Send news to e-reader devices

**Basic Usage Examples**:

**Adding Ebooks to Library**:
1. Drag and drop ebook files into Calibre window
2. OR: Click "Add books" button → Select files
3. Calibre imports and adds to library

**Converting Ebook Formats**:
1. Select book in library
2. Click "Convert books" button
3. Choose output format (EPUB, MOBI, AZW3, PDF)
4. Click "OK" → Conversion starts
5. Converted book appears in book details

**Reading Ebooks**:
1. Double-click book in library
2. OR: Right-click → Open with → E-book viewer
3. Calibre reader opens with customizable font, size, colors

**Sending to Kindle**:
1. Connect Kindle via USB (Calibre detects automatically)
2. Select books to send
3. Click "Send to device" button
4. Books transfer to Kindle

**Editing Metadata**:
1. Select book in library
2. Click "Edit metadata" button
3. Update title, author, series, tags, cover, etc.
4. Click "OK" to save changes

**Configuration Tips**:
- **Library Location**: Store in Dropbox or iCloud for cross-device sync
- **Metadata Sources**: Preferences → Sharing → Metadata download (configure sources)
- **Reading Preferences**: E-book viewer → Preferences (font, colors, margins)
- **Device Setup**: Preferences → Sharing → Sharing books by email (for Kindle email delivery)
- **Virtual Libraries**: Right sidebar → Virtual libraries → Create filtered views by tag, author, series

**No License Required**:
- Calibre is **free and open source** (no license key needed)
- All features available without payment
- Developed and maintained by Kovid Goyal

**Supported Formats**:
- **Input**: EPUB, MOBI, AZW, AZW3, AZW4, PRC, PDF, TXT, HTML, RTF, LIT, LRF, FB2, PDB, RB, SNB, TCR, and more
- **Output**: EPUB, MOBI, AZW3, PDF, TXT, HTML, FB2, PDB, LIT, LRF, TCR, SNB

**Testing Checklist**:
- [ ] Calibre installed and launches
- [ ] Welcome wizard completes successfully
- [ ] Library created at chosen location
- [ ] Can add ebook to library (drag/drop or Add books button)
- [ ] Can view book details and metadata
- [ ] Can convert between formats (e.g., PDF → EPUB)
- [ ] E-book viewer opens and displays book correctly
- [ ] Auto-update disabled (Preferences → Miscellaneous)
- [ ] Can edit metadata (title, author, cover)

**Documentation**:
- Official User Manual: https://manual.calibre-ebook.com/
- Format Conversion Guide: https://manual.calibre-ebook.com/conversion.html
- E-reader Device Guide: https://manual.calibre-ebook.com/devices.html

---


## Kindle

### Kindle

**Status**: Installed via Mac App Store (mas) `302584613` (Story 02.4-003)

**Purpose**: Official Amazon Kindle ebook reader for macOS. Read Kindle books purchased from Amazon, sync reading position across devices, access X-Ray features, take notes and highlights, and use Whispersync.

**First Launch**:
1. Launch Kindle from Spotlight (`Cmd+Space`, type "Kindle") or from `/Applications/Kindle.app`
2. Sign-in screen appears
3. Sign in with Amazon account:
   - Enter Amazon email/username
   - Enter Amazon password
   - Complete two-factor authentication if enabled
4. Library syncs from Amazon cloud
5. Downloaded books appear in "Downloaded" tab

**Account Sign-In** (REQUIRED):

Kindle requires an Amazon account (no separate license needed).

**Sign-In Process**:
1. Launch Kindle app
2. Click "Sign In"
3. Enter your **Amazon account** email/username
4. Enter your **Amazon password**
5. Complete **two-factor authentication** if enabled (code sent to phone/email)
6. Click "Sign In"
7. Kindle syncs your library from Amazon cloud (books you own appear automatically)

**If You Don't Have an Amazon Account**:
1. Visit https://www.amazon.com/
2. Click "Create your Amazon account"
3. Follow account creation steps
4. No special Kindle subscription needed - use regular Amazon account
5. Then sign in to Kindle app with new Amazon credentials

**Auto-Update Configuration**:

Kindle updates are **managed by the Mac App Store system preferences** (no in-app setting).

**System-Wide Auto-Update Control**:
- Mac App Store auto-updates controlled via System Settings
- To disable App Store auto-updates globally:
  1. Open **System Settings**
  2. Navigate to **App Store**
  3. **Uncheck** "Automatic Updates"
- This affects ALL Mac App Store apps (Kindle, Marked 2, Perplexity, etc.)

**Update Process** (Controlled by Mac App Store):
```bash
# Kindle updates managed by mas (Mac App Store CLI)
# Updates applied during darwin-rebuild when new version available
darwin-rebuild switch  # Checks for App Store app updates

# Manual update check:
mas upgrade  # Updates all outdated App Store apps
```

**Core Features**:

Kindle for Mac provides comprehensive ebook reading features:

1. **Ebook Reading**:
   - Read Kindle books with customizable fonts, sizes, and backgrounds
   - Full-screen reading mode
   - Page flip animations
   - Table of contents navigation
   - Bookmarks and annotations
   - Dictionary lookup (built-in dictionaries)

2. **Cloud Sync (Whispersync)**:
   - Reading position syncs across all devices (iPhone, iPad, Kindle e-reader, etc.)
   - Bookmarks and highlights sync
   - Notes sync
   - Last page read remembered

3. **X-Ray Features**:
   - Character and theme exploration
   - See all mentions of characters, places, themes
   - Wikipedia and Shelfari integration
   - Available for supported books

4. **Notes & Highlights**:
   - Highlight text passages
   - Add notes to highlighted text
   - View all notes and highlights
   - Export notes and highlights
   - Sync across devices via Whispersync

5. **Library Management**:
   - View all Kindle books owned
   - Download books for offline reading
   - Remove downloaded books (frees space, keeps in cloud)
   - Sort by title, author, recent
   - Search library

6. **Collections**:
   - Organize books into collections
   - Create custom collections
   - Collections sync to Kindle e-readers

**Basic Usage Examples**:

**Reading a Book**:
1. Open Kindle app
2. Click on book cover in Library
3. Book downloads (if not already downloaded) and opens
4. Click/swipe to turn pages
5. Reading position syncs automatically

**Adding Books to Library**:
- Books purchased from Amazon Kindle Store appear automatically
- Personal documents can be sent via Send to Kindle email
- No manual import of non-Amazon ebooks (use Calibre for that)

**Adjusting Reading Settings**:
1. Open a book
2. Click **Aa** button (top toolbar)
3. Adjust:
   - Font family
   - Font size
   - Line spacing
   - Margins
   - Background color (white, sepia, black)

**Taking Notes and Highlights**:
1. Select text with cursor
2. Click "Highlight" or "Note" from popup menu
3. Highlights appear in yellow (customizable color)
4. Notes saved with highlighted text
5. View all notes: Menu → View → Notes & Marks

**Syncing Reading Position**:
- Whispersync happens automatically when online
- Close book on Mac → Open on iPhone/iPad → Resume at same page
- Works across all Kindle devices and apps

**Configuration Tips**:
- **Download Books**: Right-click book → Download (for offline reading)
- **Remove Downloads**: Right-click book → Remove from Device (keeps in cloud, frees space)
- **Organize Collections**: Right-click book → Add to Collection
- **Dictionary**: Select word → Dictionary definition appears automatically
- **X-Ray**: Tap X-Ray button (if book supports it) → Explore characters, themes

**No License Required**:
- Kindle app is **free** (included with Amazon account)
- No subscription needed for basic use
- **Kindle Unlimited** subscription optional (monthly fee for unlimited reading of participating books)
- Read books you purchase from Amazon Kindle Store

**Supported Formats**:
- **Kindle formats**: AZW, AZW3, KFX, MOBI (Amazon proprietary formats)
- **Personal documents**: PDF, TXT, MOBI (via Send to Kindle email)
- **NOT supported**: EPUB (use Calibre to convert EPUB → MOBI first)

**Testing Checklist**:
- [ ] Kindle installed and launches
- [ ] Sign-in with Amazon account successful
- [ ] Library syncs from cloud (owned books appear)
- [ ] Can download a book for offline reading
- [ ] Can open and read a book
- [ ] Page navigation works (click/swipe)
- [ ] Reading settings adjustable (font, size, background)
- [ ] Can highlight text and add notes
- [ ] X-Ray feature works (if book supports it)
- [ ] Whispersync syncs reading position across devices

**Documentation**:
- Kindle for Mac Help: https://www.amazon.com/gp/help/customer/display.html?nodeId=G8XYGXFCRXT5W6WW
- Send to Kindle Guide: https://www.amazon.com/sendtokindle
- Kindle Unlimited (optional): https://www.amazon.com/kindle-unlimited

---


## Keka

### Keka

**Status**: Installed via Homebrew cask `keka` (Story 02.4-003)

**Purpose**: Archive utility for macOS. Create and extract archives in multiple formats (zip, 7z, tar, gzip, rar, etc.) with password protection, compression level control, and macOS integration.

**First Launch**:
1. Launch Keka from Spotlight (`Cmd+Space`, type "Keka") or from `/Applications/Keka.app`
2. Main window appears showing drop zone
3. No configuration wizard (ready to use immediately)
4. Optionally set as default archive handler for file types

**File Association Setup** (OPTIONAL):

Keka can be set as the default application for opening archive files (.zip, .rar, .7z, etc.).

**Setting as Default Archive Handler**:

**Method 1: Via Keka Preferences**:
1. Launch Keka
2. Click **Keka** in menu bar → **Preferences**
3. Navigate to **Extraction** tab
4. Click **Set Keka as default application for** section
5. Check file types you want Keka to handle:
   - `□` zip
   - `□` rar
   - `□` 7z
   - `□` tar
   - `□` gzip
   - `□` bzip2
   - etc.
6. Click **Apply** or close Preferences (settings save automatically)

**Method 2: Via Finder (per file type)**:
1. Right-click any `.zip` file in Finder
2. Select **Get Info** (or press `Cmd+I`)
3. Expand **Open with:** section
4. Choose **Keka** from dropdown
5. Click **Change All...** (applies to all .zip files)
6. Repeat for other archive types (.rar, .7z, etc.)

**Auto-Update Configuration**:

Keka is **free and open source** with no auto-update mechanism requiring disable. Updates managed by Homebrew only.

**Update Process** (Controlled by Homebrew):
```bash
# To update Keka (along with all other apps):
darwin-rebuild switch  # Uses current flake.lock versions

# OR to get latest versions first:
nix flake update      # Updates flake.lock with latest package versions
darwin-rebuild switch # Applies the updates
```

**Core Features**:

Keka provides comprehensive archive management:

1. **Archive Creation**:
   - Drag and drop files/folders onto Keka window
   - Creates compressed archives in multiple formats
   - Supported output formats: 7z, zip, tar, gzip, bzip2, dmg, iso
   - Compression level control (store, fast, normal, good, ultra)
   - Split archives into multiple volumes
   - Password protection (AES-256 encryption for 7z and zip)

2. **Archive Extraction**:
   - Double-click archive → Extracts automatically
   - Right-click → Open with Keka
   - Drag and drop archive onto Keka window
   - Supported input formats: 7z, zip, rar, tar, gzip, bzip2, dmg, iso, lzma, xz, cab, msi, pkg, deb, rpm, and more
   - Password-protected archive support

3. **Compression Control**:
   - Choose compression method per archive
   - Balance between file size and compression time
   - Format-specific options (solid compression for 7z, etc.)

4. **Password Protection**:
   - Encrypt archives with password (AES-256)
   - Protect sensitive files
   - Works with 7z and zip formats

5. **macOS Integration**:
   - Drag and drop interface
   - Finder context menu integration
   - Quick Look support for archive contents
   - Notification Center integration

**Basic Usage Examples**:

**Creating a Zip Archive**:
1. Launch Keka (or drag files directly onto Keka icon in Dock)
2. Drag file(s) or folder(s) into Keka window
3. Choose format (zip, 7z, tar.gz, etc.) from dropdown
4. Click "Compress" or drag onto format button
5. Archive created in same location as original files

**Extracting an Archive**:
1. Double-click archive file (if Keka is default handler)
2. OR: Right-click archive → Open with → Keka
3. OR: Drag archive onto Keka window
4. Archive extracts to folder in same location

**Creating Password-Protected Archive**:
1. Drag files into Keka window
2. Choose **7z** or **zip** format (password support)
3. Click 🔒 (lock icon) → Enter password
4. Click "Compress"
5. Archive created with AES-256 encryption

**Extracting Password-Protected Archive**:
1. Double-click password-protected archive
2. Keka prompts for password
3. Enter password → Click OK
4. Archive extracts if password correct

**Configuration Tips**:
- **Default Format**: Preferences → Compression → Default format (zip, 7z, etc.)
- **Compression Level**: Preferences → Compression → Default compression method
- **Extraction Location**: Preferences → Extraction → Extract to (same folder, custom location, ask each time)
- **File Associations**: Preferences → Extraction → Set Keka as default for archive types
- **Password Manager Integration**: Use 1Password to generate and store archive passwords

**No License Required**:
- Keka is **free and open source** (no license key needed)
- Mac App Store version is paid ($4.99) to support development
- Homebrew version is free (official distribution method)
- All features available in both versions

**Supported Formats**:
- **Create**: 7z, zip, tar, gzip, bzip2, dmg, iso
- **Extract**: 7z, zip, rar, tar, gzip, bzip2, dmg, iso, lzma, xz, cab, msi, pkg, deb, rpm, exe (self-extracting), and more

**Testing Checklist**:
- [ ] Keka installed and launches
- [ ] Can create zip archive (drag files → choose zip → compress)
- [ ] Can extract zip archive (double-click .zip file)
- [ ] Can create 7z archive
- [ ] Can extract rar archive (if available)
- [ ] Password protection works (create password-protected 7z)
- [ ] Can extract password-protected archive
- [ ] File associations configurable (Preferences → Extraction)
- [ ] Compression level adjustable (Preferences → Compression)

**Documentation**:
- Official Website: https://www.keka.io/
- GitHub Repository: https://github.com/aonez/Keka
- Supported Formats List: https://www.keka.io/en/

---


## Marked 2

### Marked 2

**Status**: Installed via Mac App Store (mas) `890031187` (Story 02.4-003)

**Purpose**: Markdown preview and export application. Live preview of Markdown files with syntax highlighting, export to PDF/HTML, custom CSS styling, multi-Markdown syntax support, and statistics.

**First Launch**:
1. Launch Marked 2 from Spotlight (`Cmd+Space`, type "Marked 2") or from `/Applications/Marked 2.app`
2. Main preview window appears
3. No sign-in required (purchased via Mac App Store)
4. Drag .md file into window or open via File → Open

**Auto-Update Configuration** (REQUIRED):

Marked 2 updates must be disabled to maintain declarative configuration control.

**Steps to Disable Auto-Update**:
1. Launch Marked 2
2. Click **Marked 2** in menu bar → **Preferences** (or press `Cmd+,`)
3. Navigate to **General** tab
4. Find **Updates** section
5. **Uncheck** "Check for updates automatically"
6. Close Preferences

**Verification**:
- Open Marked 2 Preferences → General
- Confirm "Check for updates automatically" is **unchecked**
- Updates will now only occur via `darwin-rebuild switch` (controlled by Mac App Store)

**Note**: Since Marked 2 is a Mac App Store app, system-wide App Store auto-updates should also be disabled:
1. Open **System Settings** → **App Store**
2. **Uncheck** "Automatic Updates" (affects all Mac App Store apps)

**Update Process** (Controlled by Mac App Store):
```bash
# Marked 2 updates managed by mas (Mac App Store CLI)
darwin-rebuild switch  # Checks for App Store app updates

# Manual update check:
mas upgrade  # Updates all outdated App Store apps
```

**Core Features**:

Marked 2 is a powerful Markdown preview and export tool:

1. **Live Markdown Preview**:
   - Real-time preview of Markdown files
   - Auto-refresh on file save (monitors file changes)
   - Syntax highlighting for code blocks
   - Support for GitHub Flavored Markdown (GFM)
   - Multi-Markdown (MMD) syntax support
   - Tables, footnotes, definition lists, task lists

2. **Export Capabilities**:
   - Export to **PDF** (print-quality, customizable)
   - Export to **HTML** (standalone or snippet)
   - Export to **RTF** (Rich Text Format)
   - Export to **DOCX** (Microsoft Word via Pandoc)
   - Custom CSS styling for exports
   - Include/exclude table of contents

3. **Custom Styling**:
   - Choose from built-in themes (GitHub, Swiss, Antique, etc.)
   - Custom CSS support (load your own stylesheets)
   - Preview with different CSS in real-time
   - Font size and family control

4. **Document Statistics**:
   - Word count, character count
   - Reading time estimate
   - Keyword frequency analysis
   - Readability scores (Flesch, Gunning Fog, etc.)

5. **Advanced Preview Features**:
   - Scroll sync (editor and preview in sync)
   - Mini-map navigation (see document structure)
   - Table of contents generation
   - MathJax support (LaTeX math rendering)
   - Mermaid diagram support
   - Critic Markup (track changes)

6. **Integration**:
   - Works with any text editor (VSCode, Zed, Vim, etc.)
   - File watcher monitors external edits
   - Drag and drop Markdown files
   - Open .md files directly from Finder

**Basic Usage Examples**:

**Previewing a Markdown File**:
1. Launch Marked 2
2. Drag `.md` file into Marked 2 window
3. OR: Click **File** → **Open** → Select .md file
4. Preview appears with rendered Markdown
5. Edit file in your text editor (Zed, VSCode, etc.) → Marked 2 auto-refreshes

**Exporting to PDF**:
1. Open Markdown file in Marked 2
2. Click **File** → **Export** → **PDF**
3. Choose export options:
   - Include table of contents
   - Custom CSS
   - Page size and margins
4. Click **Save** → PDF created

**Changing Preview Style**:
1. Open Markdown file in Marked 2
2. Click **Marked 2** menu → **Style** → Choose theme
3. Options: GitHub, Swiss, Antique, Manuscript, etc.
4. Preview updates with new CSS instantly

**Viewing Document Statistics**:
1. Open Markdown file in Marked 2
2. Click **Statistics** button (toolbar) OR **Marked 2** → **Statistics**
3. Panel shows:
   - Word count
   - Character count
   - Reading time
   - Readability scores

**Configuration Tips**:
- **Default Style**: Preferences → Style → Choose default preview CSS
- **Auto-Refresh**: Preferences → General → File refresh (on save, on focus, etc.)
- **Code Highlighting**: Preferences → Style → Choose syntax theme for code blocks
- **Export Defaults**: Preferences → Export → Default format, include TOC, etc.
- **Multi-Markdown**: Preferences → Processor → Enable MultiMarkdown features
- **MathJax/Mermaid**: Preferences → Advanced → Enable rendering engines

**License Requirements**:

Marked 2 is a **paid application** purchased via Mac App Store.

- **Price**: $14.99 (one-time purchase)
- **No subscription**: Pay once, use forever
- **License**: Tied to Apple ID (Mac App Store handles licensing)
- **Multiple Macs**: Install on all Macs using same Apple ID

**Supported Syntax**:
- **Standard Markdown**: Headings, lists, links, images, emphasis, code blocks
- **GitHub Flavored Markdown (GFM)**: Task lists, tables, strikethrough, fenced code blocks
- **MultiMarkdown (MMD)**: Footnotes, definition lists, tables, metadata, cross-references
- **Critic Markup**: Track changes and suggestions
- **MathJax**: LaTeX math equations
- **Mermaid**: Diagrams and flowcharts

**Testing Checklist**:
- [ ] Marked 2 installed and launches
- [ ] Can open .md file (drag/drop or File → Open)
- [ ] Markdown preview renders correctly
- [ ] Live reload works (edit file in Zed → Marked 2 updates)
- [ ] Can change preview style (Marked 2 → Style → Choose theme)
- [ ] Can export to PDF (File → Export → PDF)
- [ ] Can export to HTML (File → Export → HTML)
- [ ] Statistics panel shows word count, reading time
- [ ] Auto-update disabled (Preferences → General)
- [ ] Code blocks have syntax highlighting
- [ ] Tables render correctly (GFM syntax)

**Documentation**:
- Official User Guide: https://marked2app.com/help/
- Markdown Syntax Reference: https://marked2app.com/help/Markdown_Syntax.html
- Export Guide: https://marked2app.com/help/Export.html
- Custom CSS Guide: https://marked2app.com/help/Custom_CSS.html

---


## Related Documentation

- [Main Apps Index](../README.md) - Overview of all application documentation
- [Raycast Configuration](./raycast.md) - Productivity launcher setup
- [1Password Configuration](./1password.md) - Password manager setup
- [System Utilities Configuration](./system-utilities.md) - Onyx, f.lux
