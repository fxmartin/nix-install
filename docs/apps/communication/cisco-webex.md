# ABOUTME
Configuration and usage guide for Cisco Webex video conferencing on macOS. Covers auto-update disabling, account setup, features, permissions, and troubleshooting.

### Cisco Webex

**Status**: Installed via Homebrew cask `webex` (Story 02.5-002)

**Purpose**: Enterprise video conferencing and collaboration platform. Join or host Webex meetings, webinars, and team collaboration with screen sharing, whiteboard, recording, and advanced enterprise features.

**⚠️ CRITICAL - AUTO-UPDATE DISABLE REQUIRED**

Webex may have **automatic update checking** depending on version and admin settings. Check and disable if available to maintain control via Homebrew.

**Auto-Update Disable Steps** (IF AVAILABLE):
1. Launch Webex
2. Open **Preferences**:
   - Click your **profile picture** or **gear icon** (top right)
   - Select **Preferences** or **Settings**
3. Navigate to **General** or **Updates** tab
4. Look for **"Automatically check for updates"** or similar option
5. **Uncheck** or **Disable** this option if present
6. Close Preferences (changes save automatically)

**Note**: Some Webex deployments are managed by enterprise IT and may not show auto-update options (updates controlled by admin). In this case, auto-update disable is not required since IT manages updates.

**Verification**:
```bash
# Webex version managed by Homebrew
brew list --cask webex --versions
# Updates ONLY via darwin-rebuild (unless IT-managed)
```

**Account Requirement**:

Webex **requires** an account to use. You cannot use Webex as a guest (unlike Zoom).

1. **Company Account** (Most Common):
   - Provided by employer for work meetings
   - Sign in with company email and password (or SSO)
   - May be managed by IT (policies, features, restrictions)
   - May include licensed features (cloud recording, large meetings)

2. **Free Webex Account**:
   - Create free account at https://www.webex.com/pricing/free-trial.html
   - Sign up with personal email
   - **Meeting limits**: 50-minute limit for meetings
   - **Participant limits**: Up to 100 participants
   - **Features**: Host meetings, screen sharing, whiteboard, chat

3. **Paid Plans** (Licensed):
   - **Webex Meet** ($14.50/month): Unlimited meeting duration, 100 participants
   - **Webex Suite** ($25/month): Calling, messaging, polling, cloud storage
   - **Enterprise**: Custom pricing with advanced features and support

**First Launch**:
1. Launch Webex from Spotlight (`Cmd+Space`, type "Webex") or from `/Applications/Webex.app`
2. **Sign In** screen appears:
   - **Email Address**: Enter your company email or Webex account email
   - **Password**: Enter password OR use **SSO** (if company uses SSO)
   - **Sign In with Google/Microsoft**: Use Google or Microsoft account
3. Sign in with appropriate credentials:
   - **Work account**: Use company email and password (or SSO via company portal)
   - **Personal account**: Use personal Webex account credentials
4. After sign-in, Webex shows main interface with upcoming meetings and quick actions

**Permissions Required**:

Webex requests several macOS permissions for full functionality:

1. **Microphone** (Required for Audio):
   - **Purpose**: Enable audio in meetings (speak and be heard)
   - **Prompt**: Appears on first meeting join or when testing audio
   - **Recommendation**: **Allow** (essential for meetings)
   - **Manual Enable**: System Settings → Privacy & Security → Microphone → Enable Webex

2. **Camera** (Required for Video):
   - **Purpose**: Enable video in meetings (share your video feed)
   - **Prompt**: Appears when enabling video for first time
   - **Recommendation**: **Allow** (required for video meetings)
   - **Manual Enable**: System Settings → Privacy & Security → Camera → Enable Webex

3. **Screen Recording** (Required for Screen Sharing):
   - **Purpose**: Share your screen with meeting participants
   - **Prompt**: Appears when attempting first screen share
   - **Recommendation**: **Allow** (essential for presentations)
   - **Manual Enable**: System Settings → Privacy & Security → Screen Recording → Enable Webex

