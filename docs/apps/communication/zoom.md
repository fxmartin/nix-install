# ABOUTME
Configuration and usage guide for Zoom video conferencing on macOS. Covers auto-update disabling, account setup, features, permissions, and troubleshooting.

### Zoom

**Status**: Installed via Homebrew cask `zoom` (Story 02.5-002)

**Purpose**: Video conferencing and virtual meetings platform. Join or host Zoom meetings, webinars, and video calls with screen sharing, chat, recording, and collaboration features.

**⚠️ CRITICAL - AUTO-UPDATE DISABLE REQUIRED**

Zoom has **automatic update checking enabled by default**. You must disable this to maintain control via Homebrew.

**Auto-Update Disable Steps** (MANDATORY):
1. Launch Zoom
2. Open **Preferences**:
   - Click your **profile picture** or **initials** (top right)
   - Select **Settings** from dropdown menu
3. Navigate to **General** tab (left sidebar)
4. Look for **"Update Zoom automatically when connected to Wi-Fi"** checkbox
5. **Uncheck** this option
6. Close Settings window (changes save automatically)

**Verification**:
```bash
# Zoom version managed by Homebrew
brew list --cask zoom --versions
# Updates ONLY via darwin-rebuild, never automatic
```

**Why This Matters**:
- Zoom updates can introduce breaking changes or UI changes without warning
- Updates controlled via `rebuild` or `update` commands ensure stability
- Automatic updates bypass nix-darwin configuration management
- Unexpected updates can disrupt meeting preparation or in-progress meetings

**Account Requirement**:

Zoom can be used with or without an account:

1. **Free Account** (No License):
   - Create free Zoom account at https://zoom.us/signup
   - **Meeting limits**: 40-minute limit for group meetings (3+ participants)
   - **Participant limits**: Up to 100 participants
   - **Features**: Join meetings, host short meetings, screen sharing, chat
   - **No payment required**: Free tier is permanently free

2. **Licensed Account** (Paid Plans):
   - **Pro Plan** ($149.90/year): Unlimited meeting duration, cloud recording, reporting
   - **Business Plan** ($199.90/year/user): Admin controls, branding, managed domains
   - **Enterprise Plan** (Custom pricing): Unlimited cloud storage, dedicated support
   - **License activation**: Sign in with licensed account (provided by employer or purchased)

3. **Guest Mode** (No Account):
   - Join meetings without creating account
   - Click meeting link → Enter name → Join
   - **Limitations**: Cannot host meetings, limited feature access

**First Launch**:
1. Launch Zoom from Spotlight (`Cmd+Space`, type "Zoom") or from `/Applications/zoom.us.app`
2. **Sign In** screen appears with options:
   - **Sign In**: Use existing Zoom account (email + password)
   - **Sign In with Google**: Use Google account for SSO
   - **Sign In with Apple**: Use Apple ID for SSO
   - **Join a Meeting**: Skip sign-in to join meeting as guest
3. Choose option based on your needs:
   - **Work account**: Sign in with company-provided credentials
   - **Personal free account**: Sign in or create account at zoom.us
   - **Guest**: Click "Join a Meeting" (can sign in later)

**Permissions Required**:

Zoom requests several macOS permissions for full functionality:

1. **Microphone** (Required for Audio):
   - **Purpose**: Enable audio in meetings (speak and be heard)
   - **Prompt**: Appears on first meeting join or when testing audio
   - **Recommendation**: **Allow** (essential for meetings)
   - **Manual Enable**: System Settings → Privacy & Security → Microphone → Enable Zoom

2. **Camera** (Required for Video):
   - **Purpose**: Enable video in meetings (share your video feed)
   - **Prompt**: Appears when enabling video for first time
   - **Recommendation**: **Allow** (required for video meetings)
   - **Manual Enable**: System Settings → Privacy & Security → Camera → Enable Zoom

3. **Screen Recording** (Required for Screen Sharing):
   - **Purpose**: Share your screen with meeting participants
   - **Prompt**: Appears when attempting first screen share
   - **Recommendation**: **Allow** (essential for presentations)
   - **Manual Enable**: System Settings → Privacy & Security → Screen Recording → Enable Zoom

4. **Accessibility** (Optional, for Advanced Features):
   - **Purpose**: Remote control during screen sharing, annotation features
   - **Prompt**: May appear when using advanced collaboration features
   - **Recommendation**: **Optional** (only needed for remote control features)
   - **Manual Enable**: System Settings → Privacy & Security → Accessibility → Enable Zoom

5. **Notifications** (Optional):
   - **Purpose**: Meeting reminders, chat notifications
   - **Prompt**: Appears after first meeting
   - **Recommendation**: **Allow** (helpful for meeting reminders)
   - **Manual Enable**: System Settings → Notifications → Zoom → Enable

**Core Features**:

Zoom provides comprehensive video conferencing and collaboration features:

1. **Meeting Types**:
   - **Instant Meeting**: Start meeting immediately from Zoom app
   - **Scheduled Meeting**: Schedule meeting with date/time, send invites
   - **Personal Meeting Room**: Permanent meeting room with fixed ID
   - **Join Meeting**: Join meeting via link, ID, or calendar integration

