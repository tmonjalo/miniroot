.PHONY: all clean
all:

# Cross compilation
CROSS_ARCH =
CROSS_PATH =
CROSS_PREFIX =
#CROSS_CC = $(CROSS_PATH)/bin/$(CROSS_PREFIX)gcc # (optional)
CROSS_CFLAGS = -Os

# Host compilation
HOST_CC = gcc

# Linux
LINUX_DIR = linux
LINUX_SRC = 2.6.28 # directory or tarball or VCS URL or version
LINUX_PATCH_DIR =  # (optional)
LINUX_CONFIG =

# Busybox
BUSYBOX_DIR = busybox
BUSYBOX_SRC = 1.13.2 # directory or tarball or VCS URL or version
BUSYBOX_PATCH_DIR =  # (optional)
BUSYBOX_CONFIG =

# Packages
PKG_DIR = packages
PKG_DROPBEAR = no
#include $(PKG_DIR)/packages.mk

# Build outside of the sources
BUILD_DIR = build

# Overwrite default configuration with user parameters
include config.mk

# All rules
TOOLS_DIR = tools
include $(TOOLS_DIR)/init.mk
include $(TOOLS_DIR)/common.mk
include $(LINUX_DIR)/linux.mk
#include $(BUSYBOX_DIR)/busybox.mk
#include makedevs/makedevs.mk
#include image/image.mk
