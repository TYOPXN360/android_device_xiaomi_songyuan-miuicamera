#
# Copyright (C) 2023 The LineageOS Project
#
# SPDX-License-Identifier: Apache-2.0
#

# Inherit from the proprietary version
$(call inherit-product, vendor/xiaomi/songyuan-miuicamera/songyuan-miuicamera-vendor.mk)

# Camera
$(call soong_config_set_bool,camera,override_format_from_reserved,true)

# Hypsys_system
PRODUCT_PACKAGES += \
    vendor.xiaomi.hardware.misys-service

# Public libraries
PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/configs/public.libraries-xiaomi.txt:$(TARGET_COPY_OUT_SYSTEM)/etc/public.libraries-xiaomi.txt

# Priv-app permission
# Both apps live in /product/priv-app and the China stock build keeps their
# allowlists on the same partition (product/etc/permissions), so install them
# there rather than on /system.
PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/configs/privapp-permissions-miuicamera.xml:$(TARGET_COPY_OUT_PRODUCT)/etc/permissions/privapp-permissions-miuicamera.xml \
    $(LOCAL_PATH)/configs/privapp-permissions-miuiscanner.xml:$(TARGET_COPY_OUT_PRODUCT)/etc/permissions/privapp-permissions-miuiscanner.xml

# Soong namespaces
PRODUCT_SOONG_NAMESPACES += \
    $(LOCAL_PATH)

# Sysconfig
PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/configs/miuicamera-hiddenapi-package-allowlist.xml:$(TARGET_COPY_OUT_SYSTEM)/etc/sysconfig/miuicamera-hiddenapi-package-allowlist.xml

# MIUICamera needs CAMERA before it can enumerate anything; without it the
# viewfinder stays black. Grant the set up front and pin it.
PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/configs/default-permissions-miuicamera.xml:$(TARGET_COPY_OUT_PRODUCT)/etc/default-permissions/default-permissions-miuicamera.xml
