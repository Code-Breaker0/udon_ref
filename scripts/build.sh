#!/bin/bash
# One-click build script for udon crDroid A15
# Usage: bash build.sh [bacon|system|vendor|odm]

set -e
BUILD_DIR=~/crdroid-build/15.0
TARGET=${1:-bacon}
LOG=~/build_$(date +%Y%m%d_%H%M%S).log

echo "=== udon crDroid A15 Build ==="
echo "Target: $TARGET"
echo "Log: $LOG"
echo ""

# Verify environment first
bash $(dirname "$0")/verify.sh || exit 1

cd $BUILD_DIR
source build/envsetup.sh
lunch crdroid_udon-ap3a-userdebug

echo "Starting build at $(date)..."
make $TARGET -j8 2>&1 | tee $LOG

echo ""
echo "=== Build Complete ==="
ls -lh $BUILD_DIR/out/target/product/udon/*.img 2>/dev/null | grep -v "cache\|userdata\|ramdisk"
grep -c "FAILED\|error:" $LOG && echo "ERRORS FOUND" || echo "Clean build"
