# ABOUTME
# VLC Media Player configuration and usage guide
# Covers installation, auto-update disabling, first launch, core features, and troubleshooting

### VLC Media Player

**Status**: Installed via Homebrew cask `vlc` (Story 02.6-001)

**Purpose**: Free, open-source universal media player supporting 100+ audio and video formats. Play local media files, DVDs, network streams, and online content without codec hassles.

**⚠️ CRITICAL - AUTO-UPDATE DISABLE REQUIRED**

VLC has **automatic update checking enabled by default**. You must disable this to maintain control via Homebrew.

**Auto-Update Disable Steps** (MANDATORY):
1. Launch VLC Media Player
2. Open **Preferences**:
   - macOS: **VLC** menu → **Preferences** (or press `Cmd+,`)
3. Navigate to **General** or **Interface** tab (location varies by version)
4. Look for **"Automatically check for updates"** checkbox
5. **Uncheck** this option
6. Click **Save** or **OK**
7. Restart VLC to apply changes

**Verification**:
```bash
# VLC version managed by Homebrew
brew list --cask vlc --versions
# Updates ONLY via darwin-rebuild, never automatic
```

**No Account or License Required**:
- VLC is **free** and open source (GPL license)
- No sign-in, no registration, no license key
- No ads, no tracking, no premium features
- Developed by VideoLAN non-profit organization since 1996

**First Launch**:
1. Launch VLC from Spotlight (`Cmd+Space`, type "VLC") or from `/Applications/VLC.app`
2. **Privacy & Network Access** dialog may appear:
   - **Allow metadata and album art downloads**: Optional (enables automatic cover art)
   - **Check for updates**: **DECLINE** or **Disable** (we manage updates via Homebrew)
3. **Interface Customization** (optional):
   - Choose default interface style (modern or classic)
   - Customize toolbar and controls
4. VLC is ready to use immediately

**Core Features**:

VLC provides comprehensive media playback capabilities:

1. **Universal Format Support**:
   - **Video**: MP4, MKV, AVI, MOV, WMV, FLV, MPEG, WebM, OGV, 3GP, etc.
   - **Audio**: MP3, FLAC, AAC, OGG, WAV, WMA, ALAC, M4A, etc.
   - **Subtitles**: SRT, ASS, SSA, VTT, embedded subtitles
   - **DVD/Blu-ray**: Play encrypted DVDs (region-free with libdvdcss)
   - **Streaming**: HTTP, RTSP, RTP, MMS, UDP protocols
   - **Playlists**: M3U, PLS, XSPF, CUE formats

2. **Playback Controls**:
   - Standard controls: Play, pause, stop, next, previous
   - **Speed Control**: Slow motion (0.25×) to fast forward (4×)
   - **Frame-by-frame**: Step through video frame by frame (press `E`)
   - **A-B Loop**: Repeat section between two points
   - **Bookmarks**: Save positions in long videos
   - **Resume Playback**: Continue from last position

3. **Audio & Video Adjustments**:
   - **Volume Boost**: Up to 200% volume (beyond system max)
   - **Equalizer**: 10-band audio equalizer with presets
   - **Audio Delay**: Sync audio with video (fix lip-sync issues)
   - **Video Adjustments**: Brightness, contrast, saturation, gamma, hue
   - **Deinterlacing**: Fix interlaced video artifacts
   - **Aspect Ratio**: Force 16:9, 4:3, or custom ratios

4. **Subtitle Management**:
   - **Load Subtitles**: Drag .srt file into player OR **Subtitle** menu → **Open File**
   - **Auto-Detection**: VLC finds .srt files matching video name in same folder
   - **Subtitle Delay**: Sync subtitles with audio/video (press `H` or `J`)
   - **Font & Size**: Customize subtitle appearance (Preferences → Subtitles/OSD)
   - **Multiple Tracks**: Switch between embedded subtitle tracks

5. **Playlist Management**:
   - **Playlist View**: View → Playlist (`Cmd+L`) shows queue
   - **Add Media**: Drag files into playlist OR File → Open File/Folder
   - **Shuffle & Repeat**: Randomize playback, repeat all/one
   - **Save Playlist**: Export as M3U/XSPF for later
   - **Media Library**: Organize media by folders, artists, albums

