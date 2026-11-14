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
    $(LOCAL_PATH)/configs/privapp-permissions-miuicamera.xml:$(TARGET_COPY_OUT_PRODUCT)/etc/permissions/privapp-permissions-miuicamera.xml

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

# The app keys its permission flow off ro.product.mod_device: when the value
# contains "_global" it assumes a global build and asks Android for the
# permissions itself, otherwise it launches the HyperOS Security Center
# permissions dialog. That app does not exist here, so the dialog never shows
# and the viewfinder stays black. This is the property equivalent of
# patches/0001, which forces the same branch by clobbering the flag register.
#
# A vendor build.prop entry does not work for this one: Android 12+ does not
# take bare ro.product.* keys from a partition build.prop, so the value landed in
# /vendor/build.prop line 425 and was never applied, which left the viewfinder
# frozen while the rest of the UI worked.
#
# Stock keeps it in mi_ext/etc/build.prop, and mi_ext folds into system_ext here,
# so this is the same channel. init.songyuan.rc also sets it, because the
# property is still empty at boot if this path is ever dropped again.
PRODUCT_SYSTEM_EXT_PROPERTIES += \
    ro.product.mod_device=songyuan
