include theos/makefiles/common.mk

DEBUG=YES
USES_MS=NO
VPATH = ../Common

LIBRARY_NAME = libidcc
libidcc_FILES = CommCenterHook.m debug.m utils.c notify.m submit.m unpack.c rewrite.m NSData+serial.m
libidcc_FRAMEWORKS = CoreFoundation Foundation
libidcc_INSTALL_PATH = /usr/local/lib

libidcc_CFLAGS = -std=gnu99 -D${DEBUG}DEBUG -I../Common
libidcc_LDFLAGS = -lsubstrate

ifeq ("${USES_MS}","YES")
libidcc_CFLAGS +=  -DUSES_MS
libidcc_LDFLAGS += -init _idccInitialize
libidcc_INSTALL_PATH = /Library/MobileSubstrate/DynamicLibraries
endif

include $(THEOS_MAKE_PATH)/library.mk

