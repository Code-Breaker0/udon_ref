#
# Copyright (C) 2021-2023 The LineageOS Project
#
# SPDX-License-Identifier: Apache-2.0
#

TARGET_USES_KERNEL_PLATFORM := false

# Inherit from those products. Most specific first.
$(call inherit-product, $(SRC_TARGET_DIR)/product/core_64_bit.mk)
$(call inherit-product, $(SRC_TARGET_DIR)/product/full_base_telephony.mk)

# Inherit from udon device
$(call inherit-product, device/oneplus/udon/device.mk)

# Inherit some common Lineage stuff.
$(call inherit-product, vendor/crdroid/config/common_full_phone.mk)

PRODUCT_NAME := crdroid_udon
PRODUCT_DEVICE := udon
PRODUCT_MANUFACTURER := oplus
PRODUCT_BRAND := oplus
PRODUCT_MODEL := CPH2487
HYACINTH_BUILDTYPE := OFFICIAL

PRODUCT_SYSTEM_NAME := CPH2487
PRODUCT_SYSTEM_DEVICE := OP5961L1

PRODUCT_GMS_CLIENTID_BASE := android-oneplus

PRODUCT_BUILD_PROP_OVERRIDES += \
    BuildDesc= "CPH2487-user 13 SKQ1.220905.001 R4T3.1057738-62b8-3b9 release-keys" \
    DeviceName=$(PRODUCT_SYSTEM_DEVICE) \
    DeviceProduct=$(PRODUCT_SYSTEM_NAME)

BUILD_FINGERPRINT := OnePlus/CPH2487/OP5961L1:13/SKQ1.221119.001/T.R4T3.1057738-62b8-3b9:user/release-keys
PRODUCT_BUILD_GENERIC_OTA_PACKAGE := true
