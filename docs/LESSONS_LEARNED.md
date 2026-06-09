# OnePlus 11R (udon) ROM Porting Handbook — Lessons Learned

This document records the critical build resolutions and architecture constraints discovered during the A15 udon crDroid port. These are essential reference points for the upcoming **Android 16 (A16) development**.

---

## 1. Proprietary Blob Healing
* **The Problem**: Prebuilt proprietary HALs are often missing from source control, or sync scripts are incomplete. This results in Ninja build errors where copy rules cannot find their sources (e.g., `dax-default.xml` or `virtual_audio_policy_configuration.xml`).
* **The Solution**: We created a self-healing Python script `/home/shresth/heal_proprietary_files.py` that parses the build configurations (`udon-vendor.mk` and `crdroid_udon.mk`), identifies missing proprietary source paths, and extracts them directly from the ALPHA partition images (`odm.img`, `vendor.img`, etc.) using `debugfs` loop-free extraction.
* **A16 Action**: When bringing up the A16 tree, run the same healing script pointing to the A16 target makefiles and the ALPHA images.

---

## 2. Symlinks vs. Host Build Constraints
* **The Problem**: In GKI ROMs, remote filesystem (rfs) and WLAN services require target-side symbolic links (e.g. `/vendor/rfs/msm/...` pointing to `/mnt/vendor/...`). If these symlinks are checked into the source tree or copied using `PRODUCT_COPY_FILES`, the host OS build tool (Go/Soong) will attempt to follow them. Because the target path (e.g. `/vendor/firmware`) does not exist on the host build machine, Go's `os.Stat` throws a `does not exist` error, breaking the Soong bootstrap phase.
* **The Solution**:
  1. Remove all physical symlinks from the source folders (like `improved_blobs/`).
  2. Do **not** copy symlinks via `PRODUCT_COPY_FILES`.
  3. Instead, define them as `install_symlink` modules in `Android.bp`:
     ```bp
     install_symlink {
         name: "symlink_rfs_msm_adsp_hlos",
         vendor: true,
         symlink_target: "/mnt/vendor/persist/hlos_rfs/shared",
         installed_location: "rfs/msm/adsp/hlos",
     }
     ```
  4. Add these module names (e.g. `symlink_rfs_msm_adsp_hlos`) to `PRODUCT_PACKAGES`.
* **A16 Action**: Keep all target-side symlinks out of the physical git folders. Define them cleanly in `device/oneplus/udon/Android.bp` using `install_symlink`.

---

## 3. 64-Bit-Only Packaging Conflicts
* **The Problem**: OnePlus 11R is a 64-bit-only target (`TARGET_SUPPORTS_64_BIT_APPS_ONLY := true`). Because there is no 32-bit runtime directory, Soong maps all copies destined for `$(TARGET_COPY_OUT_VENDOR)/lib/...` directly to `$(TARGET_COPY_OUT_VENDOR)/lib64/...`. If the same library is copied from both a `lib` and a `lib64` source folder (like Dolby soundfx libraries), Soong flags a **packaging conflict** and halts the build.
* **The Solution**:
  1. Promote all unique vendor libraries to 64-bit (copy from `/lib64/` in the source image to `$(TARGET_COPY_OUT_VENDOR)/lib64/`).
  2. Remove 32-bit versions from `PRODUCT_COPY_FILES` entirely.
  3. Delete duplicate copies that are already handled by common trees (e.g. `libeffectproxy.so`).
* **A16 Action**: Audit `PRODUCT_COPY_FILES` in A16. Ensure no 32-bit library copies target `$(TARGET_COPY_OUT_VENDOR)/lib/...` if a 64-bit library version also exists.

---