4. **Accessibility** (Optional, for Advanced Features):
   - **Purpose**: Remote control during screen sharing, whiteboard annotations
   - **Prompt**: May appear when using advanced collaboration features
   - **Recommendation**: **Optional** (only if using remote control)
   - **Manual Enable**: System Settings → Privacy & Security → Accessibility → Enable Webex

5. **Notifications** (Optional):
   - **Purpose**: Meeting reminders, chat notifications, incoming call alerts
   - **Prompt**: Appears after first meeting
   - **Recommendation**: **Allow** (helpful for meeting reminders)
   - **Manual Enable**: System Settings → Notifications → Webex → Enable

**Core Features**:

Webex provides comprehensive enterprise video conferencing and collaboration:

1. **Meeting Types**:
   - **Instant Meeting**: Start meeting immediately from Webex app
   - **Scheduled Meeting**: Schedule with date/time, calendar integration
   - **Personal Room**: Permanent meeting room with fixed URL
   - **Join Meeting**: Join via link, meeting number, or calendar

2. **Video and Audio**:
   - **HD Video**: 720p or 1080p video quality
   - **Grid View**: See up to 25 participants (or more with layout options)
   - **Active Speaker View**: Focus on current speaker (auto-switches)
   - **Virtual Background**: Replace background with image or blur
   - **Noise Removal**: AI-powered background noise cancellation
   - **Audio**: VoIP, phone dial-in, mute/unmute with visual indicators

3. **Screen Sharing and Whiteboard**:
   - **Share screen**: Share entire screen or specific application window
   - **Share file**: Share document or presentation directly
   - **Whiteboard**: Collaborative whiteboard with drawing tools
   - **Annotations**: Draw, highlight, text on shared content
   - **Remote control**: Allow participants to control shared screen
   - **Share optimized for video**: Optimize sharing for video playback

4. **Chat and Messaging**:
   - **In-meeting chat**: Text chat during meetings (everyone or private)
   - **Persistent team spaces**: Chat rooms for ongoing team collaboration
   - **File sharing**: Share files via chat (drag-and-drop or browse)
   - **@mentions**: Mention specific people to get their attention
   - **Emoji reactions**: React with emoji during meetings

5. **Recording** (License Dependent):
   - **Local recording**: Save meeting to Mac (may require license)
   - **Cloud recording**: Save to Webex cloud (requires paid plan)
   - **Automatic transcription**: AI-generated transcripts (cloud recording)
   - **Recording sharing**: Share recording link with attendees

6. **Advanced Features**:
   - **Breakout sessions**: Split meeting into smaller groups (host)
   - **Polling**: Create and run polls during meetings (host)
   - **Q&A**: Structured question and answer sessions (webinars)
   - **Hand raise**: Participants raise hand to signal they want to speak
   - **Reactions**: Emoji reactions visible to all participants
   - **Closed captions**: Real-time automated captions

**Basic Usage Examples**:

**Joining a Meeting**:
1. **Via Link**: Click Webex meeting link in email/calendar → Browser opens → Click "Open Webex" → Meeting launches
2. **Via Meeting Number**:
   - Open Webex app
   - Click **Join** button
   - Enter 9-digit or 11-digit Meeting Number
   - Enter Meeting Password if required
   - Enter your name and email
   - Click **Join Meeting**
3. **Via Calendar**: Webex integrates with Outlook, Google Calendar (auto-join from calendar event)

**Hosting a Meeting** (Requires Account):
1. Open Webex app
2. Click **Start a Meeting** button (or **Meet Now**)
3. Choose audio/video settings
4. Meeting starts (you are host)
5. Click **Invite** to add participants (copy link, email invite, or call)

