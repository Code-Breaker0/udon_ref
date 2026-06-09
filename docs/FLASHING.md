# Flashing Guide — OnePlus 11R crDroid A15
| Partition | Source |
|-----------|--------|
| boot | build |
| vendor_boot | build |
| dtbo | build |
| vbmeta | build |
| vbmeta_system | build |
| vbmeta_vendor | ALPHA |
| system | build |
| system_ext | build |
| product | build |
| odm | CLEAN (v11.17) |
| vendor | ALPHA |
| vendor_dlkm | ALPHA |

## Prerequisites
- Unlocked bootloader
- ADB/fastboot installed
- ALPHA vendor extracted to: ~/Downloads/TEST/Payload_Extract_ALPHA/

## Hybrid Flash (Recommended — Tested Working)
Uses built system partitions + ALPHA vendor

```bash
cd out/target/product/udon

# Boot chain
fastboot flash boot_a boot.img && fastboot flash boot_b boot.img
fastboot flash vendor_boot_a vendor_boot.img && fastboot flash vendor_boot_b vendor_boot.img
fastboot flash vbmeta_a vbmeta.img && fastboot flash vbmeta_b vbmeta.img
fastboot flash vbmeta_system_a vbmeta_system.img && fastboot flash vbmeta_system_b vbmeta_system.img

# ALPHA vbmeta_vendor
fastboot flash vbmeta_vendor_a ~/Downloads/TEST/Payload_Extract_ALPHA/vbmeta_vendor.img
fastboot flash vbmeta_vendor_b ~/Downloads/TEST/Payload_Extract_ALPHA/vbmeta_vendor.img

# Reboot to fastbootd
fastboot reboot fastboot

# System partitions (built)
fastboot flash system system.img
fastboot flash system_ext system_ext.img
fastboot flash product product.img
fastboot flash odm odm.img

# Vendor (ALPHA)
fastboot flash vendor ~/Downloads/TEST/Payload_Extract_ALPHA/vendor.img
fastboot flash vendor_dlkm ~/Downloads/TEST/Payload_Extract_ALPHA/vendor_dlkm.img

fastboot -w && fastboot reboot
```

## Post-Flash
1. Complete setup wizard
2. Flash MindTheGapps A15 arm64 via recovery sideload
3. Login Google account (fixes lockscreen/gatekeeper)
4. Enable crDroid Play Integrity spoof in Settings
