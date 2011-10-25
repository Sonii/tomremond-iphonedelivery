export THEOS_DEVICE_IP=192.168.17.144

#CLANG=~/llvm_build/Release+Asserts/bin/clang 
CLANG=clang 

ifeq ($(CLANG),)
export TARGET_CC=$(SDKBINPATH)/gcc
export TARGET_CXX=$(SDKBINPATH)/g++
export TARGET_LD=$(SDKBINPATH)/gcc
else

ifneq ($(ANALYSE),1)
export TARGET_CC=$(CLANG) 
export TARGET_CXX=$(CLANG)
else
export TARGET_CC=$(CLANG) --analyze
export TARGET_CXX=$(CLANG) --analyze
endif

export TARGET_LD=$(CLANG)
endif

export DEBUG=0
export USES_MS=NO

VERSION=0.5gm3
REPO_URL=iphonedelivery@iphonedelivery.advinux.com
ifeq ($(DEBUG),1)
REPO=ios5debug
else
ifeq ($(USES_MS),YES)
REPO=ios5ms
else
REPO=ios5beta
endif
endif

SDKVERSION = 5.0

include theos/makefiles/common.mk

SUBPROJECTS= CommCenterHook SpringBoardHook MobileSMSHook Settings WeeBrowseID

include $(THEOS_MAKE_PATH)/aggregate.mk

archive:
	git archive --format=tar HEAD | gzip > ~/idcc.${THEOS_PACKAGE_VERSION}.tar.gz

check-plist:
	@( cd 'layout/Library/Application Support/ID.bundle/'; for f in *.plist; do plutil $$f; done)
	@( cd Settings/Resources/; for d in *.lproj; do plutil $$d/*.strings; done )

publish: 
	@dpkg-scanpackages . 2> /dev/null > Packages
	@cat Packages
	@bzip2 -f Packages
	ssh $(REPO_URL) mkdir -p www/$(REPO)/
	ssh $(REPO_URL) mkdir -p www/$(REPO)/WeeSpaces/
	scp Packages.bz2 $(REPO_URL):www/$(REPO)/
	scp com.guilleme.iphonedelivery_$(shell cat .theos/Packages/com.guilleme.iphonedelivery-$(VERSION))_iphoneos-arm.deb $(REPO_URL):www/$(REPO)/
	scp WeeSpaces/com.guilleme.WeeSpaces_$(shell cat ./WeeSpaces/.theos/Packages/com.guilleme.WeeSpaces-1.1)_iphoneos-arm.deb $(REPO_URL):www/$(REPO)/WeeSpaces/

after-stage::
	@mv  _/System/Library/WeeAppPlugins/WeeBrowseID.bundle/WeeBrowseID.dylib \
		_/System/Library/WeeAppPlugins/WeeBrowseID.bundle/WeeBrowseID
ifeq ("${USES_MS}","YES")
	@echo cp CommCenterHook/libidcc.plist _/Library/MobileSubstrate/DynamicLibraries
endif

ifeq ($(DEBUG),1)
before-package::
	@sed -i "" '/^Depends:/s/$$/, syslogd/' _/DEBIAN/control 
endif