**Screen Sharing**:
1. Join or start meeting
2. Click **Share Screen** button (bottom toolbar)
3. Select what to share:
   - **Screen**: Share entire screen
   - **Application**: Share specific window (e.g., browser, PowerPoint)
   - **Whiteboard**: Share collaborative whiteboard
   - **File**: Share document or presentation
4. Click **Share** button
5. Screen sharing starts (red border indicates sharing active)
6. Click **Stop Sharing** button (floating toolbar) to stop

**Muting/Unmuting**:
- **Mute**: Click microphone icon (bottom left) OR press `Cmd+Shift+M`
- **Unmute**: Click microphone icon again OR press and hold `Space` (push-to-talk)
- **Keyboard shortcut**: `Cmd+Shift+M` to toggle mute/unmute

**Enabling/Disabling Video**:
- **Start video**: Click camera icon (bottom left)
- **Stop video**: Click camera icon again (icon turns red with slash)
- **Keyboard shortcut**: `Cmd+Shift+V` to toggle video on/off

**Using Chat**:
1. Click **Chat** icon (bottom toolbar or right panel)
2. Chat panel opens
3. Type message in text field at bottom
4. Choose recipient:
   - **Everyone**: Send to all participants (default)
   - **Specific person**: Select person from dropdown (private message)
5. Press **Enter** to send message

**Using Whiteboard**:
1. Click **Share Screen** → **Whiteboard** → **Share**
2. Whiteboard opens (blank canvas)
3. Use tools:
   - **Pen**: Draw freehand
   - **Shapes**: Add circles, squares, arrows
   - **Text**: Add text boxes
   - **Sticky notes**: Add colored notes
4. Collaborators can draw simultaneously (if permissions granted)
5. Click **Stop Sharing** when done

**Reactions and Hand Raise**:
1. Click **Reactions** button (bottom toolbar)
2. Choose reaction: 👍 Thumbs up, 👏 Clap, ❤️ Heart, 😂 Laugh, etc.
3. Reaction appears briefly next to your name
4. **Raise Hand**: Click **Raise Hand** button (or Reactions → Raise Hand)
5. **Lower Hand**: Click **Lower Hand** button (or Reactions → Lower Hand)

**Recording a Meeting** (Host Only, License May Be Required):
1. Start or join meeting as host
2. Click **Record** button (bottom toolbar)
3. Choose recording location:
   - **Record on this Computer**: Save to Mac (may require license)
   - **Record to Cloud**: Save to Webex cloud (requires paid plan)
4. Recording starts (indicator shows "Recording" for all participants)
5. Click **Pause** or **Stop Recording** when done
6. Recording saves after meeting ends

**Keyboard Shortcuts**:
- **Mute/Unmute**: `Cmd+Shift+M`
- **Start/Stop Video**: `Cmd+Shift+V`
- **Share Screen**: `Cmd+Shift+S`
- **Open Chat**: `Cmd+Shift+W`
- **Raise/Lower Hand**: `Cmd+Shift+Y`
- **Show Participants**: `Cmd+Shift+P`
- **Full Screen**: `Cmd+Shift+F`
- **Leave/End Meeting**: `Cmd+L`

**Configuration Tips**:
- **Audio Settings**: Webex → Preferences → Audio → Test speaker/microphone, adjust volume
- **Video Settings**: Webex → Preferences → Video → Choose camera, enable HD, mirror video
- **Virtual Background**: Webex → Preferences → Virtual Background → Choose image or blur
- **Noise Removal**: Webex → Preferences → Audio → Enable "Remove background noise"
- **Keyboard Shortcuts**: Webex → Preferences → Keyboard Shortcuts → View or customize shortcuts
- **Notifications**: Webex → Preferences → Notifications → Customize alert sounds and badges

**Troubleshooting**:

