# Soong namespace for Qualcomm WLAN driver command library
PRODUCT_SOONG_NAMESPACES += hardware/qcom-caf/wlan
PRODUCT_SOONG_NAMESPACES += hardware/qcom-caf/wlan

# Bootanimation Soong config (fixes crDroid prebuilt bootanimation)
SOONG_CONFIG_NAMESPACES += lineage_bootanimation
SOONG_CONFIG_lineage_bootanimation += width height
SOONG_CONFIG_lineage_bootanimation_width := 1440
SOONG_CONFIG_lineage_bootanimation_height := 3216

# Bootanimation Soong config (OnePlus 11R = 2772x1240)
SOONG_CONFIG_NAMESPACES += lineage_bootanimation
SOONG_CONFIG_lineage_bootanimation += width height
SOONG_CONFIG_lineage_bootanimation_width := 2772
SOONG_CONFIG_lineage_bootanimation_height := 1240