6. **Network Streaming**:
   - **Open Network Stream**: File → Open Network → Enter URL
   - **Supported Protocols**: HTTP, HTTPS, FTP, RTSP, MMS, UDP
   - **YouTube/Online Video**: Paste video URL to stream (may require VLC update for site changes)
   - **IPTV/M3U Streams**: Load IPTV playlists for live streaming

**Common Use Cases**:

**Playing a Video File**:
1. **Drag and Drop**: Drag video file onto VLC window
2. OR **File Menu**: File → Open File (`Cmd+O`) → Select video
3. OR **Double-Click**: Set VLC as default player (see below) → Double-click video
4. Video plays immediately

**Playing a DVD**:
1. Insert DVD into Mac's optical drive (or external drive)
2. File → Open Disc (`Cmd+D`)
3. Select disc type (DVD/Blu-ray)
4. Click **Open**
5. DVD menu appears (navigate with arrow keys + Enter)

**Loading Subtitles**:
1. Play video file
2. **Drag .srt file** into VLC window (easiest method)
3. OR **Subtitle menu** → **Add Subtitle File** → Select .srt
4. Subtitles appear automatically
5. **Sync subtitles**: Press `H` to delay, `J` to advance (50ms increments)

**Adjusting Audio/Video Sync**:
1. Play video
2. **Tools** menu → **Track Synchronization** (or press `Cmd+K`)
3. **Audio Track Synchronization**:
   - Negative values: Audio plays earlier
   - Positive values: Audio plays later
   - Adjust in 50ms increments until lips match audio
4. Click **Close** when synced

**Streaming Online Video**:
1. Copy video URL (e.g., YouTube, Vimeo, direct video link)
2. File → **Open Network** (`Cmd+N`)
3. Paste URL into text field
4. Click **Open**
5. Video streams directly (no download required)

**Setting VLC as Default Player**:
1. Right-click any video file in Finder
2. **Get Info** (`Cmd+I`)
3. **Open With** section → Select **VLC.app**
4. Click **Change All...** button
5. Confirm "Are you sure?" dialog
6. All videos of this type now open in VLC by default

**Advanced Features**:

1. **Video Conversion**:
   - **Convert/Save**: File → Convert/Stream → Add media → Convert
   - Choose output format (MP4, WebM, OGG, etc.)
   - Select codec and quality settings
   - Click **Save as File** → Choose destination
   - VLC transcodes video to new format

2. **Screen Recording** (Capture Desktop):
   - File → Open Capture Device
   - **Capture Mode**: Screen
   - Choose display or window
   - Click **Capture** button dropdown → **Stream**
   - Configure output destination and format
   - Start recording

3. **Audio Visualization**:
   - **Tools** menu → **Effects and Filters** (`Cmd+E`)
   - **Audio Effects** tab → **Visualization**
   - Enable visualizer (spectrum, scope, etc.)
   - Visualization appears during audio playback

4. **Take Screenshots**:
   - **Video** menu → **Take Snapshot** (or press `Cmd+Alt+S`)
   - Screenshot saved to ~/Pictures by default
   - Configure path: Preferences → Video → Video snapshot directory

5. **Audio Passthrough** (for surround sound):
   - Preferences → Audio → Output modules
   - Enable **S/PDIF** or **HDMI** passthrough
   - Send Dolby/DTS audio directly to receiver

**Keyboard Shortcuts** (Essential):

| Action | Shortcut | Description |
|--------|----------|-------------|
| Play/Pause | `Space` | Toggle playback |
| Fullscreen | `F` or `Cmd+F` | Toggle fullscreen mode |
| Volume Up/Down | `Cmd+Up` / `Cmd+Down` | Adjust volume |
| Mute | `Cmd+Alt+Down` | Mute audio |
| Next/Previous | `N` / `P` | Jump to next/previous file |
| Forward/Backward | `Cmd+Right` / `Cmd+Left` | Skip 10 seconds |
| Fast Forward/Rewind | `Alt+Right` / `Alt+Left` | Skip 1 minute |
| Subtitle Delay | `H` / `J` | Delay/advance subtitles 50ms |
| Speed Up/Down | `]` / `[` | Adjust playback speed |
| Frame by Frame | `E` | Step one frame forward |
| Take Snapshot | `Cmd+Alt+S` | Screenshot current frame |
| Quit | `Cmd+Q` | Exit VLC |

