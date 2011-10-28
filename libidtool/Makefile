export THEOS_DEVICE_IP=192.168.17.144
CLANG=clang

export TARGET_CC=$(CLANG)
export TARGET_LD=$(CLANG)
export TARGET_CXX=$(CLANG)++

include theos/makefiles/common.mk

TOOL_NAME = libidtool
libidtool_FILES = main.mm
libidtool_FRAMEWORKS = Foundation UIKit

include $(THEOS_MAKE_PATH)/tool.mk
