include theos/makefiles/common.mk

VPATH = ../Common

LIBRARY_NAME = libidcc
libidcc_FILES = CommCenterHook.m debug.m utils.c notify.m submit.m unpack.c rewrite.m NSData+serial.m
libidcc_FRAMEWORKS = CoreFoundation Foundation
libidcc_INSTALL_PATH = /usr/local/lib

libidcc_CFLAGS = -std=gnu99 -I../Common

include $(THEOS_MAKE_PATH)/library.mk

