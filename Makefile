TARGET := iphone:clang:latest:14.0
ARCHS := arm64 arm64e
THEOS_PACKAGE_SCHEME = roothide

include $(THEOS)/makefiles/common.mk

TWEAK_NAME := grab
grab_FILES := Tweak.xm
grab_CFLAGS := -fobjc-arc -Wno-deprecated-declarations
grab_FRAMEWORKS := Foundation UIKit Preferences
grab_PRIVATE_FRAMEWORKS := Preferences

include $(THEOS_MAKE_PATH)/tweak.mk

BUNDLE_NAME := grabprefs
grabprefs_INSTALL_PATH := /Library/PreferenceBundles
grabprefs_FRAMEWORKS := Foundation UIKit Preferences
grabprefs_PRIVATE_FRAMEWORKS := Preferences
grabprefs_FILES := Tweak.xm

include $(THEOS_MAKE_PATH)/bundle.mk
