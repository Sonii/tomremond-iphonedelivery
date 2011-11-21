export THEOS_DEVICE_IP=192.168.17.144
CLANG=clang

export TARGET_CC=$(CLANG)
export TARGET_LD=$(CLANG)
export TARGET_CXX=$(CLANG)++

include theos/makefiles/common.mk

LIBRARY_NAME = WeeSpaces
WeeSpaces_FILES = WeeSpaces.mm Snapshot.m UIImage+scale.m WeeSpacesView.m WeeAppView.m
WeeSpaces_INSTALL_PATH = /Library/WeeLoader/Plugins/WeeSpaces.bundle
WeeSpaces_FRAMEWORKS = UIKit CoreGraphics
WeeSpaces_PRIVATE_FRAMEWORKS = BulletinBoard

include $(THEOS_MAKE_PATH)/library.mk

after-stage::
	@mv  _/Library/WeeLoader/Plugins/WeeSpaces.bundle/WeeSpaces.dylib \
		_/Library/WeeLoader/Plugins/WeeSpaces.bundle/WeeSpaces


