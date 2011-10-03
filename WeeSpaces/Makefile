export THEOS_DEVICE_IP=192.168.17.144
export TARGET_CC=$(SDKBINPATH)/gcc
export TARGET_LD=$(SDKBINPATH)/gcc
export TARGET_CXX=$(SDKBINPATH)/g++

include theos/makefiles/common.mk

LIBRARY_NAME = WeeSpaces
WeeSpaces_FILES = WeeSpaces.mm
WeeSpaces_INSTALL_PATH = /System/Library/WeeAppPlugins/WeeSpaces.bundle/
WeeSpaces_FRAMEWORKS = UIKit CoreGraphics
WeeSpaces_PRIVATE_FRAMEWORKS = BulletinBoard

include $(THEOS_MAKE_PATH)/library.mk

after-stage::
	@mv  _/System/Library/WeeAppPlugins/WeeSpaces.bundle/WeeSpaces.dylib \
		_/System/Library/WeeAppPlugins/WeeSpaces.bundle/WeeSpaces


