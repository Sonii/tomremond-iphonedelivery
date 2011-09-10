include theos/makefiles/common.mk

VPATH = ../Common

LIBRARY_NAME = WeeBrowseID
WeeBrowseID_FILES = WeeBrowseID.mm database.m Localizer.m Date+extra.m
WeeBrowseID_INSTALL_PATH = /System/Library/WeeAppPlugins/WeeBrowseID.bundle/
WeeBrowseID_FRAMEWORKS = UIKit CoreGraphics
WeeBrowseID_PRIVATE_FRAMEWORKS = BulletinBoard
WeeBrowseID_CFLAGS = -I../Common
WeeBrowseID_LDFLAGS = -lsqlite3

include $(THEOS_MAKE_PATH)/library.mk

