all:

# Overwrite default configuration with user parameters
include config.mk

# Main targets
.PHONY: all clean
TARGETS ?= linux image
all: $(TARGETS)

# Host compilation
HOST_CC ?= gcc
SET_HOST_CC = $(if $(HOST_CC), CC=$(HOST_CC))

# Target compilation
TARGET_CPPFLAGS ?=
TARGET_CFLAGS ?= -Os
TARGET_CXXFLAGS ?= -Os
TARGET_LDFLAGS ?= -static
SET_CROSS_PATH = $(if $(CROSS_PATH), PATH="$$PATH:$(abspath $(CROSS_PATH))/bin")
SET_CROSS_ARCH = $(if $(CROSS_ARCH), ARCH=$(CROSS_ARCH))
SET_CROSS_COMPILE = $(if $(CROSS_PREFIX), CROSS_COMPILE=$(CROSS_PREFIX))
SET_CROSS_CC = $(if $(CROSS_CC), CC=$(CROSS_CC))
SET_CROSS_CXX = $(if $(CROSS_CXX), CXX=$(CROSS_CXX))
SET_CPPFLAGS = $(if $(TARGET_CPPFLAGS), CPPFLAGS='$(TARGET_CPPFLAGS)')
SET_CFLAGS = $(if $(TARGET_CFLAGS), CFLAGS='$(TARGET_CFLAGS)')
SET_CXXFLAGS = $(if $(TARGET_CXXFLAGS), CXXFLAGS='$(TARGET_CXXFLAGS)')
SET_LDFLAGS = $(if $(TARGET_LDFLAGS), LDFLAGS='$(TARGET_LDFLAGS)')
TARGET_STATIC = $(findstring -static, $(TARGET_LDFLAGS))
TARGET_LIB_DIRS += $(if $(CROSS_PATH), $(strip $(CROSS_PATH))/lib)
CONFIGURE_CROSS_HOST = $(if $(CROSS_PREFIX), --host=$(strip $(CROSS_PREFIX:-=)))
CROSS_PATH_PREFIX = $(if $(CROSS_PATH), $(strip $(CROSS_PATH))/bin/$(CROSS_PREFIX))
TARGET_STRIP = $(CROSS_PATH_PREFIX)strip -s

# Build outside of the sources
BUILD_DIR ?= build

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

# Add user-defined rules which can use variables previously defined
ifdef EXTRA_RULES
include $(EXTRA_RULES)
endif
