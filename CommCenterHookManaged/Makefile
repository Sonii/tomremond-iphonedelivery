include theos/makefiles/common.mk

VPATH = ../Common

LIBRARY_NAME = libidccms
libidccms_FILES = CommCenterHook.m debug.m utils.c notify.m submit.m unpack.c rewrite.m NSData+serial.m
libidccms_FRAMEWORKS = CoreFoundation Foundation

libidccms_CFLAGS = -std=gnu99 -I../Common
libidccms_LDFLAGS = -lsubstrate

libidccms_CFLAGS +=  -DUSES_MS
libidccms_LDFLAGS += -init _idccInitialize
libidccms_INSTALL_PATH = /Library/MobileSubstrate/DynamicLibraries

include $(THEOS_MAKE_PATH)/library.mk

