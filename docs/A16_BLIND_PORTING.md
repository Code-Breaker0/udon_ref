# Android 16 (A16) Blind Porting Strategy for `udon`

This document serves as the internal technical memory for the Gemini CLI agent when porting to Android 16 without a working comparison image.

## 1. The "Zero-Reference" Module Logic
When moving to A16, the kernel modules will likely change. To avoid bootloops without a working `vendor_boot.img`:
- **Source of Truth:** Trust the `modules.load` and `modules.load.recovery` found in the **new kernel prebuilt directory**.
- **The Blocklist Heuristic:** Carry over the A15 `modules.blocklist`. Most conflicting drivers (like `8250_of` or `llcc_perfmon`) are platform-level conflicts, not Android-version specific.
- **Dependency Loading:** If the build system fails to generate `modules.dep`, manually trigger `depmod` using the host tools in `out/host/linux-x86/bin/depmod`.

## 2. Recovery Partition Integrity
For A16, Google may further push GKI standards, but the physical layout of the OnePlus 11R won't change.
- **Enforcement:** Always keep `BOARD_EXCLUDE_KERNEL_FROM_RECOVERY_IMAGE := true`. 
- **Symptoms of Failure:** If A16 recovery boots to a black screen, it's likely a missing display module in `modules.load.recovery`.
- **Mandatory Modules for `udon`:** Ensure `oplus_bsp_tp_custom.ko` (Touch) and `ufshcd-crypto-qti.ko` (Storage) are prioritized in the load list.

## 3. SEPolicy Evolution
Android 16 will likely introduce new `neverallow` rules and partition contexts.
- **Strategy:** Start with `BOARD_VENDOR_SEPOLICY_DIRS` pointing only to the core device tree. 
- **Debugging:** If `init` fails to start services, check `dmesg` via recovery for "denied" messages. Do not use `permissive` as a permanent fix; identify the missing context in `file_contexts`.

## 4. Partitions & AVB
- **Logic:** A16 might resize logical partitions. 
- **Action:** If "Insufficient space" occurs during build, check `BOARD_ONEPLUS_DYNAMIC_PARTITIONS_SIZE` in `BoardConfigCommon.mk` and compare with the physical `super` partition size from a `fastboot getvar all` dump.

## 5. VINTF & HAL Compatibility
- **AIDL vs HIDL:** As of A15, Oplus Radio HALs (`appradioaidl`, `ims`, `radio`) have transitioned to AIDL. For A16, verify if HIDL is fully deprecated for these services. 
- **Consistency Check:** If the `odm` partition fails to boot, compare the generated `manifest.xml` against the expected symbols in proprietary blobs. Use `grep -r` on blobs to confirm if they expect HIDL (`@1.0::IOplusRadio`) or AIDL (`IRadioStable`).
- **Brand Identity:** Proprietary blobs (especially camera and NFC) may have hardcoded checks for `ro.product.brand=oplus` and `ro.product.manufacturer=oplus`. If `OnePlus` is used, these HALs may silently fail or crash.

## 6. Critical Package Manifest
Never assume the core build system includes all required updater services. Ensure these are explicitly in `PRODUCT_PACKAGES`:
- `update_engine` & `update_engine_client`
- `update_verifier`
- `nfc-service-nxp` (Verified for `udon`)
- `vendor.lineage.touch@1.0-service.oplus` (Required for display/touch sync)
- `vndservicemanager`

## 7. Init Script Synchronization
- **HBM Node:** Always ensure `chmod 0000 /sys/kernel/oplus_display/hbm` is present in `init.oplus.rc` to prevent display-related crashes during early boot.
- **Multisim Detection:** Use `if grep -q simcardnum.simcardnum=1 /proc/cmdline; then` for DSDS configuration on `udon` instead of `rf_version` checks, as it is the most reliable hardware trigger.

## 8. Summary of "Udon" Specifics to Maintain
- `TARGET_NO_RECOVERY := false`
- `BOARD_MOVE_RECOVERY_RESOURCES_TO_VENDOR_BOOT := false`
- `BOARD_USES_GENERIC_KERNEL_IMAGE := true`
- `BOARD_BOOT_HEADER_VERSION := 4`
- `PRODUCT_MANUFACTURER := oplus`
- `PRODUCT_BRAND := oplus`

## 9. Future-Proofing Strategy
- **Baseline:** Always use the last working A15 build tree as the structural baseline.
- **Incrementalism:** When porting to A16, apply device-tree changes one at a time. If a bootloop occurs, revert to the "Known Good" state (A15 logic) for that specific component.
