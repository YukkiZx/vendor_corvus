ifeq ($(PRODUCT_GMS_CLIENTID_BASE),)
PRODUCT_SYSTEM_DEFAULT_PROPERTIES += \
    ro.com.google.clientidbase=android-google
else
PRODUCT_SYSTEM_DEFAULT_PROPERTIES += \
    ro.com.google.clientidbase=$(PRODUCT_GMS_CLIENTID_BASE)
endif

# Additional props
PRODUCT_SYSTEM_DEFAULT_PROPERTIES += \
    dalvik.vm.debug.alloc=0 \
    ro.url.legal=http://www.google.com/intl/%s/mobile/android/basic/phone-legal.html \
    ro.url.legal.android_privacy=http://www.google.com/intl/%s/mobile/android/basic/privacy.html \
    ro.error.receiver.system.apps=com.google.android.gms \
    ro.setupwizard.enterprise_mode=1 \
    ro.com.android.dataroaming=false \
    ro.atrace.core.services=com.google.android.gms,com.google.android.gms.ui,com.google.android.gms.persistent \
    ro.setupwizard.rotation_locked=true \
    ro.com.google.ime.theme_id=5 \
    ro.storage_manager.enabled=1 \
    ro.opa.eligible_device=true \
    ro.com.android.wifi-watchlist=GoogleGuest \
    ro.setupwizard.network_required=false \
    ro.setupwizard.gservices_delay=-1 \
    ro.setupwizard.mode=OPTIONAL \
    setupwizard.feature.predeferred_enabled=false \
    drm.service.enabled=true \
    ro.iorapd.enable=true \
    net.tethering.noprovisioning=true \
    keyguard.no_require_sim=true \
    persist.sys.disable_rescue=true \
    persist.debug.wfd.enable=1 \
    persist.sys.wfd.virtual=0 \
    ro.build.selinux=1

PRODUCT_PROPERTY_OVERRIDES += \
    ro.services.whitelist.packagelist=com.google.android.gms

# This needs to be specified explicitly to override ro.apex.updatable=true from
# prebuilt vendors, as init reads /product/build.prop after /vendor/build.prop
PRODUCT_PRODUCT_PROPERTIES += ro.apex.updatable=false

# Gapps
ifeq ($(USE_GAPPS),true)
include vendor/gms/gms.mk
endif

# Proton Clang
ifeq ($(USE_PROTON),true)
KERNEL_SUPPORTS_LLVM_TOOLS := true
TARGET_KERNEL_CLANG_VERSION := proton
TARGET_KERNEL_CLANG_PATH := $(shell pwd)/prebuilts/clang/host/linux-x86/clang-proton
TARGET_KERNEL_CROSS_COMPILE_PREFIX := aarch64-linux-gnu-
endif

# Copy all custom init rc files
$(foreach f,$(wildcard vendor/corvus/prebuilt/common/etc/init/*.rc),\
    $(eval PRODUCT_COPY_FILES += $(f):$(TARGET_COPY_OUT_SYSTEM)/etc/init/$(notdir $f)))

# Backup tool
PRODUCT_COPY_FILES += \
    vendor/corvus/build/tools/backuptool.sh:install/bin/backuptool.sh \
    vendor/corvus/build/tools/backuptool.functions:install/bin/backuptool.functions \
    vendor/corvus/build/tools/50-corvus.sh:$(TARGET_COPY_OUT_SYSTEM)/addon.d/50-corvus.sh

# Permission
PRODUCT_COPY_FILES += \
    vendor/corvus/prebuilt/common/etc/permissions/corvus-power-whitelist.xml:$(TARGET_COPY_OUT_SYSTEM)/etc/sysconfig/corvus-power-whitelist.xml \
    vendor/corvus/prebuilt/common/etc/permissions/privapp-permissions-corvus-system.xml:$(TARGET_COPY_OUT_SYSTEM)/etc/permissions/privapp-permissions-corvus-system.xml \
    vendor/corvus/prebuilt/common/etc/permissions/privapp-permissions-corvus-product.xml:$(TARGET_COPY_OUT_PRODUCT)/etc/permissions/privapp-permissions-corvus-product.xml \
    vendor/corvus/prebuilt/common/etc/permissions/privapp-permissions-recorder.xml:$(TARGET_COPY_OUT_SYSTEM)/etc/permissions/privapp-permissions-recorder.xml \
    vendor/corvus/prebuilt/common/etc/permissions/privapp-permissions-corvus-system_ext.xml:$(TARGET_OUT_SYSTEM_EXT_ETC)/etc/permissions/privapp-permissions-corvus-system_ext.xml \
    vendor/corvus/prebuilt/common/etc/permissions/privapp-permissions-elgoog.xml:$(TARGET_COPY_OUT_SYSTEM)/etc/permissions/privapp-permissions-elgoog.xml \
    vendor/corvus/prebuilt/google/etc/sysconfig/pixel_experience_2020.xml:$(TARGET_COPY_OUT_PRODUCT)/etc/sysconfig/pixel_experience_2020.xml 


# Disable vendor restrictions
PRODUCT_RESTRICT_VENDOR_FILES := false

# Flatten APEXs for performance
OVERRIDE_TARGET_FLATTEN_APEX := true

# Strip the local variable table and the local variable type table to reduce
# the size of the system image. This has no bearing on stack traces, but will
# leave less information available via JDWP.
PRODUCT_MINIMIZE_JAVA_DEBUG_INFO := true

# Enable ccache
USE_CCACHE := true

# Art
include vendor/corvus/config/art.mk

# Boot animation
include vendor/corvus/config/bootanimation.mk

# Branding
include vendor/corvus/config/branding.mk

# Packages
include vendor/corvus/config/packages.mk

# Themes
include vendor/themes/common.mk

# Overlays
PRODUCT_ENFORCE_RRO_EXCLUDED_OVERLAYS += vendor/corvus/overlay
DEVICE_PACKAGE_OVERLAYS += vendor/corvus/overlay/common

# Face Unlock
TARGET_FACE_UNLOCK_SUPPORTED := false
ifneq ($(TARGET_DISABLE_ALTERNATIVE_FACE_UNLOCK), true)
PRODUCT_PACKAGES += \
    FaceUnlockService
TARGET_FACE_UNLOCK_SUPPORTED := true
endif
PRODUCT_SYSTEM_DEFAULT_PROPERTIES += \
    ro.face.moto_unlock_service=$(TARGET_FACE_UNLOCK_SUPPORTED)

# Copy all init rc files
$(foreach f,$(wildcard vendor/corvus/prebuilt/common/etc/init/*.rc),\
	$(eval PRODUCT_COPY_FILES += $(f):$(TARGET_COPY_OUT_SYSTEM)/etc/init/$(notdir $f)))

ifneq (,$(filter $(RAVEN_LAIR), Official OFFICIAL))
    ifneq (,$(filter $(TEST_BUILD), true))
        SIGNING_KEYS := certs
        ifeq ($(wildcard certs/keys.txt),)
             $(warning Signing keys not found!)
             $(warning Copy paste 'git clone https://github.com/Corvus-R/.certs certs')
             $(error Official build can't be done without signing keys; exiting)
        endif
    endif
endif
