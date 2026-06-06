# OnePlus 11R (`udon`) Build Environment Setup

This document provides the necessary commands and dependencies to set up a clean, zero-configuration build environment for Android porting on the OnePlus 11R (`udon`).

## 1. System Dependencies (Ubuntu/Debian)

Run the following command to install all required packages for building Android (AOSP/crDroid/LineageOS):

```bash
sudo apt-get update
sudo apt-get install -y bc bison build-essential ccache curl flex g++-multilib gcc-multilib git git-lfs gnupg gperf imagemagick lib32ncurses-dev lib32readline-dev lib32z1-dev liblz4-tool libncurses6 libncurses-dev libsdl1.2-dev libssl-dev libwxgtk3.2-dev libxml2 libxml2-utils lzop pngcrush rsync schedtool squashfs-tools xsltproc zip zlib1g-dev
```

## 2. Essential Host Tools

Ensure you have the following tools installed and accessible in your `$PATH` (e.g., `~/bin`):

*   **Repo:** Source tree management
    ```bash
    mkdir -p ~/bin
    curl https://storage.googleapis.com/git-repo-downloads/repo > ~/bin/repo
    chmod a+x ~/bin/repo
    export PATH=~/bin:$PATH
    ```
*   **Payload Dumper Go:** For extracting stock/reference OTA payloads (useful for future porting).
    ```bash
    go install github.com/ssut/payload-dumper-go@latest
    mv ~/go/bin/payload-dumper-go ~/bin/
    ```

## 3. Initializing the Core Source Tree (Example: crDroid 15.0 / Android 15)

First, initialize the generic ROM source tree.

```bash
mkdir -p ~/crdroid-build/15.0
cd ~/crdroid-build/15.0
repo init -u https://github.com/crdroidandroid/android.git -b 15.0 --git-lfs
repo sync -c -j$(nproc --all) --force-sync --no-clone-bundle --no-tags
```

## 4. Injecting the Fully Patched `udon` Source Trees

This `udon_ref` repository already contains the **complete, fully-patched device, vendor, and kernel source trees**. You do not need to clone from LineageOS and apply manual patches. 

Simply copy the `source/` folder from this repository directly into your build environment. This guarantees you are using the VINTF-aligned, bootloop-free baseline.

```bash
# Assuming you cloned udon_ref to ~/udon_ref
cd ~/crdroid-build/15.0
cp -r ~/udon_ref/source/* ./
```
*Note: The bundled trees use a prebuilt kernel to bypass module signing panics on Android 15/16 ports.*

## 5. Building the ROM

Once the sources are merged, you are ready to build.

```bash
cd ~/crdroid-build/15.0
source build/envsetup.sh
lunch crdroid_udon-ap3a-userdebug

# Optimize memory usage during heavy linking phases
export MALLOC_ARENA_MAX=2

# Start the build (adjust -j to your CPU threads)
mka bacon -j$(nproc)
```

---

## References & Acknowledgments

This porting baseline would not be possible without the incredible open-source community.
*   **crDroid Android:** Base ROM framework and build system. ([GitHub](https://github.com/crdroidandroid))
*   **LineageOS Project:** Initial device tree (`sm8450-common` and `udon`) structure and hardware abstraction layers. ([GitHub](https://github.com/LineageOS))
*   **payload-dumper-go:** By *ssut*, used extensively for extracting firmware and proprietary blobs from OxygenOS payload.bin files. ([GitHub](https://github.com/ssut/payload-dumper-go))
*   **Qualcomm & Oplus:** Proprietary blobs and kernel bases.
