# Default rule
all :

# Overwrite default configuration with user parameters
include config.mk

# Main targets
.PHONY : all clean
TARGETS ?= linux image
all : $(TARGETS)
	@ printf '\n'

# Host compilation
SET_HOST_CC = $(if $(HOST_CC), CC=$(HOST_CC))

# Target compilation
TARGET_CPPFLAGS ?=
TARGET_CFLAGS ?= -Os
TARGET_CXXFLAGS ?= -Os
TARGET_LDFLAGS ?= -static
SET_ARCH = $(if $(TARGET_ARCH), ARCH=$(TARGET_ARCH))
SET_CROSS_COMPILE = $(if $(TOOLCHAIN_PREFIX), CROSS_COMPILE=$(TOOLCHAIN_PREFIX))
SET_LINUX_CROSS_COMPILE = $(if $(LINUX_TOOLCHAIN_PREFIX), CROSS_COMPILE=$(LINUX_TOOLCHAIN_PREFIX))
SET_PATH = $(if $(TOOLCHAIN_PATH), PATH="$$PATH:$(abspath $(TOOLCHAIN_PATH))/bin")
SET_LINUX_PATH = $(if $(LINUX_TOOLCHAIN_PATH), PATH="$$PATH:$(abspath $(LINUX_TOOLCHAIN_PATH))/bin")
SET_CC = $(if $(TARGET_CC), CC=$(TARGET_CC))
SET_LINUX_CC = $(if $(LINUX_TARGET_CC), CC=$(LINUX_TARGET_CC))
SET_CXX = $(if $(TARGET_CXX), CXX=$(TARGET_CXX))
SET_CPPFLAGS = $(if $(TARGET_CPPFLAGS), CPPFLAGS='$(TARGET_CPPFLAGS)')
SET_CFLAGS = $(if $(TARGET_CFLAGS), CFLAGS='$(TARGET_CFLAGS)')
SET_CXXFLAGS = $(if $(TARGET_CXXFLAGS), CXXFLAGS='$(TARGET_CXXFLAGS)')
SET_LDFLAGS = $(if $(TARGET_LDFLAGS), LDFLAGS='$(TARGET_LDFLAGS)')
TARGET_STATIC = $(findstring -static, $(TARGET_LDFLAGS))
TARGET_LIB_DIRS += $(if $(TOOLCHAIN_PATH), $(strip $(TOOLCHAIN_PATH))/lib)
CONFIGURE_HOST = $(if $(TOOLCHAIN_PREFIX), --host=$(strip $(TOOLCHAIN_PREFIX:-=)))
TOOLCHAIN_PATH_PREFIX = $(if $(TOOLCHAIN_PATH), $(strip $(TOOLCHAIN_PATH))/bin/$(TOOLCHAIN_PREFIX))
TARGET_STRIP = $(TOOLCHAIN_PATH_PREFIX)strip -s

# Build outside of the sources
BUILD_DIR ?= build

# Build tools
include tools/tools.mk

# Linux
include linux/linux.mk

# Image
include image/image.mk

# Root filesystem
include root/root.mk

# Busybox
include busybox/busybox.mk

# Packages
include packages/packages.mk

# Add user-defined rules which can use variables previously defined
ifdef EXTRA_RULES
include $(EXTRA_RULES)
endif
