# ABOUTME
Configuration and usage guide for WhatsApp Desktop on macOS. Covers account linking, features, permissions, and troubleshooting.

### WhatsApp

**Status**: Installed via Mac App Store (mas) `310633997` (Story 02.5-001)

**Purpose**: Official WhatsApp desktop messaging application. Send and receive WhatsApp messages from your Mac, sync conversations with phone, make voice/video calls, share files, and stay connected without constant phone access.

**First Launch**:
1. Launch WhatsApp from Spotlight (`Cmd+Space`, type "WhatsApp") or from `/Applications/WhatsApp.app`
2. **QR Code screen** appears with link instructions
3. **Phone Required**: WhatsApp Desktop requires linking to WhatsApp on your phone
4. No independent desktop account - Mac app mirrors phone WhatsApp

**Account Linking** (REQUIRED):

WhatsApp Desktop **requires** an existing WhatsApp account on your phone. You cannot create a WhatsApp account on Mac - phone setup is mandatory.

**QR Code Linking Process**:
1. **Ensure Phone Has WhatsApp**:
   - Install WhatsApp on your **iPhone** or **Android phone** (free from App Store/Play Store)
   - Set up WhatsApp on phone with phone number verification
   - Must have active WhatsApp account before linking desktop

2. **Link WhatsApp Desktop to Phone**:
   - Launch WhatsApp Desktop on Mac (QR code appears)
   - On your **phone**, open WhatsApp app
   - **iPhone**: Tap **Settings** (bottom right) → **Linked Devices** → **Link a Device**
   - **Android**: Tap **⋮** (three dots, top right) → **Linked Devices** → **Link a Device**
   - Phone camera opens in QR scanner mode

3. **Scan QR Code**:
   - Point phone camera at QR code on Mac screen
   - Phone scans code automatically
   - Wait for "Linked!" confirmation on phone
   - WhatsApp Desktop syncs conversations (may take 1-2 minutes)

4. **Verification Complete**:
   - WhatsApp Desktop shows your conversations
   - Messages sync between phone and Mac
   - Desktop app is now fully functional

**If You Don't Have WhatsApp on Phone**:
1. Download WhatsApp from App Store (iPhone) or Google Play (Android)
2. Launch WhatsApp app on phone
3. Verify phone number with SMS code
4. Set up profile (name, photo)
5. **Then** link WhatsApp Desktop via QR code

**Auto-Update Configuration**:

WhatsApp updates are **managed by the Mac App Store system preferences** (no in-app auto-update setting).

**System-Wide Auto-Update Control**:
- Mac App Store auto-updates controlled via System Settings
- To disable App Store auto-updates globally:
  1. Open **System Settings**
  2. Navigate to **App Store**
  3. **Uncheck** "Automatic Updates"
- This affects ALL Mac App Store apps (WhatsApp, Kindle, Marked 2, Perplexity, etc.)

**Update Process** (Controlled by Mac App Store):
```bash
# WhatsApp updates managed by mas (Mac App Store CLI)
# Updates applied during darwin-rebuild when new version available
darwin-rebuild switch  # Checks for App Store app updates

# Manual update check:
mas upgrade  # Updates all outdated App Store apps
```

**Permissions Required**:

WhatsApp Desktop requests several macOS permissions for full functionality:

1. **Notifications** (Required):
   - **Purpose**: Show message notifications on Mac
   - **Prompt**: Appears on first launch
   - **Recommendation**: **Allow** (essential for message alerts)
   - **Manual Enable**: System Settings → Notifications → WhatsApp → Enable

2. **Microphone** (Optional, for Voice/Video Calls):
   - **Purpose**: Make voice and video calls from Mac
   - **Prompt**: Appears when attempting first call
   - **Recommendation**: **Allow** if using calls (deny if messaging only)
   - **Manual Enable**: System Settings → Privacy & Security → Microphone → Enable WhatsApp

3. **Camera** (Optional, for Video Calls):
   - **Purpose**: Make video calls from Mac
   - **Prompt**: Appears when attempting first video call
   - **Recommendation**: **Allow** if using video calls (deny if not needed)
   - **Manual Enable**: System Settings → Privacy & Security → Camera → Enable WhatsApp

