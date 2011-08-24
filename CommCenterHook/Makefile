include theos/makefiles/common.mk
#DEBUG=NO
VPATH = ../Common

LIBRARY_NAME = libidcc
libidcc_FILES = CommCenterHook.m debug.m utils.c notify.m submit.m unpack.c rewrite.m NSData+serial.m
libidcc_INSTALL_PATH = /Library/MobileSubstrate/DynamicLibraries
libidcc_FRAMEWORKS = CoreFoundation Foundation AudioToolbox
libidcc_CFLAGS = -std=gnu99 -DUSES_MS -D${DEBUG}DEBUG -I../Common

libidcc_LDFLAGS = -init _idccInitialize -lsubstrate

include $(THEOS_MAKE_PATH)/library.mk

