# udon_ref: The Ultimate OnePlus 11R (`udon`) Porting Reference

Welcome to the `udon_ref` repository. This project is the central source of truth for porting custom ROMs (specifically Android 15/16) to the **OnePlus 11R (`udon`)** smoothly, without encountering the infamous "Orange State" bootloops, recovery failures, or system hangups.

This repository serves as a base reference derived from extensive blind porting logic and empirical testing against a working ALPHA build.

---

## 📂 Repository Structure

*   **`docs/`**: Contains the critical reference documents.
    *   `A16_BLIND_PORTING.md`: Essential logic, module loading heuristics, and VINTF alignment rules for Android 16. **(Must Read)**
    *   `GEMINI.md`: Flashing instructions, AVB security flags, and specific `udon` quirks.
*   **`setup/`**: Contains environment setup guides.
    *   `environment_setup.md`: Commands to download dependencies, initialize the repo, and seamlessly inject the bundled sources.
*   **`source/`**: The complete, "zero-config" source trees (`device`, `vendor`, `kernel`). These contain all the proprietary blobs, prebuilt kernels, and the following critical patches:
    *   **VINTF Matrices:** Updated `manifest_dsds.xml` and `device_framework_matrix.xml` to force **AIDL** for Oplus Radio, IMS, and AppRadio (resolving `odm` bootloops).
    *   **Init Scripts:** Synced `init.oplus.rc` (HBM node overrides) and `init.oplus.sh` (Multisim detection).
    *   **Makefiles (`common.mk`, `crdroid_udon.mk`, `device.mk`):** Enforces `oplus` as the manufacturer/brand and includes missing critical updater packages (`update_engine`, `update_verifier`, `nfc-service-nxp`).
    *   **BoardConfig (`BoardConfig.mk`):** Contains the critical `BOARD_EXCLUDE_KERNEL_FROM_RECOVERY_IMAGE := true` flag and kernel prebuilt logic.
    *   **Kernel Blocklists (`modules.blocklist`):** Prevents kernel panics during boot by blacklisting conflicting A15 modules.

---

## 🚀 How to Use This Repository

If you are porting a new ROM or updating to Android 16:

1.  **Read the Docs:** Familiarize yourself with `docs/A16_BLIND_PORTING.md`. Understanding *why* we bypass kernel compilation in favor of prebuilts and how AVB is handled on this device is critical.
2.  **Set Up Environment:** Follow `setup/environment_setup.md` to initialize your build tree.
3.  **Inject Source Trees:** Because this repository contains the fully-patched source trees, you do **not** need to manually clone from external sources or apply patches. Simply copy the `source/` folder into your initialized ROM tree:
    ```bash
    cp -r source/* /path/to/your/android/source/
    ```
4.  **Build and Flash:** Follow the flashing protocol in `docs/GEMINI.md` to properly neutralize verification before sideloading.

---

## 🛠️ The "Bootloop Free" Guarantee

The bundled sources included here address the most common reasons a build fails to boot on `udon`:
*   **Kernel Panic:** Handled by strictly enforcing prebuilt kernel modules via `modules.blocklist`.
*   **VINTF Mismatch:** Handled by aligning `device_framework_matrix.xml` to accept AIDL HALs expected by Oplus proprietary blobs.
*   **Brand Mismatch:** Handled by forcing `ro.product.brand=oplus`, preventing silent crashes in camera/fingerprint HALs.
*   **Recovery Loops:** Handled by setting `BOARD_EXCLUDE_KERNEL_FROM_RECOVERY_IMAGE := true`.

---

## References & Acknowledgments

This porting baseline would not be possible without the incredible open-source community:
*   **crDroid Android:** Base ROM framework and build system.
*   **LineageOS Project:** Initial device tree (`sm8450-common` and `udon`) structure and hardware abstraction layers.
*   **payload-dumper-go:** Used for extracting firmware and proprietary blobs from OxygenOS payload.bin files.
*   **Qualcomm & Oplus:** Proprietary blobs and kernel bases.
