export THEOS_DEVICE_IP=192.168.17.144
CLANG=/Users/francois/llvm_build/Release+Asserts/bin/clang

export TARGET_CC=$(CLANG)
export TARGET_LD=$(CLANG)
export TARGET_CXX=$(CLANG)++

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


