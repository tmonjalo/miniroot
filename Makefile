# Default rule
all :

# User configuration
include config.mk

# Main targets
.PHONY : all clean
TARGETS ?= linux image
all : $(TARGETS)
	@ printf '\n'

# Build outside of the sources
BUILD_DIR ?= build

# Compiler flags
TARGET_CPPFLAGS ?=
TARGET_CFLAGS ?= -Os
TARGET_CXXFLAGS ?= -Os
TARGET_LDFLAGS ?= -static

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