## 4. HBM & Screen Flashing (UDFPS / AOD)
* **The Problem**: Under-display fingerprint sensor (UDFPS) use and Ambient Display (AOD) lighting can cause full-screen flashes or surfaceflinger crashes when the kernel high-brightness-mode (HBM) nodes are improperly accessed during early boot.
* **The Solution**: We injected `chmod 0000 /sys/kernel/oplus_display/hbm` into [init.oplus.rc](file:///home/shresth/crdroid-build/15.0/device/oneplus/sm8450-common/init/init.oplus.rc#L45-L48) to lock down the early boot permissions of the HBM node, preventing surfaceflinger from silently crashing.
* **A16 Action**: Carry over this early boot lockdown permission and ensure the `init.oplus.rc` init sequence matches.

---

## 5. Zygote Boot Loop & Zygote64_32 Config Mismatch
* **The Problem**: Zygote fails to start entirely, causing a boot loop at the Android boot animation. System logs show services repeatedly waiting for binder interfaces like `aidl/activity` with:
  ```
  init: Control message: Could not find 'aidl/activity' for ctl.interface_start
  ```
  This is caused by `ro.zygote` resolving to `zygote64_32` on the device, which makes the init system look for the `/system/etc/init/hw/init.zygote64_32.rc` config file. If this file is missing, the init system never starts Zygote.
* **The Solution**: In `crdroid_udon.mk`, change:
  ```make
  $(call inherit-product, $(SRC_TARGET_DIR)/product/core_64_bit_only.mk)
  ```
  to:
  ```make
  $(call inherit-product, $(SRC_TARGET_DIR)/product/core_64_bit.mk)
  ```
  This packages the hybrid `init.zygote64_32.rc` and `init.zygote32.rc` configuration files into the system image, allowing the hybrid zygote setup to start properly.
* **A16 Action**: Verify `ro.zygote` requirements of the target SoC. Inherit `core_64_bit.mk` if the SoC or vendor expectations require a hybrid 64/32-bit zygote setup, rather than forcing `core_64_bit_only.mk`.

---

## 6. Dolby Integration & 64-Bit-Only Multi-Arch Conflicts
* **The Problem**: Dolby packages (`DaxUI` and `daxService`) require specific prebuilt proprietary libraries (like `libstagefright_foundation-v33.so` and soundfx libraries). In 64-bit-only targets, the build system maps all `/lib/` copies to `/lib64/`, causing Soong packaging conflicts if both 32-bit and 64-bit rules exist. Furthermore, conflicting copies of `libeffectproxy.so` between the Dolby tree and common vendor tree halt the build.
* **The Solution**: 
  1. We inherited `hardware/dolby/dolby.mk` in `device/oneplus/udon/device.mk` to build the `DaxUI` and `daxService` apps and start the DMS HAL.
  2. We commented out the duplicate Dolby configs and library copy rules in `improvements.mk` and `crdroid_udon.mk`.
  3. We wrapped the 32-bit library copy rules in `hardware/dolby/dolby.mk` with a product check: `ifneq ($(filter %udon,$(TARGET_PRODUCT)),)` to only copy 64-bit components for `udon`, and omitted the duplicate `libeffectproxy.so` copy.
* **A16 Action**: In A16, inherit `hardware/dolby/dolby.mk` but verify that no duplicate copies exist in device makefiles, and ensure that 32-bit VNDK or soundfx libraries are excluded for 64-bit-only builds.

---

## 7. Fingerprint HBM & Always-On Display (AOD) Flickering
* **The Problem**: 
  1. Setting `chmod 0000 /sys/kernel/oplus_display/hbm` in early boot prevents SurfaceFlinger from crashing, but blocks the fingerprint sensor (FOD/UDFPS) from triggering High Brightness Mode (HBM), causing registration and scanning failures.
  2. Noise or rapid lux shifts on the Ambient Light Sensor (ALS) during AOD/Doze mode causes the screen to fluctuate rapidly between brightness states (flickering).
* **The Solution**:
  1. We reverted the `chmod 0000` HBM lockdown in `init.oplus.rc` and set `/sys/kernel/oplus_display/hbm` and `/sys/kernel/oplus_display/dimlayer_hbm` to system ownership with `chmod 0660` permissions. This allows the fingerprint service to control HBM.
  2. We disabled auto-brightness specifically during doze by setting `<bool name="config_allowAutoBrightnessWhileDozing">false</bool>` in `device/oneplus/udon/overlay/OPlusFrameworksResTarget/res/values/config.xml`. This locks AOD to a stable static brightness value.
* **A16 Action**: Carry over the `0660` display node permissions and set `config_allowAutoBrightnessWhileDozing` to `false` in the A16 target overlay configuration.

---

## 8. Mainline Connectivity Crash (CneApp Compatibility)
* **The Problem**: Prebuilt vendor APks like `CneApp.apk` (com.qualcomm.qti.cne) crash repeatedly on Android 15 with `java.lang.IllegalArgumentException: NetworkCallback was not registered`. Android 15's `ConnectivityManager.java` enforces strict registration checks and throws an exception on unregistering unregistered callbacks, whereas legacy platforms handled it silently. This crash loop brings down the telephony data stack, preventing SIM network registration.
* **The Solution**: We modified the framework mainline connectivity module in [ConnectivityManager.java](file:///home/shresth/crdroid-build/15.0/packages/modules/Connectivity/framework/src/android/net/ConnectivityManager.java#L5483-L5488) to log a warning (`Log.w`) and return early instead of throwing `IllegalArgumentException`.
* **A16 Action**: Mainline modules migrate from HIDL to AIDL in A16. Carry over the `ConnectivityManager` patch to prevent un-migrated or legacy vendor APKs from crashing the system services.

---

## 9. VINTF Conflict for ODM Fingerprint HAL Relocation
* **The Problem**: When moving a custom fingerprint HAL from `/vendor` to `/odm` partition (setting `device_specific: true` in `Android.bp`), specifying `vintf_fragments` installs a duplicate XML manifest fragment at `/odm/etc/vintf/manifest/android.hardware.biometrics.fingerprint@2.3-service.oplus.xml`. This conflicts with the pre-existing `/odm/etc/vintf/manifest/manifest_oplus_fingerprint.xml`, failing VINTF validation checks at the end of the build.
* **The Solution**: We removed `vintf_fragments` from the binary rule in [Android.bp](file:///home/shresth/crdroid-build/15.0/hardware/oplus/hidl/fingerprint/Android.bp#L1-L6) because the interface declaration already exists in the device's main manifest list.
* **A16 Action**: When registering ODM services, ensure VINTF declarations are not duplicated between individual component rc/xml rules and the device/ODM target manifest files.


