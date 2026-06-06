# crDroid 15.0 Build Documentation for OnePlus 11 (udon)

This document provides a comprehensive overview of the crDroid 15.0 (Android 15) build process for the OnePlus 11 (codename: `udon`). It includes environment setup, critical bug fixes, forced image generation, and a precise multi-stage flashing protocol.

## 1. Project Overview
- **Device:** OnePlus 11 (`udon`)
- **Build System:** crDroid 15.0 (Android 15 / SDK 35)
- **Codename:** `ap3a` (Targeting `REL` platform version)
- **Status:** Successful build with verified recovery and module fixes.
- **Root Directory:** `/home/shresth/crdroid-build/15.0/`
- **Primary Output:** `out/target/product/udon/crDroidAndroid-15.0-20260605--v11.17.zip`

---

## 2. Environment & Tools
### Locations
- **Source Root:** `/home/shresth/crdroid-build/15.0/`
- **Device Tree:** `device/oneplus/udon`
- **Common Tree:** `device/oneplus/sm8450-common`
- **Vendor Tree:** `vendor/oneplus/udon`
- **Kernel Prebuilts:** `vendor/oneplus/udon-kernel` (Modules in `vendor_ramdisk/` and `vendor_dlkm/`)
- **Hardware Oplus:** `hardware/oplus`
- **Lineage Sepolicy:** `device/lineage/sepolicy`

### Essential Build Tools
- **repo:** Source management (`/home/shresth/bin/repo`).
- **soong_ui:** Core build engine (`out/soong_ui`).
- **ninja:** Low-level build runner (`prebuilts/build-tools/linux-x86/bin/ninja`).
- **ckati:** Makefile to Ninja converter (`prebuilts/build-tools/linux-x86/bin/ckati`).
- **mkbootimg:** Image generation (`out/host/linux-x86/bin/mkbootimg`).
- **avbtool:** Security signing (`out/host/linux-x86/bin/avbtool`).
- **payload-dumper-go:** Tool to inspect `payload.bin` contents (`/home/shresth/bin/payload-dumper-go`).

### Host Libraries (System)
`bc bison build-essential ccache curl flex g++-multilib gcc-multilib git git-lfs gnupg gperf imagemagick lib32ncurses-dev lib32readline-dev lib32z1-dev liblz4-tool libncurses6 libncurses-dev libsdl1.2-dev libssl-dev libwxgtk3.2-dev libxml2 libxml2-utils lzop pngcrush rsync schedtool squashfs-tools xsltproc zip zlib1g-dev`

---

## 3. Critical Fixes & Bug Debugging

### A. Kernel Panic (Bootloop) - STORAGE MOUNT & MODULE ORDER FAILURE
- **Symptom:** immediate reboot to "Orange State" warning or hang at boot logo.
- **Cause:** Missing UFS/Storage modules in `vendor_boot` or incorrect alphabetical loading order.
- **Fix Location:** `device/oneplus/udon/BoardConfig.mk`.
- **Logic:** 
    - Forced `BOARD_VENDOR_RAMDISK_KERNEL_MODULES_LOAD` to use prebuilt `modules.load`.
    - Created `vendor/oneplus/udon-kernel/vendor_ramdisk/modules.blocklist` to match working reference.
    - Explicitly set `BOARD_VENDOR_RAMDISK_RECOVERY_KERNEL_MODULES_LOAD := $(shell cat $(KERNEL_PREBUILT_DIR)/vendor_ramdisk/modules.load.recovery)`.

### B. Recovery Partition - NO RECOVERY BOOT / FASTBOOT REBOOT
- **Symptom:** `fastboot reboot recovery` boots back to fastboot.
- **Cause:** Kernel inclusion in recovery partition (OnePlus 11 expects ramdisk only).
- **Fix Location:** `device/oneplus/udon/BoardConfig.mk`.
- **Logic:** 
    - Set `BOARD_EXCLUDE_KERNEL_FROM_RECOVERY_IMAGE := true`.
    - Confirmed `TARGET_NO_RECOVERY := false` to maintain physical partition support.

