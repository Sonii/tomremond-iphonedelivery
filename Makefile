export THEOS_DEVICE_IP=192.168.17.144
SDKVERSION = 5.0
include theos/makefiles/common.mk

SUBPROJECTS= CommCenterHook SpringBoardHook MobileSMSHook Settings

include $(THEOS_MAKE_PATH)/aggregate.mk

archive:
	git archive --format=tar HEAD | gzip > ~/idcc.${THEOS_PACKAGE_VERSION}.tar.gz
