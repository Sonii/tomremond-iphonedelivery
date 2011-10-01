include theos/makefiles/common.mk

VPATH = ../Common

TWEAK_NAME = libidsms
libidsms_INSTALL_PATH = /Library/MobileSubstrate/DynamicLibraries
libidsms_FRAMEWORKS = CoreFoundation Foundation UIKit CoreGraphics
libidsms_FILES = MobileSMS.xm database.m Date+extra.m DeliveryDateView.m MarkView.m Localizer.m smiley.m DeliveryDateView.m ReportCache.m
libidsms_CFLAGS = -I../Common 
libidsms_LDFLAGS = -lsqlite3

include $(THEOS_MAKE_PATH)/tweak.mk

