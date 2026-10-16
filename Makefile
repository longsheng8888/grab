TARGET := iphone:clang:latest:14.0
ARCHS := arm64 arm64e
THEOS_PACKAGE_SCHEME = roothide
INSTALL_TARGET_PROCESSES := 货拉拉司机端

include $(THEOS)/makefiles/common.mk

TWEAK_NAME := grab
grab_FILES := Tweak.xm
grab_CFLAGS := -fobjc-arc -Wno-deprecated-declarations
grab_FRAMEWORKS := Foundation UIKit

include $(THEOS_MAKE_PATH)/tweak.mk
