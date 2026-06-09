#!/bin/bash
# Setup script for udon crDroid A15 build environment
# Run from ~/crdroid-build/15.0 after repo sync

set -e
BUILD_DIR=~/crdroid-build/15.0
SCRIPT_DIR=$(dirname "$0")
PORT_DIR=$(dirname "$SCRIPT_DIR")

echo "=== udon crDroid A15 Build Setup ==="

# Apply all patches
echo "Applying patches..."
bash $PORT_DIR/scripts/apply_patches.sh

# Verify critical files exist
echo "Verifying build environment..."
bash $PORT_DIR/scripts/verify.sh

echo "=== Setup Complete ==="
echo "Build with: source build/envsetup.sh && lunch crdroid_udon-ap3a-userdebug && make bacon -j8"