2. **Video and Audio**:
   - **HD Video**: 720p or 1080p video quality (settings adjustable)
   - **Gallery View**: See up to 49 participants at once
   - **Speaker View**: Focus on active speaker (auto-switches)
   - **Virtual Backgrounds**: Replace background with image or blur
   - **Touch Up Appearance**: Smooth skin, adjust lighting
   - **Audio**: VoIP, phone dial-in, mute/unmute controls

3. **Screen Sharing**:
   - **Share screen**: Share entire screen or specific window
   - **Share portion**: Share specific application window only
   - **iPhone/iPad screen**: Share iOS device screen via cable or wireless
   - **Whiteboard**: Collaborative whiteboard for drawing/annotations
   - **Annotations**: Draw, highlight, text on shared screen
   - **Remote control**: Allow participants to control your shared screen

4. **Chat and Messaging**:
   - **In-meeting chat**: Text chat during meetings (public or private DMs)
   - **File sharing**: Share files via chat (drag-and-drop or browse)
   - **Chat channels**: Persistent chat channels outside meetings (team collaboration)
   - **Emoji reactions**: React with emoji during meetings

5. **Recording** (Host Only, License May Be Required):
   - **Local recording**: Save meeting to Mac (free accounts get this)
   - **Cloud recording**: Save to Zoom cloud (requires paid plan)
   - **Audio transcript**: Auto-generate transcript (cloud recording only)
   - **Recording permissions**: Host controls who can record

6. **Breakout Rooms** (Host Only):
   - **Create rooms**: Split meeting into smaller groups
   - **Auto-assign** or **manual assign** participants
   - **Broadcast message**: Send message to all breakout rooms
   - **Timer**: Set time limit for breakout sessions

7. **Security and Controls** (Host):
   - **Waiting room**: Screen participants before admitting
   - **Lock meeting**: Prevent new participants from joining
   - **Mute participants**: Mute all or individual participants
   - **Remove participant**: Kick participant from meeting
   - **Enable/disable**: Screen sharing, chat, rename permissions

**Basic Usage Examples**:

**Joining a Meeting**:
1. **Via Link**: Click Zoom meeting link in email/calendar → Browser opens → Click "Open Zoom" → Enter name → Join
2. **Via Meeting ID**:
   - Open Zoom app
   - Click **Join** button (orange button)
   - Enter 9-digit or 10-digit Meeting ID
   - Enter Meeting Password if required
   - Enter your name
   - Click **Join**
3. **Via Calendar**: Zoom integrates with Google Calendar, Outlook (auto-join from calendar event)

**Hosting a Meeting** (Requires Account):
1. Open Zoom app
2. Click **New Meeting** button
3. Choose video on/off option
4. Meeting starts (you are host)
5. Click **Participants** → **Invite** to invite others (copy link or email)

**Screen Sharing**:
1. Join meeting (or start meeting)
2. Click **Share Screen** button (green button at bottom)
3. Select what to share:
   - **Screen 1/2**: Share entire screen
   - **Application window**: Share specific app (e.g., browser, slides)
   - **Whiteboard**: Share collaborative whiteboard
4. Click **Share** button
5. Screen sharing starts (participants see your screen)
6. Click **Stop Share** (red button at top) to stop sharing

**Muting/Unmuting**:
- **Mute**: Click microphone icon (bottom left) OR press `Space` (hold to talk, release to mute)
- **Unmute**: Click microphone icon again
- **Keyboard shortcut**: `Cmd+Shift+A` to toggle mute/unmute

**Enabling/Disabling Video**:
- **Start video**: Click camera icon (bottom left)
- **Stop video**: Click camera icon again (turns red)
- **Keyboard shortcut**: `Cmd+Shift+V` to toggle video on/off

**Using Chat**:
1. Click **Chat** button (bottom toolbar)
2. Chat panel opens on right side
3. Type message in text field at bottom
4. Choose recipient:
   - **Everyone**: Send to all participants
   - **Specific person**: Send private DM (select from dropdown)
5. Press **Enter** to send message

**Reactions and Hand Raise**:
1. Click **Reactions** button (bottom toolbar)
2. Choose reaction:
   - **Thumbs up** 👍, **Clap** 👏, **Heart** ❤️, etc.
   - Reaction appears briefly on your video feed
3. **Raise Hand**: Click **Reactions** → **Raise Hand** ✋ (host sees raised hand indicator)
4. **Lower Hand**: Click **Reactions** → **Lower Hand**

**Recording a Meeting** (Host Only):
1. Start or join meeting as host
2. Click **Record** button (bottom toolbar)
3. Choose recording location:
   - **Record on this Computer**: Save to Mac (~/Documents/Zoom/)
   - **Record to the Cloud**: Save to Zoom cloud (requires paid plan)
4. Recording starts (indicator appears for all participants)
5. Click **Pause** or **Stop Recording** when done
6. Recording saves after meeting ends (local or cloud)

