




FINALPACKAGE = 0
PACKAGE_VERSION = 1.0-2





ARCHS = armv7 armv7s arm64
TARGET = iphone:clang:latest





TWEAK_NAME = SWCello
SWCello_CFLAGS = -fobjc-arc
SWCello_FILES = MusicCoalescingEntityValueProvider.xm MusicContextualActionsHeaderViewController.xm MusicLibraryBrowseTableViewController.xm
SWCello_FRAMEWORKS = Foundation UIKit
SWCello_LIBRARIES = substrate

ADDITIONAL_CFLAGS = -Ipublic





include theos/makefiles/common.mk
include theos/makefiles/tweak.mk
include theos/makefiles/swcommon.mk





after-install::
	$(ECHO_NOTHING)install.exec "killall -9 Music > /dev/null 2> /dev/null"; echo -n '';$(ECHO_END)




