export THEOS_DEVICE_IP=192.168.17.144
export TARGET_CC=$(SDKBINPATH)/gcc
export DEBUG=NO
export TARGET_LD=$(SDKBINPATH)/gcc
VERSION=0.5beta1
REPO_URL=iphonedelivery@iphonedelivery.advinux.com
REPO=ios5beta

export TARGET_CXX=$(SDKBINPATH)/g++
SDKVERSION = 5.0
include theos/makefiles/common.mk

SUBPROJECTS= CommCenterHook SpringBoardHook MobileSMSHook Settings

include $(THEOS_MAKE_PATH)/aggregate.mk

archive:
	git archive --format=tar HEAD | gzip > ~/idcc.${THEOS_PACKAGE_VERSION}.tar.gz

publish: package
	@dpkg-scanpackages . 2> /dev/null > Packages
	@cat Packages
	@bzip2 Packages
	ssh $(REPO_URL) mkdir -p www/$(REPO)/
	scp Packages.bz2 $(REPO_URL):www/$(REPO)/
	scp com.guilleme.iphonedelivery_$(shell cat .theos/Packages/com.guilleme.iphonedelivery-0.5beta1)_iphoneos-arm.deb $(REPO_URL):www/$(REPO)/