**Keyboard Shortcuts**:
- **Mute/Unmute**: `Cmd+Shift+A`
- **Start/Stop Video**: `Cmd+Shift+V`
- **Share Screen**: `Cmd+Shift+S`
- **Pause/Resume Screen Share**: `Cmd+Shift+T`
- **Enter/Exit Full Screen**: `Cmd+Shift+F`
- **Switch Camera**: `Cmd+Shift+N` (if multiple cameras)
- **Open Chat**: `Cmd+Shift+H`
- **Show/Hide Participants**: `Cmd+U`
- **View Meeting Info**: `Cmd+I`

**Configuration Tips**:
- **Audio Settings**: Zoom → Settings → Audio → Test microphone/speaker, adjust volume
- **Video Settings**: Zoom → Settings → Video → Choose camera, enable HD, test video
- **Virtual Background**: Zoom → Settings → Background & Effects → Choose image or blur
- **Appearance**: Zoom → Settings → Video → Touch Up Appearance (smooth skin, adjust lighting)
- **Keyboard Shortcuts**: Zoom → Settings → Keyboard Shortcuts → Customize or view all shortcuts
- **Recording Location**: Zoom → Settings → Recording → Choose local save location
- **Bandwidth**: Zoom → Settings → Video → Optimize for video quality vs. bandwidth

**Troubleshooting**:

**Cannot Hear Others / Others Cannot Hear Me**:
- Check microphone/speaker selection: Zoom → Settings → Audio → Test Speaker/Microphone
- Grant microphone permission: System Settings → Privacy & Security → Microphone → Enable Zoom
- Check mute status: Ensure microphone icon is not red (click to unmute)
- Test system audio: Play music outside Zoom to verify Mac audio works
- Restart Zoom app

**Video Not Working**:
- Grant camera permission: System Settings → Privacy & Security → Camera → Enable Zoom
- Check camera selection: Zoom → Settings → Video → Select correct camera
- Ensure camera not in use by another app (quit other video apps)
- Click camera icon in meeting to enable video (must not be red/disabled)
- Restart Zoom app or reboot Mac

**Cannot Share Screen**:
- Grant Screen Recording permission: System Settings → Privacy & Security → Screen Recording → Enable Zoom
- **CRITICAL**: Must **quit and relaunch Zoom** after granting permission (system requirement)
- Click "Share Screen" button in meeting → Select screen/window → Click "Share"
- If still failing, restart Mac (screen recording permission requires full restart sometimes)

**Meeting Won't Start / Cannot Join**:
- Check internet connection (Zoom requires stable internet)
- Verify meeting ID and password are correct (check invite email/calendar)
- Update Zoom via darwin-rebuild: `darwin-rebuild switch`
- Clear Zoom cache: Zoom → Settings → Advanced → Clear Cache
- Try joining via browser: Visit meeting link in browser → Join from browser (fallback)

**Poor Video/Audio Quality**:
- Check bandwidth: Zoom → Settings → Statistics → Network (requires 1.5-3 Mbps for HD video)
- Reduce video quality: Zoom → Settings → Video → Uncheck "HD" or "Enable HD"
- Turn off video: Click camera icon to disable video (reduces bandwidth usage)
- Close bandwidth-heavy apps: Quit streaming, downloads, cloud sync during meeting
- Move closer to Wi-Fi router or use Ethernet connection

**Testing Checklist**:
- [ ] Zoom installed and launches
- [ ] Auto-update disabled (Settings → General → Uncheck "Update automatically")
- [ ] Sign-in screen appears (can sign in with account or skip to guest join)
- [ ] Can join meeting as guest (click "Join a Meeting" → enter ID → join)
- [ ] Microphone permission granted (System Settings → Privacy → Microphone)
- [ ] Camera permission granted (System Settings → Privacy → Camera)
- [ ] Screen recording permission granted (System Settings → Privacy → Screen Recording)
- [ ] Can mute/unmute audio (click microphone icon or Cmd+Shift+A)
- [ ] Can enable/disable video (click camera icon or Cmd+Shift+V)
- [ ] Can share screen (click "Share Screen" → select screen → share works)
- [ ] Can use chat (click "Chat" → type message → send)
- [ ] Can raise hand (click "Reactions" → "Raise Hand")
- [ ] Can record meeting locally if host (click "Record" → "Record on this Computer")
- [ ] Notifications work (meeting reminders appear)
- [ ] App accessible from Spotlight/Raycast

**Documentation**:
- Zoom Help Center: https://support.zoom.us/hc/en-us
- Getting Started Guide: https://support.zoom.us/hc/en-us/articles/360034967471
- Keyboard Shortcuts: https://support.zoom.us/hc/en-us/articles/205683899
- System Requirements: https://support.zoom.us/hc/en-us/articles/201362023
- Pricing Plans: https://zoom.us/pricing

---

## Related Documentation

- [Main Apps Index](../README.md) - Overview of all applications
- [WhatsApp](./whatsapp.md) - Messaging and communication
- [Cisco Webex](./cisco-webex.md) - Enterprise video conferencing
