# Main target
TARGET = image # built by "make" or "make all"

# Host compilation
HOST_CC = gcc

# Cross compilation
CROSS_ARCH =
CROSS_PATH =  # toolchain will be built if undefined (optional)
CROSS_PREFIX =
#CROSS_CC = 'ccache $(CROSS_PATH)/bin/$(CROSS_PREFIX)gcc' # (optional)
CROSS_CFLAGS = -Os

# Linux
LINUX_SRC = 2.6.28 # directory or tarball or VCS URL or version
LINUX_PATCH_DIR =  # (optional)
LINUX_CONFIG =

# Busybox
BUSYBOX_SRC = 1.13.2 # directory or tarball or VCS URL or version
BUSYBOX_PATCH_DIR =  # (optional)
BUSYBOX_CONFIG =  # (optional)

# Packages
PKG_DROPBEAR = no

# Overwrite default configuration with user parameters
include config.mk

# All rules
include all.mk
