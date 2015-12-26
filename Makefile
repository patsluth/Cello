




FINALPACKAGE = 1
PACKAGE_VERSION = 1.0-1





ARCHS = armv7 armv7s arm64
TARGET = iphone:clang:latest





TWEAK_NAME = SWCello
SWCello_CFLAGS = -fobjc-arc
SWCello_FILES = MusicCoalescingEntityValueProvider.xm MusicEntityValueContext.xm MusicContextualActionsHeaderViewController.xm MusicLibraryBrowseTableViewController.xm MusicMediaDetailViewController.xm Prefs.xm
SWCello_FRAMEWORKS = Foundation UIKit MediaPlayer
SWCello_LIBRARIES = substrate sw packageinfo

ADDITIONAL_CFLAGS = -Ipublic





BUNDLE_NAME = CelloSupport
CelloSupport_INSTALL_PATH = /Library/Application Support





SUBPROJECTS += CelloPrefs





include theos/makefiles/common.mk
include theos/makefiles/bundle.mk
include theos/makefiles/tweak.mk
include theos/makefiles/aggregate.mk
include theos/makefiles/swcommon.mk





after-install::
	$(ECHO_NOTHING)install.exec "killall -9 Music > /dev/null 2> /dev/null"; echo -n '';$(ECHO_END)




