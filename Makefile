目标 := iphone:clang:latest:14.0
包含 $(THEOS_MAKE_PATH)/tweak.mk
THEOS_PACKAGE_SCHEME = roothide

include $(THEOS)/makefiles/common.mk

TWEAK_NAME := grab
grab_FILES := Tweak.xm
grab_CFLAGS := -fobjc-arc -Wno-deprecated-declarations
grab_FRAMEWORKS := Foundation UIKit

include $(THEOS_MAKE_PATH)/tweak.mk
