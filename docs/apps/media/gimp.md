# ABOUTME
# GIMP image editor configuration and usage guide
# Covers installation, first launch, interface layout, tools, and comprehensive editing features

### GIMP

**Status**: Installed via Homebrew cask `gimp` (Story 02.6-001)

**Purpose**: Free, open-source image editor and graphics creation tool. Professional-grade alternative to Adobe Photoshop with comprehensive photo editing, graphic design, and digital art capabilities.

**No Auto-Update to Disable**:
- GIMP is open source with **no automatic update mechanism**
- Updates managed entirely by Homebrew (no in-app settings required)
- Update ONLY via `darwin-rebuild` or `brew upgrade gimp`

**No Account or License Required**:
- GIMP is **free** and open source (GPL license)
- No sign-in, no registration, no license key
- No ads, no tracking, no premium features
- Developed by GIMP community since 1996

**First Launch**:
1. Launch GIMP from Spotlight (`Cmd+Space`, type "GIMP") or from `/Applications/GIMP.app`
2. **Initial Startup** (first launch takes ~10 seconds):
   - GIMP initializes plugins and resources
   - Splash screen appears with loading progress
3. **Main Interface** appears:
   - **Toolbox** (left panel): Selection, paint, transform tools
   - **Canvas** (center): Active image workspace
   - **Docks** (right panel): Layers, channels, paths, brushes, patterns
4. **Single-Window Mode** (Recommended):
   - Default: Multi-window mode (separate windows for toolbox, canvas, docks)
   - **Switch to Single-Window**: Windows → **Single-Window Mode** (check to enable)
   - All panels dock into one unified window (easier to manage)

**Interface Layout**:

GIMP uses a multi-panel interface optimized for professional workflows:

1. **Toolbox Panel** (Left):
   - **Selection Tools**: Rectangle, Ellipse, Free Select, Fuzzy Select (Magic Wand), Select by Color
   - **Paint Tools**: Pencil, Paintbrush, Eraser, Airbrush, Ink, Clone, Heal, Dodge/Burn, Smudge
   - **Transform Tools**: Move, Rotate, Scale, Shear, Perspective, Flip
   - **Color Tools**: Color Picker, Bucket Fill, Blend (Gradient)
   - **Other**: Text, Measure, Zoom, Crop
   - **Foreground/Background Colors**: Click to change (swap with `X` key)

2. **Canvas Area** (Center):
   - Active image workspace with rulers and guides
   - Multiple images open in tabs (Windows → Dockable Dialogs → Images)
   - Zoom controls at bottom (25% to 800%)
   - Right-click for context menu (filters, tools, image operations)

3. **Docks Panel** (Right):
   - **Layers**: Manage image layers (stack, opacity, blend modes)
   - **Channels**: RGB, alpha channel editing
   - **Paths**: Vector paths for precise selections
   - **Brushes**: Select brush shape and size
   - **Patterns**: Choose fill patterns
   - **Gradients**: Color gradient presets
   - **Fonts**: Text tool font selection
   - Customize: Windows → Dockable Dialogs → Add more panels

**Core Features**:

GIMP provides professional image editing capabilities:

1. **Layer Management**:
   - **Create Layers**: Layer → New Layer (or click "New Layer" icon in Layers panel)
   - **Layer Types**: Normal, text, adjustment layers
   - **Blend Modes**: Normal, Multiply, Screen, Overlay, etc. (20+ modes)
   - **Opacity Control**: Adjust layer transparency (0-100%)
   - **Layer Masks**: Non-destructive editing with masks
   - **Layer Groups**: Organize layers into folders
   - **Merge/Flatten**: Combine layers or flatten to single layer

2. **Selection Tools**:
   - **Rectangle/Ellipse Select**: Geometric selections
   - **Free Select** (Lasso): Freehand selection boundary
   - **Fuzzy Select** (Magic Wand): Click to select similar colors
   - **Select by Color**: Select all pixels of chosen color
   - **Intelligent Scissors**: Edge-detection selection
   - **Foreground Select**: Advanced subject isolation
   - **Feather Edges**: Soften selection boundaries
   - **Grow/Shrink**: Expand or contract selection

3. **Painting & Drawing**:
   - **Brush Tool**: Freehand painting with customizable brushes
   - **Pencil Tool**: Hard-edge drawing (no anti-aliasing)
   - **Airbrush**: Pressure-sensitive spray painting
   - **Ink Tool**: Calligraphy and ink-style strokes
   - **Clone Tool**: Copy/stamp from one area to another
   - **Heal Tool**: Remove blemishes/imperfections seamlessly
   - **Blur/Sharpen**: Soften or sharpen details
   - **Dodge/Burn**: Lighten or darken areas

4. **Filters & Effects**:
   - **Blur**: Gaussian, Motion, Pixelate, Mosaic
   - **Enhance**: Sharpen, Denoise, Despeckle, Red Eye Removal
   - **Distort**: Ripple, Whirl, Pinch, Lens Distortion, Perspective
   - **Light & Shadow**: Drop Shadow, Lens Flare, Lighting Effects
   - **Artistic**: Oilify, Cartoon, Cubism, Canvas, Watercolor
   - **Render**: Clouds, Noise, Fractal patterns, Gfig (geometric shapes)
   - **Web**: Optimize for web, ImageMap, Slice

