.PHONY: all clean
all:

# Cross compilation
CROSS_ARCH =
CROSS_PATH =
CROSS_PREFIX =
CROSS_CC = $(CROSS_PATH)/bin/$(CROSS_PREFIX)gcc
CROSS_CFLAGS = -Os

# Host compilation
HOST_CC = gcc

# Linux
LINUX_DIR = linux
LINUX_SRC =  # tarball or directory (optional)
LINUX_VERSION = 2.6.28 # download if no LINUX_SRC
LINUX_PATCH_DIR =  # (optional) TODO: not implemented
LINUX_CONFIG =
include $(LINUX_DIR)/linux.mk

#include makedevs/makedevs.mk
#include busybox/busybox.mk
#include image/image.mk

# Packages
PKG_DIR = packages
PKG_DROPBEAR = no
#include $(PKG_DIR)/packages.mk

include config.mk
