# Calibre Secrets Configuration

Sensitive Calibre values are stored outside this repository in
`~/.config/calibre-secrets/`:

```text
~/.config/calibre-secrets/
├── dedrm.json
├── bookfusion.json
└── DeACSM/
    └── account/
        ├── activation.xml
        ├── device.xml
        └── devicesalt
```

Create the directory with owner-only permissions:

```bash
mkdir -p ~/.config/calibre-secrets/DeACSM/account
chmod 700 ~/.config/calibre-secrets
```

Copy the tracked template before adding a Kindle serial number:

```bash
cp config/calibre/plugins/dedrm.json.template ~/.config/calibre-secrets/dedrm.json
chmod 600 ~/.config/calibre-secrets/dedrm.json
```

Optional BookFusion and Adobe account files can be copied from an existing
Calibre installation. Keep every file below `~/.config/calibre-secrets/` at
mode `0600`; never copy credentials, serial numbers, activation XML, or API
keys into this repository.
