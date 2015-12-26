




ARCHS = armv7 armv7s arm64
TARGET = iphone:clang:latest





BUNDLE_NAME = CelloPrefs
CelloPrefs_CFLAGS = -fobjc-arc
CelloPrefs_FILES = SWCelloPSListController.mm
CelloPrefs_INSTALL_PATH = /Library/PreferenceBundles
CelloPrefs_FRAMEWORKS = UIKit
CelloPrefs_PRIVATE_FRAMEWORKS = Preferences
CelloPrefs_LIBRARIES = sw





include theos/makefiles/common.mk
include theos/makefiles/bundle.mk
include theos/makefiles/swcommon.mk





internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/$(BUNDLE_NAME).plist$(ECHO_END)




