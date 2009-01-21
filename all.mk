.PHONY: all init finish clean
all: init $(TARGETS) finish
# User-defined targets (init and finish can be defined in config.mk)
init:
finish:

# Host compilation
SET_HOST_CC = $(if $(HOST_CC), CC=$(HOST_CC))

# Cross compilation
SET_CROSS_PATH = $(if $(CROSS_PATH), PATH="$(abspath $(CROSS_PATH))/bin:$$PATH")
SET_CROSS_ARCH = $(if $(CROSS_ARCH), ARCH=$(CROSS_ARCH))
SET_CROSS_COMPILE = $(if $(CROSS_PREFIX), CROSS_COMPILE=$(CROSS_PREFIX))
SET_CROSS_CC = $(if $(CROSS_CC), CC=$(CROSS_CC))
CROSS_LIB_DIRS += $(CROSS_PATH)/lib
CROSS_PATH_PREFIX = $(if $(CROSS_PATH), $(CROSS_PATH)/bin/$(CROSS_PREFIX))
CROSS_STRIP = $(CROSS_PATH_PREFIX)strip -s
CONFIGURE_CROSS_HOST = $(if $(CROSS_PREFIX), --host=$(strip $(CROSS_PREFIX:-=)))

# Build outside of the sources
BUILD_DIR = build

# Build tools
TOOLS_DIR = tools
include $(TOOLS_DIR)/tools.mk

# Linux
LINUX_DIR = linux
include $(LINUX_DIR)/linux.mk

# Image
IMAGE_DIR = image
include $(IMAGE_DIR)/image.mk

# Root filesystem
ROOT_DIR = root
include $(ROOT_DIR)/root.mk

# Busybox
BUSYBOX_DIR = busybox
include $(BUSYBOX_DIR)/busybox.mk

# Packages
PKG_DIR = packages
include $(PKG_DIR)/packages.mk