5. **Color Correction**:
   - **Brightness/Contrast**: Basic exposure adjustments
   - **Levels**: Histogram-based tone adjustment
   - **Curves**: Advanced tone curve editing (like Photoshop)
   - **Hue/Saturation**: Adjust color and vibrance
   - **Color Balance**: Shift color tones (shadows, midtones, highlights)
   - **Desaturate**: Convert to grayscale (multiple methods)
   - **Color to Alpha**: Make specific color transparent
   - **Auto Levels/White Balance**: Automatic color correction

6. **Text Tools**:
   - **Text Tool** (shortcut: `T`): Click to add text
   - **Font Selection**: Access all system fonts
   - **Size, Color, Style**: Customize text appearance
   - **Text Layers**: Text remains editable until rasterized
   - **Text Effects**: Apply filters (shadow, outline, warp) to text layers
   - **Text Along Path**: Curve text along any path

**File Format Support**:

**Native Format**:
- **XCF** (GIMP's native format): Preserves layers, channels, paths, transparency
- **Always save working files as .xcf** for non-destructive editing

**Import Formats** (Open):
- **Raster**: PNG, JPG/JPEG, GIF, BMP, TIFF, TGA, PSD (Photoshop), PDF, SVG, WebP
- **RAW Photos**: CR2, NEF, ARW, DNG (requires UFRaw plugin)
- **Vector**: SVG (rasterized on import)
- **Other**: ICO (icons), XPM, XBM

**Export Formats** (Save As):
- **Web**: PNG (lossless, transparency), JPEG (lossy, small size), GIF (animation, 256 colors), WebP
- **Print**: TIFF (uncompressed, high quality), PDF (vector + raster)
- **Photoshop**: PSD (preserves layers, limited compatibility)
- **Other**: BMP, TGA, PPM

**Export vs Save**:
- **Save** (`Cmd+S`): Save as XCF (native format, preserves everything)
- **Export** (`Cmd+Shift+E`): Export to PNG/JPEG/etc. (flattens layers, loses editability)

**Common Use Cases**:

**Opening and Editing a Photo**:
1. File → **Open** (`Cmd+O`) → Select photo
2. Photo opens in canvas
3. Make edits (crop, color correct, retouch)
4. File → **Export As** (`Cmd+Shift+E`) → Choose format (PNG/JPEG) → Export
5. Original XCF remains if saved separately

**Cropping an Image**:
1. Select **Crop Tool** from Toolbox (or press `Shift+C`)
2. Click and drag to select crop area
3. Adjust crop boundaries (drag corners/edges)
4. Press **Enter** to apply crop (or click inside crop area)
5. Image cropped to selection

**Resizing an Image**:
1. Image → **Scale Image**
2. Enter new dimensions (width × height)
3. **Chain icon**: Lock aspect ratio (width/height stay proportional)
4. **Interpolation**: Choose quality (Cubic = best quality, slower)
5. Click **Scale**
6. Image resized

**Removing Background** (Make Transparent):
1. Layer → **Transparency** → **Add Alpha Channel** (if not already present)
2. Select **Fuzzy Select** (Magic Wand) or **Select by Color**
3. Click background to select
4. Press **Delete** (background becomes transparent checkerboard)
5. Export as **PNG** to preserve transparency (JPEG doesn't support transparency)

**Adding Text to Image**:
1. Select **Text Tool** from Toolbox (or press `T`)
2. Click on image where text should appear
3. Text editor dialog opens → Type text
4. Customize font, size, color in **Tool Options** dock
5. Click **Close** when done
6. Text layer created (editable until rasterized)

**Adjusting Colors** (Brightness/Contrast):
1. Colors → **Brightness-Contrast** (basic) OR **Levels** (advanced)
2. **Brightness-Contrast**:
   - Drag sliders to adjust
   - Preview updates in real-time
   - Click **OK** to apply
3. **Levels** (more control):
   - Drag black/white point handles on histogram
   - Adjust mid-tones with gray slider
   - Click **OK** to apply

**Creating a New Image from Scratch**:
1. File → **New** (`Cmd+N`)
2. Set dimensions (e.g., 1920 × 1080 for web graphics)
3. Choose **Fill with**: White, Foreground color, Background color, Transparency
4. Click **OK**
5. Blank canvas appears → Start creating

**Batch Processing** (Apply Same Edit to Multiple Images):
1. Filters → **Batch Processing** → **DBP (David's Batch Processor)** (plugin)
2. OR use **Script-Fu**: Filters → Script-Fu → Console (for advanced users)
3. OR automate with Python-Fu scripting

**Interface Customization**:

1. **Single-Window Mode** (Recommended):
   - Windows → **Single-Window Mode** (check to enable)
   - All panels in one window (easier window management)
   - Disable for multi-monitor setups (separate windows per screen)

2. **Dark Theme**:
   - Edit → Preferences → Interface → Theme → Select **Dark** or **System**
   - Icon Theme: Choose icon style (Symbolic, Color, Legacy)

3. **Customize Toolbox**:
   - Edit → Preferences → Toolbox
   - Choose which tools appear in Toolbox
   - Enable/disable color swatches, brush indicators

4. **Keyboard Shortcuts**:
   - Edit → Keyboard Shortcuts
   - Search for function → Click to set custom shortcut
   - Export/import shortcut sets for backup

**Essential Keyboard Shortcuts**:

| Action | Shortcut | Description |
|--------|----------|-------------|
| New Image | `Cmd+N` | Create new image |
| Open | `Cmd+O` | Open image file |
| Save (XCF) | `Cmd+S` | Save as native XCF |
| Export | `Cmd+Shift+E` | Export as PNG/JPEG/etc. |
| Undo | `Cmd+Z` | Undo last action |
| Redo | `Cmd+Y` | Redo undone action |
| Copy | `Cmd+C` | Copy selection |
| Paste | `Cmd+V` | Paste as new layer |
| Select All | `Cmd+A` | Select entire image |
| Deselect | `Cmd+Shift+A` | Remove selection |
| Zoom In/Out | `+` / `-` | Zoom canvas |
| Fit in Window | `Cmd+Shift+E` | Fit image to window |
| Fullscreen | `F11` | Toggle fullscreen |
| Toolbox | `Ctrl+B` | Show/hide Toolbox |

**Full List**: Help → Keyboard Shortcuts

**Learning Resources**:

1. **Built-in Help**:
   - Help → **User Manual** (comprehensive documentation)
   - Help → **Procedure Browser** (search all functions)
   - Context-sensitive: Press `F1` with tool selected for help

2. **Official Tutorials**:
   - GIMP.org tutorials: https://www.gimp.org/tutorials/
   - Beginner to advanced lessons
   - Photo retouching, web graphics, drawing techniques

3. **Third-Party Resources**:
   - **YouTube**: Search "GIMP tutorial [topic]" (thousands of videos)
   - **GIMPTalk Forums**: Community support and tips
   - **Books**: "GIMP 2.10 for Photographers" by John M. Williams

**Troubleshooting**:

**GIMP Slow Performance**:
- Preferences → Environment → Tile Cache Size → Increase (e.g., 2048MB for 8GB RAM)
- Preferences → Image Windows → Use "Pixel data" for speed (not "Gegl")
- Close unused images (free memory)
- Reduce brush size (large brushes = slower)

**Text Looks Blurry**:
- Ensure **Hinting** enabled: Preferences → Toolbox → Text Tool → Hinting: Full
- Increase font size (small fonts may appear fuzzy)
- Use TrueType/OpenType fonts (better quality than bitmap fonts)

**Can't Export to JPEG/PNG**:
- Use **File → Export As** (`Cmd+Shift+E`), NOT "Save"
- "Save" only works for .xcf format
- Export flattens layers to raster format

**Layers Disappeared**:
- Check **Layers panel** visibility: Windows → Dockable Dialogs → Layers
- Layer may be hidden: Click "eye" icon to show
- Layer may be below another layer: Drag to reorder

**Color Picker Selects Wrong Color**:
- Ensure working on correct layer (check Layers panel)
- Image may be indexed color mode: Image → Mode → **RGB** (convert to full color)
- Zoom in for precise color selection

**Brush Not Working**:
- Check layer has alpha channel: Layer → Transparency → **Add Alpha Channel**
- Ensure layer not locked: Uncheck lock icon in Layers panel
- Verify brush opacity >0% (Tool Options → Opacity slider)

**Testing Checklist**:
- [ ] GIMP installed and launches
- [ ] Single-window mode enabled (Windows → Single-Window Mode)
- [ ] Can create new image (File → New)
- [ ] Can open existing image (File → Open)
- [ ] Can select and use basic tools (brush, eraser, crop, text)
- [ ] Layers panel visible and functional (create layer, adjust opacity)
- [ ] Can apply filters (Filters → Blur → Gaussian Blur)
- [ ] Can adjust colors (Colors → Brightness-Contrast)
- [ ] Can save as XCF (File → Save)
- [ ] Can export as PNG (File → Export As → .png)
- [ ] Can export as JPEG (File → Export As → .jpg)
- [ ] Undo/Redo works (`Cmd+Z` / `Cmd+Y`)
- [ ] App accessible from Spotlight/Raycast
- [ ] Dark theme enabled (Edit → Preferences → Interface → Theme: Dark)
- [ ] Help system accessible (Help → User Manual)

**Documentation**:
- GIMP Official Site: https://www.gimp.org/
- User Manual: https://docs.gimp.org/
- Tutorials: https://www.gimp.org/tutorials/
- Keyboard Shortcuts: https://docs.gimp.org/en/gimp-shortcuts.html
- Plugin Registry: https://registry.gimp.org/

---

## Related Documentation

- [Main Apps Index](../README.md)
- [VLC Media Player](./vlc.md)
- [Media Tools Overview](./README.md)
