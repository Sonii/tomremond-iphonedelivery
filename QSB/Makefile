export THEOS_DEVICE_IP=192.168.17.144
export TARGET_CC=$(SDKBINPATH)/gcc
export TARGET_LD=$(SDKBINPATH)/gcc
export TARGET_CXX=$(SDKBINPATH)/g++

include theos/makefiles/common.mk

LIBRARY_NAME = WeeQSB
WeeQSB_FILES = WeeQSB.mm
WeeQSB_INSTALL_PATH = /System/Library/WeeAppPlugins/WeeQSB.bundle/
WeeQSB_FRAMEWORKS = UIKit CoreGraphics
WeeQSB_PRIVATE_FRAMEWORKS = BulletinBoard

include $(THEOS_MAKE_PATH)/library.mk

after-stage::
	@mv  _/System/Library/WeeAppPlugins/WeeQSB.bundle/WeeQSB.dylib \
		_/System/Library/WeeAppPlugins/WeeQSB.bundle/WeeQSB