**Cannot Hear Others / Others Cannot Hear Me**:
- Check microphone/speaker selection: Webex → Preferences → Audio → Test Speaker/Microphone
- Grant microphone permission: System Settings → Privacy & Security → Microphone → Enable Webex
- Check mute status: Ensure microphone icon is not red/slashed (click to unmute)
- Test system audio: Play music outside Webex to verify Mac audio works
- Restart Webex app

**Video Not Working**:
- Grant camera permission: System Settings → Privacy & Security → Camera → Enable Webex
- Check camera selection: Webex → Preferences → Video → Select correct camera
- Ensure camera not in use by another app (quit Zoom, FaceTime, etc.)
- Click camera icon in meeting to enable video (must not be red/slashed)
- Restart Webex app or reboot Mac

**Cannot Share Screen**:
- Grant Screen Recording permission: System Settings → Privacy & Security → Screen Recording → Enable Webex
- **CRITICAL**: Must **quit and relaunch Webex** after granting permission
- Click "Share Screen" button → Select screen/window → Click "Share"
- If still failing, restart Mac (screen recording permission may require restart)

**Meeting Won't Join / Connection Issues**:
- Check internet connection (Webex requires stable internet)
- Verify meeting number and password are correct (check invite email)
- Try alternate join method: Click meeting link in browser → Join from browser
- Update Webex via darwin-rebuild: `darwin-rebuild switch`
- Clear Webex cache: Webex → Help → Health Checker → Clear Cache

**Sign-In Issues**:
- Verify company email and password are correct
- Try **SSO** (Sign in with company portal) if available
- Reset password: Click "Forgot password?" on sign-in screen
- Contact IT admin if using company account (may be account lockout/policy issue)
- Check firewall/VPN: Some corporate networks block Webex (try different network)

**Poor Video/Audio Quality**:
- Check bandwidth: Webex → Help → Health Checker → Run Network Test
- Reduce video quality: Webex → Preferences → Video → Uncheck "HD video"
- Turn off video: Click camera icon to disable (reduces bandwidth)
- Close bandwidth-heavy apps: Quit streaming, downloads, cloud sync
- Move closer to Wi-Fi router or use Ethernet connection
- Enable noise removal: Webex → Preferences → Audio → "Remove background noise"

**Testing Checklist**:
- [ ] Webex installed and launches
- [ ] Auto-update disabled if option available (Preferences → General/Updates)
- [ ] Sign-in screen appears
- [ ] Can sign in with company or personal account
- [ ] Microphone permission granted (System Settings → Privacy → Microphone)
- [ ] Camera permission granted (System Settings → Privacy → Camera)
- [ ] Screen recording permission granted (System Settings → Privacy → Screen Recording)
- [ ] Can join meeting (click meeting link or enter meeting number)
- [ ] Can mute/unmute audio (click microphone icon or Cmd+Shift+M)
- [ ] Can enable/disable video (click camera icon or Cmd+Shift+V)
- [ ] Can share screen (click "Share Screen" → select screen → share works)
- [ ] Can use chat (click "Chat" → type message → send)
- [ ] Can raise hand (click "Raise Hand" button or Cmd+Shift+Y)
- [ ] Can use whiteboard (click "Share" → "Whiteboard" → draw on canvas)
- [ ] Notifications work (meeting reminders appear)
- [ ] App accessible from Spotlight/Raycast

**Documentation**:
- Webex Help Center: https://help.webex.com/
- Getting Started: https://help.webex.com/en-us/article/n62wi3c/Get-Started-with-Webex
- Keyboard Shortcuts: https://help.webex.com/en-us/article/guz7r/Keyboard-Shortcuts-for-Webex-Meetings
- System Requirements: https://help.webex.com/en-us/article/WBX000028782/
- Pricing Plans: https://www.webex.com/pricing/

---

## Related Documentation

- [Main Apps Index](../README.md) - Overview of all applications
- [WhatsApp](./whatsapp.md) - Messaging and communication
- [Zoom](./zoom.md) - Video conferencing and meetings
