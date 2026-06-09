# Known Bugs & Fixes

## Fixed
| Bug | Fix | File |
|-----|-----|------|
| dtb.img ninja failure | BOARD_INCLUDE_DTB_IN_BOOTIMG + BOARD_PREBUILT_DTBIMAGE_DIR | device/oneplus/udon/BoardConfig.mk |
| SettingsLib Baklava injection | Use ap3a lunch target not trunk_staging | Build command |
| OOM at 80% | Use make -j8 not mka | Build command |
| Zygote64_32 crash | core_64_bit.mk + dummy init.zygote64_32.rc | device/oneplus/udon/crdroid_udon.mk |
| Network OUT_OF_SERVICE | Remove AIDL radio from manifest_dsds.xml | device/oneplus/sm8450-common/manifest_dsds.xml |
| Dynamic partition overflow | BOARD_ONEPLUS_DYNAMIC_PARTITIONS_SIZE=14000000000 | device/oneplus/sm8450-common/BoardConfigCommon.mk |
| VINTF framework matrix | Add oplus HALs as optional=true | device/oneplus/sm8450-common/device_framework_matrix.xml |
| CneApp crash loop | Patch ConnectivityManager.java | frameworks/opt/telephony |
| wpa_supplicant compile error | C-style casts | external/wpa_supplicant_8 |
| Vendor underpopulated | 54 RC/config files from ALPHA | vendor/oneplus/sm8450-common |
| init_boot flash failure | Remove from AB_OTA_PARTITIONS | device/oneplus/sm8450-common/BoardConfigCommon.mk |

## Pending
| Bug | Status | Notes |
|-----|--------|-------|
| UDFPS dim glow | In progress | notify_fppress needs 0660 permissions |
| AOD flickering | Fix applied | config_allowAutoBrightnessWhileDozing=false |
| Auto-brightness dim | Fix applied | Lux curves adjusted in overlay |
| Gatekeeper service | Fixed via GApps | Flash GApps after ROM |