4. **Contacts** (Optional):
   - **Purpose**: See contact names instead of phone numbers
   - **Prompt**: May appear during setup
   - **Recommendation**: **Optional** (contacts sync from phone anyway)
   - **Manual Enable**: System Settings → Privacy & Security → Contacts → Enable WhatsApp

**Core Features**:

WhatsApp Desktop provides comprehensive messaging and communication features:

1. **Messaging**:
   - Send and receive text messages
   - Reply to specific messages (quote/reply)
   - Forward messages to other chats
   - Delete messages (for everyone or just you)
   - Edit sent messages (within 15 minutes)
   - Star important messages for quick access
   - Search conversations (by contact, message content, date)

2. **Media Sharing**:
   - Send photos and videos
   - Share documents (PDF, DOCX, ZIP, etc.) up to 2GB per file
   - Send voice messages (record via microphone)
   - Share contacts from phone
   - Share location (via map link)
   - Drag and drop files into chat window

3. **Voice and Video Calls**:
   - Voice calls (one-on-one or group)
   - Video calls (one-on-one or group)
   - Screen sharing during calls
   - Call encryption (end-to-end)
   - Call history syncs with phone

4. **Group Chats**:
   - Create groups (up to 1024 members)
   - Group admin controls (add/remove members, change settings)
   - Group descriptions and icons
   - Mute group notifications
   - Broadcast lists (send message to multiple contacts without group)

5. **Sync and Backup**:
   - **Real-time sync**: Messages appear on both phone and Mac instantly
   - **Message history**: Syncs recent conversations from phone
   - **Backup**: WhatsApp backup managed on phone (iCloud for iPhone, Google Drive for Android)
   - **Media download**: Choose to auto-download media or manual download only

6. **Privacy and Security**:
   - **End-to-end encryption**: All messages and calls encrypted
   - **Two-step verification**: Optional PIN for account security (set up on phone)
   - **Disappearing messages**: Set messages to auto-delete after 24h/7d/90d
   - **View once media**: Send photos/videos that disappear after viewing
   - **Block contacts**: Block unwanted contacts (sync across devices)

**Basic Usage Examples**:

**Sending a Message**:
1. Open WhatsApp Desktop
2. Click on contact or group in left sidebar
3. Type message in text field at bottom
4. Press **Enter** to send (or **Shift+Enter** for new line)

**Sending a File/Photo**:
1. Open chat with contact or group
2. Click **📎** (paperclip) icon OR drag file into chat window
3. Choose file type:
   - **Photos & Videos**: Browse photos/videos
   - **Documents**: Browse documents (PDF, DOCX, ZIP, etc.)
4. Select file → Click **Send**
5. File uploads and sends (progress bar shows upload status)

**Making a Voice/Video Call**:
1. Open chat with contact
2. Click **📞** (phone) icon for voice call OR **🎥** (video camera) for video call
3. Call connects (requires microphone/camera permissions)
4. During call:
   - **Mute**: Click 🎤 icon to mute/unmute
   - **Video toggle**: Click 📹 to turn video on/off
   - **End call**: Click red phone icon

**Creating a Group**:
1. Click **☰** (menu) in top left → **New Group**
2. Select contacts to add (search or scroll)
3. Click **→** (next arrow)
4. Set group name and optional icon
5. Click **✓** (checkmark) to create group
6. Group appears in chat list

**Searching Messages**:
1. Click **🔍** (search) icon at top
2. Type search query (contact name, message text, etc.)
3. Results appear with context (message preview, date)
4. Click result to jump to that message in chat

**Archiving Chats**:
1. Right-click chat in sidebar (or swipe left on trackpad)
2. Click **Archive chat**
3. Chat moves to Archive (hidden from main list)
4. View archived chats: Scroll to top of chat list → **Archived** section

**Pinning Important Chats**:
1. Right-click chat in sidebar
2. Click **Pin chat**
3. Chat stays at top of chat list (up to 3 pinned chats)
4. Unpin: Right-click pinned chat → **Unpin chat**

