include theos/makefiles/common.mk

BUNDLE_NAME = DeliveryReportSettings
DeliveryReportSettings_FILES = DeliveryReportSettings.mm 
DeliveryReportSettings_INSTALL_PATH = /System/Library/PreferenceBundles
DeliveryReportSettings_FRAMEWORKS = UIKit
DeliveryReportSettings_LDFLAGS += -lsubstrate
DeliveryReportSettings_CFLAGS += -I../Common
DeliveryReportSettings_PRIVATE_FRAMEWORKS = Preferences ToneLibrary

include $(THEOS_MAKE_PATH)/bundle.mk

