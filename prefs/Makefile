BUNDLE_NAME = grabprefs
grabprefs_FILES = GrabPrefsRootListController.m
grabprefs_FRAMEWORKS = UIKit
grabprefs_CFLAGS = -fobjc-arc
grabprefs_INSTALL_PATH = /Library/PreferenceBundles

include $(THEOS)/makefiles/common.mk
include $(THEOS_MAKE_PATH)/bundle.mk

# 强制把 Resources 里的所有文件打包进 bundle 根目录
grabprefs_RESOURCE_DIRS = Resources
