# Main targets
TARGETS = linux image # built by "make" or "make all"

# Host compilation
HOST_CC = gcc

# Target compilation
CROSS_ARCH =
CROSS_PATH =  # toolchain will be built if undefined (optional)
CROSS_PREFIX =
CROSS_CC =  # (optional)
CROSS_CXX =  # (optional)
TARGET_CFLAGS = -Os
TARGET_CXXFLAGS = -Os
TARGET_LDFLAGS = -static

# Linux
LINUX_SRC = 2.6.29.1 # directory or tarball or VCS URL or version
LINUX_PATCH_DIR =  # (optional)
LINUX_CONFIG =

# Root filesystem
ROOT_DEV_TABLE = $(ROOT_DIR)/default_dev_table
ROOT_SKEL_DIR = $(ROOT_DIR)/default_skel

# Busybox
BUSYBOX_SRC = 1.13.3 # directory or tarball or VCS URL or version
BUSYBOX_PATCH_DIR =  # (optional)
BUSYBOX_CONFIG =  # (optional)

# Packages
PKG_DROPBEAR_SERVER = no
PKG_DROPBEAR_CLIENT = no
PKG_E2FSPROGS_MKFS = no
PKG_LIBROXML = no
