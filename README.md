# OnePlus 11R (udon) crDroid Port

Pioneer Android 15 port for OnePlus 11R (SM8450/taro, Snapdragon 8+ Gen 1).
Built from scratch — no existing community tree.

## Status
| Feature | A15 Status |
|---------|-----------|
| Boot | ✅ Working |
| Network/Calls | ✅ Working |
| Mobile Data | ✅ Working |
| WiFi | ✅ Working |
| Camera | ✅ Working |
| Fingerprint enrollment | ⚠️ Partial (dim glow) |
| AOD | ⚠️ Minor flicker |
| Widevine L1 | ✅ Working |
| Play Integrity | ✅ Basic+Device |

## Quick Start — Build
```bash
# 1. Setup build environment (after repo sync)
git clone https://github.com/Code-Breaker0/udon_ref ~/udon-crdroid-port
bash ~/udon-crdroid-port/scripts/setup.sh

# 2. One-click build
bash ~/udon-crdroid-port/scripts/build.sh bacon

# 3. One-click flash
bash ~/udon-crdroid-port/scripts/flash_hybrid.sh
```

## Repository Structure
```
udon-crdroid-port/
├── README.md              — This file
├── scripts/
│   ├── setup.sh           — Run after repo sync to apply all patches
│   ├── build.sh           — One-click build
│   ├── flash_hybrid.sh    — One-click hybrid flash
│   ├── apply_patches.sh   — Apply all git patches
│   └── verify.sh          — Verify build environment
├── patches/               — Git diff patches for all modified repos
│   ├── device_udon.patch
│   ├── device_sm8450_common.patch
│   ├── hardware_oplus.patch
│   ├── frameworks_base.patch
│   └── wpa_supplicant.patch
├── docs/
│   ├── BUGS.md            — All known bugs and fixes
│   ├── FLASHING.md        — Detailed flash instructions
│   ├── LESSONS_LEARNED.md — Critical porting insights
│   └── A16_PORTING_GUIDE.md — Guide for Android 16 port
└── manifests/
    └── local_manifests.xml — Reference manifest structure
```

## Build Requirements
- Ubuntu 22.04 or Arch Linux (CachyOS)
- 32GB RAM minimum (64GB recommended)
- 300GB+ disk space
- ALWAYS use: `make bacon -j8` (not mka — causes OOM)
- ALWAYS use: `lunch crdroid_udon-ap3a-userdebug` (not trunk_staging)

## Flash Requirements
- Unlocked bootloader
- ALPHA vendor images at: `~/Downloads/TEST/Payload_Extract_ALPHA/`
- ADB/fastboot tools

## Documentation
- [Bug Tracker](docs/BUGS.md)
- [Flash Guide](docs/FLASHING.md)
- [Lessons Learned](docs/LESSONS_LEARNED.md)
- [A16 Porting Guide](docs/A16_PORTING_GUIDE.md)

## Credits
- crDroid team for the ROM base
- Maitreya/opudon for original device tree reference
- OnePlus for the ALPHA community build
