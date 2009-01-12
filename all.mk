.PHONY: all clean
all:

# Build outside of the sources
BUILD_DIR = build

# Build tools
TOOLS_DIR = tools
include $(TOOLS_DIR)/toolchain.mk
#include $(TOOLS_DIR)/makedevs.mk

# Host compilation
SET_HOST_CC = $(if $(HOST_CC), CC=$(HOST_CC))

# Cross compilation
SET_CROSS_PATH = $(if $(CROSS_PATH), PATH="$(CROSS_PATH)/bin:$$PATH")
SET_CROSS_ARCH = $(if $(CROSS_ARCH), ARCH=$(CROSS_ARCH))
SET_CROSS_COMPILE = $(if $(CROSS_PREFIX), CROSS_COMPILE=$(CROSS_PREFIX))
SET_CROSS_CC = $(if $(CROSS_CC), CC=$(CROSS_CC))

# Linux
LINUX_DIR = linux
include $(LINUX_DIR)/linux.mk

# Busybox
BUSYBOX_DIR = busybox
include $(BUSYBOX_DIR)/busybox.mk

# Packages
PKG_DIR = packages
#include $(PKG_DIR)/packages.mk

# Root filesystem
ROOT_DIR = root
#include $(ROOT_DIR)/root.mk
