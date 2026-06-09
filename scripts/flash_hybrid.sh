#!/bin/bash
# One-click hybrid flash for udon crDroid A15
# Requires: ALPHA vendor at ~/Downloads/TEST/Payload_Extract_ALPHA/

set -e
BUILD_DIR=~/crdroid-build/15.0/out/target/product/udon
ALPHA_DIR=~/Downloads/TEST/Payload_Extract_ALPHA

# Verify images exist
for img in boot.img vendor_boot.img vbmeta.img vbmeta_system.img system.img system_ext.img product.img odm.img; do
    [ -f "$BUILD_DIR/$img" ] || { echo "MISSING: $BUILD_DIR/$img"; exit 1; }
done
for img in vbmeta_vendor.img vendor.img vendor_dlkm.img; do
    [ -f "$ALPHA_DIR/$img" ] || { echo "MISSING: $ALPHA_DIR/$img"; exit 1; }
done

echo "=== Flashing udon crDroid A15 Hybrid ==="
echo "Built images: $BUILD_DIR"
echo "ALPHA vendor: $ALPHA_DIR"
echo ""
read -p "Continue? (y/N) " confirm
[[ $confirm == [yY] ]] || exit 0

cd $BUILD_DIR

echo "Flashing boot chain..."
fastboot flash boot_a boot.img
fastboot flash boot_b boot.img
fastboot flash vendor_boot_a vendor_boot.img
fastboot flash vendor_boot_b vendor_boot.img
fastboot flash vbmeta_a vbmeta.img
fastboot flash vbmeta_b vbmeta.img
fastboot flash vbmeta_system_a vbmeta_system.img
fastboot flash vbmeta_system_b vbmeta_system.img
fastboot flash vbmeta_vendor_a $ALPHA_DIR/vbmeta_vendor.img
fastboot flash vbmeta_vendor_b $ALPHA_DIR/vbmeta_vendor.img

echo "Rebooting to fastbootd..."
fastboot reboot fastboot
sleep 5

echo "Flashing system partitions..."
fastboot flash system system.img
fastboot flash system_ext system_ext.img
fastboot flash product product.img
fastboot flash odm odm.img

echo "Flashing ALPHA vendor..."
fastboot flash vendor $ALPHA_DIR/vendor.img
fastboot flash vendor_dlkm $ALPHA_DIR/vendor_dlkm.img

echo "Wiping data and rebooting..."
fastboot -w
fastboot reboot

echo ""
echo "=== Flash Complete ==="
echo "1. Complete setup wizard"
echo "2. Flash MindTheGapps A15 arm64 via recovery sideload"
echo "3. Login Google account"
echo "4. Enable crDroid Play Integrity spoof in Settings"