**Full List**: Help → Keyboard Shortcuts (`Cmd+?`)

**Configuration Tips**:

1. **Default Interface**:
   - Preferences → Interface → Choose "Minimal" or "Native" style
   - Minimal: Modern, clean, minimal controls
   - Native: Traditional VLC interface with all controls visible

2. **Resume Playback**:
   - Preferences → Interface → **Continue playback?**: Ask, Always, Never
   - "Always" resumes from last position automatically

3. **File Association**:
   - Preferences → Interface → **Associate files** button
   - Select all media types to open with VLC by default

4. **Performance**:
   - Preferences → Input/Codecs → **Hardware-accelerated decoding**: Enable
   - Uses Mac GPU for smoother 4K/high-res playback
   - Reduces CPU usage and heat

5. **Subtitle Font**:
   - Preferences → Subtitles/OSD → Font, size, color customization
   - Increase size for 4K displays or viewing from distance

**Troubleshooting**:

**Video Won't Play / Codec Error**:
- VLC supports 99% of formats - rarely a codec issue
- Try: Tools → Codec Information → Check codec details
- Update VLC via Homebrew: `brew upgrade vlc` (or `darwin-rebuild`)
- Re-download video file (may be corrupted)

**Subtitles Not Appearing**:
- Ensure subtitle file has same name as video (e.g., `movie.mp4` + `movie.srt`)
- Subtitle file must be in same folder as video
- Manually load: Subtitle → Add Subtitle File
- Check subtitle track: Subtitle menu → Subtitle Track → Select correct track

**Audio/Video Out of Sync**:
- Tools → Track Synchronization (`Cmd+K`)
- Adjust **Audio Track Synchronization** slider
- Positive = delay audio, Negative = advance audio
- Fine-tune in 50ms increments

**VLC Performance Issues / Stuttering**:
- Enable hardware acceleration: Preferences → Input/Codecs → Hardware-accelerated decoding
- Reduce video quality: Tools → Effects and Filters → Video Effects → Reduce resolution
- Close other apps (free RAM/CPU resources)
- Try different output module: Preferences → Video → Output: Try "macOS video output"

**DVD Won't Play (Encryption)**:
- Install libdvdcss for encrypted DVD support:
  ```bash
  # Via Homebrew
  brew install libdvdcss
  ```
- Restart VLC after installation
- DVD should play normally

**Online Stream Not Loading**:
- URL may be expired or geo-blocked
- Try updating VLC (sites change APIs frequently)
- Use browser to verify URL works
- Check internet connection

**Testing Checklist**:
- [ ] VLC installed and launches
- [ ] Auto-update disabled (Preferences → General → Uncheck auto-update)
- [ ] Can play video file (drag and drop)
- [ ] Can play audio file (MP3, FLAC)
- [ ] Subtitles load automatically (.srt in same folder as video)
- [ ] Volume controls work (including boost >100%)
- [ ] Fullscreen mode works (press `F`)
- [ ] Playback speed control works (`[` and `]` keys)
- [ ] Can stream online video (File → Open Network → paste URL)
- [ ] Keyboard shortcuts functional (Space, arrows, etc.)
- [ ] Can take screenshot (Cmd+Alt+S)
- [ ] App accessible from Spotlight/Raycast
- [ ] Hardware acceleration enabled (Preferences → Input/Codecs)
- [ ] Resume playback works (stop video → reopen → continues from last position)

**Documentation**:
- VLC Official Site: https://www.videolan.org/vlc/
- User Guide: https://www.videolan.org/support/
- Keyboard Shortcuts: https://wiki.videolan.org/Mac_OS_X_shortcuts/
- Format Support: https://wiki.videolan.org/VLC_Features_Formats/

---

## Related Documentation

- [Main Apps Index](../README.md)
- [GIMP - Image Editor](./gimp.md)
- [Media Tools Overview](./README.md)
