# Calibre Secrets Configuration

This directory contains Calibre plugins and settings. **Sensitive data is NOT stored in git.**

## Secrets Location

Sensitive files are stored locally in `~/.config/calibre-secrets/`:

```
~/.config/calibre-secrets/
├── dedrm.json                    # Kindle serial, Adobe DRM keys
└── DeACSM/
    └── account/
        ├── activation.xml        # Adobe account activation
        ├── device.xml            # Adobe device registration
        └── devicesalt            # Adobe encryption salt
```

## Setup Instructions

### 1. Create secrets directory
```bash
mkdir -p ~/.config/calibre-secrets/DeACSM/account
chmod 700 ~/.config/calibre-secrets
```

### 2. Create dedrm.json
Copy the template and add your Kindle serial:
```bash
cp config/calibre/plugins/dedrm.json.template ~/.config/calibre-secrets/dedrm.json
# Edit and add your Kindle serial number (Settings → Device Info on Kindle)
chmod 600 ~/.config/calibre-secrets/dedrm.json
```

### 3. Adobe DRM (optional)
If using DeACSM for Adobe DRM, copy your account files:
- Export from existing Calibre installation, or
- Set up DeACSM plugin in Calibre and copy the generated files

### 4. Run rebuild
```bash
rebuild
```

The activation script will merge secrets into the deployed Calibre config.

## Finding Your Kindle Serial

1. On your Kindle device: **Settings** → **Device Info**
2. Note the 16-character **Serial Number**
3. Add to `serials` array in `dedrm.json`

## Security Notes

- Never commit `dedrm.json` or `DeACSM/account/` to git
- These files contain DRM keys tied to your accounts
- The `.gitignore` excludes these paths automatically
