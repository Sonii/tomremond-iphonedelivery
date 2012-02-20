export THEOS_DEVICE_IP=192.168.17.203

CLANG=clang 

export TARGET_CC=$(CLANG)
export TARGET_CXX=$(CLANG)
export TARGET_LD=$(CLANG)

SDKVERSION = 5.0
include theos/makefiles/common.mk

TWEAK_NAME = Prefix
Prefix_FILES = Tweak.xm ct.xm
Prefix_FILES = Tweak.xm

include $(THEOS_MAKE_PATH)/tweak.mk
