# OnePlus 11R (`udon`) Build Environment Setup

This document provides the necessary commands and dependencies to set up a clean build environment for Android porting, specifically for `udon`.

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
*   **Payload Dumper Go:** For extracting stock/reference OTA payloads.
    ```bash
    # Install via Go if available
    go install github.com/ssut/payload-dumper-go@latest
    # Move to bin
    mv ~/go/bin/payload-dumper-go ~/bin/
    ```

## 3. Initializing the Source Tree (Example: crDroid 15.0 / Android 15)

```bash
mkdir -p ~/crdroid-build/15.0
cd ~/crdroid-build/15.0
repo init -u https://github.com/crdroidandroid/android.git -b 15.0 --git-lfs
repo sync -c -j$(nproc --all) --force-sync --no-clone-bundle --no-tags
```

## 4. Cloning the `udon` Device Trees

You will need the device, common, vendor, and kernel (prebuilt) trees. 

*(Note: Replace with your specific forks if you have them)*
```bash
# Clone the trees into the expected directories
git clone https://github.com/LineageOS/android_device_oneplus_udon.git -b lineage-22.0 device/oneplus/udon
git clone https://github.com/LineageOS/android_device_oneplus_sm8450-common.git -b lineage-22.0 device/oneplus/sm8450-common
# Vendor and Kernel trees typically come from GitLab or specific dumps
```

## 5. Applying the Bootloop Fixes

Before building, you **must** apply the patches found in this repository (`udon_ref/patches/`) to the source tree. These fix critical AIDL/HIDL mismatches and missing packages that cause bootloops on `udon`.

```bash
cp -r /path/to/udon_ref/patches/* ~/crdroid-build/15.0/
```

## 6. Building the ROM

```bash
cd ~/crdroid-build/15.0
source build/envsetup.sh
lunch crdroid_udon-ap3a-userdebug
export MALLOC_ARENA_MAX=2
mka bacon -j$(nproc)
```
