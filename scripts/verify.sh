#!/bin/bash
# Verify critical build requirements
BUILD_DIR=~/crdroid-build/15.0
ERRORS=0

check() {
    local desc=$1
    local path=$2
    if [ -e "$BUILD_DIR/$path" ]; then
        echo "✓ $desc"
    else
        echo "✗ MISSING: $desc ($path)"
        ERRORS=$((ERRORS+1))
    fi
}

check "Prebuilt kernel Image" "vendor/oneplus/udon-kernel/Image"
check "Prebuilt DTB" "vendor/oneplus/udon-kernel/dtb.img"
check "udon device tree" "device/oneplus/udon/BoardConfig.mk"
check "sm8450-common tree" "device/oneplus/sm8450-common/BoardConfigCommon.mk"
check "Zygote redirect RC" "device/oneplus/udon/init.zygote64_32.rc"
check "SELinux vendor_init fix" "device/oneplus/udon/sepolicy/vendor/vendor_init.te"
check "UDFPS ueventd rules" "device/oneplus/udon/ueventd.rc"
check "hardware/oplus" "hardware/oplus/hidl/fingerprint/BiometricsFingerprint.h"
check "wpa_supplicant fix" "external/wpa_supplicant_8/src/drivers/driver_nl80211_event.c"

if [ $ERRORS -gt 0 ]; then
    echo ""
    echo "✗ $ERRORS missing files. Run repo sync and try again."
    exit 1
else
    echo ""
    echo "✓ All checks passed. Ready to build."
fi
