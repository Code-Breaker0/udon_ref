#
# Copyright (C) 2021-2023 The LineageOS Project
#
# SPDX-License-Identifier: Apache-2.0
#

# Force vendor sepolicy source compilation
TARGET_USES_PREBUILT_VENDOR_SEPOLICY := false

DEVICE_PATH := device/oneplus/udon

# === Prebuilt Kernel Configuration ===
# Must be defined before including BoardConfigCommon.mk
KERNEL_PREBUILT_DIR := vendor/oneplus/udon-kernel
TARGET_FORCE_PREBUILT_KERNEL := true
TARGET_USES_KERNEL_PLATFORM := false

# Include the common OEM chipset BoardConfig.
include device/oneplus/sm8450-common/BoardConfigCommon.mk

# Display
TARGET_SCREEN_DENSITY := 480

# Properties
TARGET_VENDOR_PROP += $(DEVICE_PATH)/vendor.prop

# SEPolicy
BOARD_VENDOR_SEPOLICY_DIRS += $(DEVICE_PATH)/sepolicy/vendor

# Recovery
TARGET_RECOVERY_UI_MARGIN_HEIGHT := 103

# Include the proprietary files BoardConfig.
include vendor/oneplus/udon/BoardConfigVendor.mk

# Firmware
include vendor/oneplus/firmware-udon/BoardConfigVendor.mk

# Force use of prebuilt kernel + modules
TARGET_PREBUILT_KERNEL := $(KERNEL_PREBUILT_DIR)/Image
BOARD_VENDOR_RAMDISK_KERNEL_MODULES := $(wildcard $(KERNEL_PREBUILT_DIR)/vendor_ramdisk/*.ko)
BOARD_VENDOR_RAMDISK_KERNEL_MODULES_LOAD := $(shell cat $(KERNEL_PREBUILT_DIR)/vendor_ramdisk/modules.load)
BOARD_VENDOR_RAMDISK_RECOVERY_KERNEL_MODULES_LOAD := $(shell cat $(KERNEL_PREBUILT_DIR)/vendor_ramdisk/modules.load.recovery)

BOARD_VENDOR_KERNEL_MODULES := $(wildcard $(KERNEL_PREBUILT_DIR)/vendor_dlkm/*.ko)
BOARD_VENDOR_KERNEL_MODULES_LOAD := $(shell cat $(KERNEL_PREBUILT_DIR)/vendor_dlkm/modules.load)
BOARD_VENDOR_RAMDISK_KERNEL_MODULES_BLOCKLIST_FILE := $(KERNEL_PREBUILT_DIR)/vendor_ramdisk/modules.blocklist

# Recovery - A/B GKI device with dedicated recovery partition
TARGET_NO_RECOVERY := false
BOARD_USES_RECOVERY_AS_BOOT := false
BOARD_MOVE_RECOVERY_RESOURCES_TO_VENDOR_BOOT := false
TARGET_NEEDS_RECOVERY_AS_BOOT := false
BUILDING_RECOVERY_IMAGE := true
BOARD_EXCLUDE_KERNEL_FROM_RECOVERY_IMAGE := true

# Force OTA package generation

# === Clean DTB Prebuilt Configuration ===
BOARD_INCLUDE_DTB_IN_BOOTIMG := true
BOARD_PREBUILT_DTBIMAGE_DIR := $(KERNEL_PREBUILT_DIR)/dtbs
BOARD_PREBUILT_DTBOIMAGE := $(KERNEL_PREBUILT_DIR)/dtbs/dtbo.img

# Force inclusion of Lineage common sepolicy (skipped by core makefiles when LINEAGE_BUILD is empty)
include device/lineage/sepolicy/common/sepolicy.mk
