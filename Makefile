export THEOS_DEVICE_IP=192.168.17.144
export TARGET_CC=$(SDKBINPATH)/gcc
export TARGET_LD=$(SDKBINPATH)/gcc
export DEBUG=0
VERSION=0.5beta14
REPO_URL=iphonedelivery@iphonedelivery.advinux.com
ifeq ($(DEBUG),1)
REPO=ios5debug
else
REPO=ios5beta
endif

export TARGET_CXX=$(SDKBINPATH)/g++
SDKVERSION = 5.0
include theos/makefiles/common.mk

SUBPROJECTS= CommCenterHook SpringBoardHook MobileSMSHook Settings WeeBrowseID

include $(THEOS_MAKE_PATH)/aggregate.mk

archive:
	git archive --format=tar HEAD | gzip > ~/idcc.${THEOS_PACKAGE_VERSION}.tar.gz

publish: 
	@dpkg-scanpackages . 2> /dev/null > Packages
	@cat Packages
	@bzip2 -f Packages
	ssh $(REPO_URL) mkdir -p www/$(REPO)/
	ssh $(REPO_URL) mkdir -p www/$(REPO)/QSB/
	scp Packages.bz2 $(REPO_URL):www/$(REPO)/
	scp com.guilleme.iphonedelivery_$(shell cat .theos/Packages/com.guilleme.iphonedelivery-$(VERSION))_iphoneos-arm.deb $(REPO_URL):www/$(REPO)/
	scp QSB/com.guilleme.QSB_$(shell cat ./QSB/.theos/Packages/com.guilleme.QSB-1.0)_iphoneos-arm.deb $(REPO_URL):www/$(REPO)/QSB/

after-stage::
	@mv  _/System/Library/WeeAppPlugins/WeeBrowseID.bundle/WeeBrowseID.dylib \
		_/System/Library/WeeAppPlugins/WeeBrowseID.bundle/WeeBrowseID
