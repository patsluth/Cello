




FINALPACKAGE = 1
DEBUG = 0
PACKAGE_VERSION = 1.0-10






ifeq ($(DEBUG), 1)
    ARCHS = arm64
else
    ARCHS = armv7 armv7s arm64
endif
TARGET = iphone:clang:latest:7.0





TWEAK_NAME = Cello
Cello_CFLAGS = -fobjc-arc
Cello_FILES = MusicCoalescingEntityValueProvider.xm \
                MusicContextualActionsHeaderViewController.xm \
                MusicEntityValueContext.xm \
                MusicLibraryBrowseCollectionViewController.xm \
                MusicLibraryBrowseTableViewController.xm \
                MusicLibraryComposersViewConfiguration.xm \
                MusicLibraryGenresViewConfiguration.xm \
                MusicLibrarySongsViewConfiguration.xm \
                MusicLibraryViewConfiguration.xm \
                MusicMediaDetailViewController.xm \
                SWCelloDataSource.xm \
                SWCelloPrefs.xm \

ifeq ($(DEBUG), 1)
    Cello_CFLAGS += -Wno-unused-variable
    Cello_FILES += SWCelloTest.xm SWCelloDebug.xm
endif

Cello_FRAMEWORKS = Foundation UIKit MediaPlayer
Cello_LIBRARIES = substrate sw packageinfo MobileGestalt

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
	$(ECHO_NOTHING)install.exec "killall -9 Preferences > /dev/null 2> /dev/null"; echo -n '';$(ECHO_END)




