# OnePlus 11R (udon) crDroid A15 Port

Pioneer Android 15 port for OnePlus 11R (SM8450/taro).
No existing community tree — built from scratch.

## Device Info
- Codename: udon
- SoC: Snapdragon 8+ Gen 1 (SM8450/taro)
- RAM: 8GB/16GB
- Android: crDroid 15.0 (Android 15)

## Quick Start
```bash
# 1. Install repo tool
mkdir -p ~/.bin
curl https://storage.googleapis.com/git-repo-downloads/repo > ~/.bin/repo
chmod a+x ~/.bin/repo

# 2. Initialize build environment
mkdir -p ~/crdroid-build/15.0
cd ~/crdroid-build/15.0
repo init -u https://github.com/crdroidandroid/android.git -b 15.0 --git-lfs

# 3. Clone this repo and run setup script
git clone https://github.com/Code-Breaker0/udon_ref.git ~/udon-crdroid-port
bash ~/udon-crdroid-port/scripts/setup.sh

# 4. Build
source build/envsetup.sh
lunch crdroid_udon-ap3a-userdebug
make bacon -j8 2>&1 | tee ~/build.log
```

## Flash Instructions
See docs/FLASHING.md

## Known Issues & Fixes
See docs/BUGS.md

## Porting Lessons Learned
See docs/LESSONS_LEARNED.md
