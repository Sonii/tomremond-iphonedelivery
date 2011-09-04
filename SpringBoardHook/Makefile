include theos/makefiles/common.mk

VPATH = ../Common

TWEAK_NAME = libidsp
libidsp_INSTALL_PATH = /Library/MobileSubstrate/DynamicLibraries
libidsp_FRAMEWORKS = CoreFoundation Foundation AudioToolbox UIKit
libidsp_FILES = SpringBoard.xm database.m Localizer.m Date+extra.m NSData+serial.m Bulletin.m
libidsp_PRIVATE_FRAMEWORKS = ToneLibrary
libidsp_CFLAGS = -I../Common
libidsp_LDFLAGS = -lsqlite3

include $(THEOS_MAKE_PATH)/tweak.mk