### C. SEPolicy Collisions - BUILD FAILURE
- **Symptom:** "Duplicate file_contexts" or "Duplicate property" errors.
- **Fix Locations:**
  - `hardware/oplus/sepolicy/qti/vendor/file_contexts` (NFC duplicates).
  - `device/lineage/sepolicy/common/public/property.te` (Camera persist property duplicates).

### D. Android 15 Source Compatibility
- **Symptom:** `PowerManager.wakeUp()` compilation error.
- **Fix Location:** `hardware/oplus/doze/src/org/lineageos/settings/doze/PickupSensor.kt`.
- **Logic:** Add `Display.DEFAULT_DISPLAY` as the 4th parameter.

### E. ROM Comparison Insights
Comparing our build to the working "ALPHA" build (`crDroidAndroid-15.0-20241029-udon-v11.0-ALPHA.zip`):
- **Payload Structure:** Both use `payload.bin`.
- **Firmware:** The Alpha build is a "Full" package containing all device firmware (abl, aop, bluetooth, modem, xbl, etc.). Our build is "Core" (Android partitions only).
- **Recovery:** The Alpha build includes a dedicated `recovery` partition in the payload.
- **Build Type:** Our build is `userdebug` (~1.8GB), while the Alpha is likely `user` (~700MB compressed), explaining the size difference.

---

## 4. Build Instructions
To reproduce the full build with recovery:
```bash
cd /home/shresth/crdroid-build/15.0/
source build/envsetup.sh
lunch crdroid_udon-ap3a-userdebug
export MALLOC_ARENA_MAX=2
mka recoveryimage bacon -j16
```

---

## 5. Comprehensive Flashing Protocol (OnePlus 11)
Due to the mix of physical and logical partitions, and strict AVB security, flashing must be done in a specific sequence. **Always use `bash -c` to wrap commands** to prevent shell-parsing errors with security flags.

### Stage 1: Physical Partitions & Security (Standard Fastboot)
Run these commands from the bootloader. The AVB flags are **CRITICAL**; without them, the bootloader will reject custom images.

```bash
cd /home/shresth/crdroid-build/15.0/out/target/product/udon

# Disable AVB Verification properly
bash -c 'fastboot flash vbmeta vbmeta.img --disable-verity --disable-verification'
bash -c 'fastboot flash vbmeta_system vbmeta_system.img --disable-verity --disable-verification'
bash -c 'fastboot flash vbmeta_vendor vbmeta_vendor.img --disable-verity --disable-verification'

# Flash core boot and recovery
bash -c 'fastboot flash recovery recovery.img'
bash -c 'fastboot flash boot boot.img'
bash -c 'fastboot flash vendor_boot vendor_boot.img'
bash -c 'fastboot flash dtbo dtbo.img'
```

### Stage 2: Recovery & Sideload
Reboot to the recovery you just flashed. The logical partitions (like `vendor_dlkm` and `system`) are handled automatically by the sideload process.

```bash
fastboot reboot recovery
# In crDroid Recovery: select "Apply Update" -> "Apply from ADB"
adb sideload crDroidAndroid-15.0-20260605--v11.17.zip
```
**Important:** If coming from stock, you **must** select **Factory Reset / Format Data** in recovery before booting the system.

---

## 6. Technical Corrections
- **`vendor_ramdisk`:** This is NOT a partition. It is a build component. Never attempt to flash it.
- **`vendor_dlkm`:** This is a logical partition. While it exists, it is bundled in the OTA zip and flashed during sideload. Manual flashing is redundant and requires fastbootd.
- **AVB Flags:** `--disable-verification` must be applied alongside `--disable-verity`. Using only one will result in a bootloop.

---

## 6. Known Artifacts
| Image | Location | Description |
| :--- | :--- | :--- |
| `recovery.img` | `out/target/product/udon/` | Standalone recovery (100MB) |
| `boot.img` | `out/target/product/udon/` | Kernel + Generic ramdisk |
| `vendor_boot.img` | `out/target/product/udon/` | Vendor ramdisk with ~350 modules |
| `vendor_dlkm.img` | `out/target/product/udon/` | Logical partition for DLKM modules |
| `vendor_ramdisk.img` | `out/target/product/udon/` | Logical vendor ramdisk |

---
*Generated by Gemini CLI Agent - 2026-06-05*