**Configuration Tips**:
- **Notifications**: WhatsApp → Settings → Notifications → Customize sound, badges, previews
- **Theme**: WhatsApp → Settings → Theme → Light/Dark/System (follows macOS appearance)
- **Privacy**: WhatsApp → Settings → Privacy → Last seen, profile photo, about visibility
- **Keyboard Shortcuts**: WhatsApp → Settings → Keyboard Shortcuts → Customize shortcuts
- **Download Location**: WhatsApp → Settings → Storage → Change download folder
- **Media Auto-Download**: Settings → Storage → Disable auto-download to save bandwidth/space

**Linking Multiple Devices**:

WhatsApp supports **up to 4 linked devices** simultaneously (in addition to your phone):
- Mac, iPad, another Mac, etc.
- Each device requires separate QR code linking
- All devices stay in sync (messages appear everywhere)
- Linked devices work even when phone is offline (after initial linking)

**To Link Another Device**:
1. On phone: WhatsApp → Settings/Menu → **Linked Devices**
2. Tap **Link a Device**
3. Scan QR code on other device
4. Device links and syncs

**To Unlink WhatsApp Desktop**:
1. On phone: WhatsApp → Settings/Menu → **Linked Devices**
2. Find "WhatsApp on Mac" in linked devices list
3. Tap device → **Log Out**
4. Desktop app disconnects (shows QR code screen again)

**No License Required**:
- WhatsApp is **free** (no subscription, no ads)
- Owned by Meta (Facebook parent company)
- No premium features or paid tiers
- Unlimited messaging, calls, and media sharing

**Data and Privacy**:
- **End-to-end encryption**: Meta cannot read messages/calls
- **Message storage**: Messages stored on phone (not in cloud)
- **Backup**: Optional backup to iCloud (iPhone) or Google Drive (Android)
- **Desktop sync**: Recent messages sync to desktop (deleted when unlinking)
- **Metadata**: Meta collects usage metadata (who you message, when, frequency)

**Troubleshooting**:

**QR Code Not Scanning**:
- Ensure phone WhatsApp is up to date
- Restart WhatsApp Desktop (quit and relaunch)
- Refresh QR code (click "Click to reload QR code" link)
- Clean phone camera lens
- Ensure good lighting (QR code must be clearly visible)

**Messages Not Syncing**:
- Check internet connection on both phone and Mac
- Ensure phone WhatsApp is running (doesn't need to be foreground)
- Unlink and re-link desktop: Phone → Linked Devices → Log Out → Link again

**Calls Not Working**:
- Check microphone/camera permissions (System Settings → Privacy & Security)
- Test microphone: System Settings → Sound → Input → Speak and check levels
- Restart WhatsApp Desktop
- Update WhatsApp on both phone and desktop

**Desktop Shows "Phone Not Connected"**:
- Ensure phone has internet connection (Wi-Fi or cellular)
- Open WhatsApp on phone (wake it up)
- Check phone battery saver isn't killing WhatsApp background process
- Re-link if issue persists

**Testing Checklist**:
- [ ] WhatsApp installed and launches
- [ ] QR code screen appears on first launch
- [ ] Can link to phone via QR code scan
- [ ] Conversations sync from phone (recent messages appear)
- [ ] Can send text message from desktop
- [ ] Can receive messages on desktop (send from phone → appears on Mac)
- [ ] Can send photo/file (click paperclip → select file → send)
- [ ] Can make voice call (microphone permission granted)
- [ ] Can make video call (camera + microphone permissions granted)
- [ ] Notifications work (send message to self → notification appears)
- [ ] Can create new group chat
- [ ] Can search messages (click search → type query → results appear)
- [ ] App accessible from Spotlight/Raycast
- [ ] App stays synced when phone is locked (messages still deliver)

**Documentation**:
- WhatsApp Desktop Help: https://faq.whatsapp.com/1317564615384230/
- Linking Devices Guide: https://faq.whatsapp.com/1317564615384230/#link
- Privacy & Security: https://www.whatsapp.com/security/
- Desktop Features: https://faq.whatsapp.com/478868410920146/

---

## Related Documentation

- [Main Apps Index](../README.md) - Overview of all applications
- [Zoom](./zoom.md) - Video conferencing and meetings
- [Cisco Webex](./cisco-webex.md) - Enterprise video conferencing
