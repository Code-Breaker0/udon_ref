# Critical Boot Dependencies & Missing Flags

When cloning the standard, open-source device trees (such as those from LineageOS) for the OnePlus 11R (`udon`), several critical flags, packages, and hardware definitions are either missing, incomplete, or outdated. 

This document serves as an exhaustive list of exactly what we had to manually inject or modify compared to the stock trees to achieve a bootloop-free environment. These are the exact changes bundled into the `source/` folder of this repository.

## 1. Missing Core Packages (`common.mk`)
Generic device trees often assume the build system (like AOSP or crDroid) will automatically pull in updater or system-level services. For `udon`, this fails silently, leading to missing binaries in `system` and `system_ext`. We explicitly added:
*   `update_engine` & `update_engine_client` (Critical for A/B OTA devices)
*   `update_verifier` (Without this, the system may roll back assuming a failed boot)
*   `vndservicemanager` (Crucial for vendor-to-system service communication)
*   `vendor.lineage.touch@1.0-service.oplus` (Required to initialize the touchscreen daemon)
*   `nfc-service-nxp` (The standard `android.hardware.nfc_snxxx` causes crashes; `udon` requires the NXP variant).

## 2. VINTF Framework Mismatches
The most severe cause of `odm` partition bootloops was a mismatch between what the Android framework expected and what the proprietary Oplus blobs provided. 
*   **The Issue:** The standard trees declared Oplus Radio, IMS, and AppRadio using legacy **HIDL** interfaces (`@1.0::IOplusRadio`). However, modern Android 14/15 proprietary blobs require **AIDL**.
*   **The Fix:** We rewrote both `manifest_dsds.xml` and `device_framework_matrix.xml` to strictly enforce **AIDL** definitions:
    *   `vendor.oplus.hardware.appradioaidl`
    *   `vendor.oplus.hardware.ims`
    *   `vendor.oplus.hardware.radio`

## 3. Brand & Manufacturer Spoofing
Many proprietary Oplus blobs (specifically Camera and Fingerprint HALs) have hardcoded checks for the system brand.
*   **The Issue:** Using `PRODUCT_BRAND := OnePlus` causes silent segmentation faults in `system_ext` extensions.
*   **The Fix:** We forced `PRODUCT_MANUFACTURER := oplus` and `PRODUCT_BRAND := oplus` in `crdroid_udon.mk`.

## 4. Recovery & Kernel Flags (`BoardConfig.mk`)
Due to the physical partition layout of the device, standard GKI recovery generation fails.
*   **The Fix:** We injected `BOARD_EXCLUDE_KERNEL_FROM_RECOVERY_IMAGE := true`.
*   **The Fix:** We forced `TARGET_FORCE_PREBUILT_KERNEL := true` to prevent the build system from compiling a kernel from source, which bypasses signing/panic issues on initial bring-up.

## 5. Early Boot Init Script Fixes
*   **HBM Node Crash:** The High Brightness Mode (HBM) node in the kernel can crash `surfaceflinger` if accessed improperly during early boot. We injected `chmod 0000 /sys/kernel/oplus_display/hbm` into `init.oplus.rc` to lock it down.
*   **Multisim Detection:** The standard `rf_version` checks were unreliable for enabling Dual SIM (DSDS). We replaced them in `init.oplus.sh` with a direct boot cmdline check: `if grep -q simcardnum.simcardnum=1 /proc/cmdline; then`.

## Conclusion
All of these fixes are pre-applied in the `source/` folder of this repository. When porting to Android 16, **ensure none of these flags or packages are dropped** if you re-sync with upstream LineageOS trees.
