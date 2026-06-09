#!/bin/bash
# Apply all patches to build tree
BUILD_DIR=~/crdroid-build/15.0
PATCHES_DIR=$(dirname "$0")/../patches

apply_patch() {
    local repo=$1
    local patch=$2
    echo "Applying patch to $repo..."
    git -C $BUILD_DIR/$repo apply $PATCHES_DIR/$patch && \
        echo "✓ $patch applied" || \
        echo "✗ $patch failed — may already be applied"
}

apply_patch device/oneplus/udon device_udon.patch
apply_patch device/oneplus/sm8450-common device_sm8450_common.patch
apply_patch hardware/oplus hardware_oplus.patch
apply_patch external/wpa_supplicant_8 wpa_supplicant.patch
apply_patch frameworks/base frameworks_base.patch
