export THEOS_DEVICE_IP=192.168.17.144
export TARGET_CC=$(SDKBINPATH)/gcc
export DEBUG=NO
export TARGET_LD=$(SDKBINPATH)/gcc
export TARGET_CXX=$(SDKBINPATH)/g++
SDKVERSION = 5.0
include theos/makefiles/common.mk

SUBPROJECTS= CommCenterHook SpringBoardHook MobileSMSHook Settings

include $(THEOS_MAKE_PATH)/aggregate.mk

archive:
	git archive --format=tar HEAD | gzip > ~/idcc.${THEOS_PACKAGE_VERSION}.tar.gz
