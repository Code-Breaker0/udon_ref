# Android 16 Porting Guide — OnePlus 11R (udon)

## Overview
A16 port builds on all A15 work. Estimated time: 2-3 days vs weeks for A15.
All major blockers are documented and solved.

## Step 1 — Initialize A16 Build Environment
```bash
mkdir -p ~/crdroid-build/16.0
cd ~/crdroid-build/16.0
repo init -u https://github.com/crdroidandroid/android.git -b 16.0 --git-lfs
repo sync -c --no-clone-bundle --no-tags --optimized-fetch --prune -j8
```

## Step 2 — Apply All Patches
```bash
git clone https://github.com/Code-Breaker0/udon_ref ~/udon-crdroid-port
# Update BUILD_DIR in scripts to ~/crdroid-build/16.0
sed -i 's|crdroid-build/15.0|crdroid-build/16.0|g' ~/udon-crdroid-port/scripts/*.sh
bash ~/udon-crdroid-port/scripts/apply_patches.sh
```

## Step 3 — A16-Specific Changes Required

### 3.1 Lunch Target
A16 uses a different release config. Check available targets:
```bash
source build/envsetup.sh
grep -r "crdroid_udon" device/oneplus/udon/AndroidProducts.mk
```
Use the A16 equivalent of `ap3a` — likely `ap4a` or `baklava`.
NEVER use `trunk_staging`.

### 3.2 HIDL → AIDL Migration
A16 may deprecate HIDL 1.6 radio. Check:
```bash
grep -r "radio@1.6\|IRadio" vendor/oneplus/ device/oneplus/ 2>/dev/null
```
If AIDL radio is required, implement thin AIDL wrapper over HIDL 1.6.

### 3.3 Zygote — Same Fix Applies
Keep in `crdroid_udon.mk`:
```makefile
$(call inherit-product, $(SRC_TARGET_DIR)/product/core_64_bit.mk)
PRODUCT_SYSTEM_PROPERTIES += ro.zygote=zygote64
PRODUCT_PRODUCT_PROPERTIES += ro.zygote=zygote64
```
Keep `init.zygote64_32.rc` redirect in device tree.

### 3.4 ConnectivityManager Patch
Carry over the CneApp crash fix — legacy vendor APKs still use old API.
File: `frameworks/opt/telephony/...ConnectivityManager.java`

### 3.5 Dynamic Partition Size
Keep: `BOARD_ONEPLUS_DYNAMIC_PARTITIONS_SIZE := 14000000000`

### 3.6 Blob Healing
Run healing script pointing at A15 ALPHA images:
```bash
python3 /home/shresth/heal_proprietary_files.py \
  --target ~/crdroid-build/16.0 \
  --source ~/Downloads/TEST/Payload_Extract_ALPHA
```

### 3.7 Build Command
```bash
cd ~/crdroid-build/16.0
source build/envsetup.sh
lunch crdroid_udon-ap4a-userdebug  # or equivalent A16 target
make bacon -j8 2>&1 | tee ~/build_a16.log
```

## Step 4 — Known A16 Risk Areas

| Area | Risk | Mitigation |
|------|------|------------|
| HIDL radio deprecation | HIGH | AIDL wrapper or keep HIDL if still supported |
| Kernel GKI version | MEDIUM | Check if udon-kernel prebuilts are A16 compatible |
| APEX changes | MEDIUM | ADB may move to different APEX in A16 |
| Vendor interface level | MEDIUM | Update target-level in manifest_taro.xml |
| Dolby A16 compat | LOW | Same 64-bit only fix applies |

## Step 5 — First Boot Checklist
Same as A15 — in order:
1. Orange state passes ✓
2. Bootanimation appears ✓
3. ADB connects ✓
4. Setup wizard ✓
5. Network IN_SERVICE ✓
6. Camera works ✓

## Reference
- A15 patches: ~/udon-crdroid-port/patches/
- Lessons learned: ~/udon-crdroid-port/docs/LESSONS_LEARNED.md
- Build scripts: ~/udon-crdroid-port/scripts/
