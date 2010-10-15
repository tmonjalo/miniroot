# macro to check if *_SRC exists locally (archive or directory) or is an URL
define IS_SRC
$(findstring ://, $1 $(shell [ -e '$(strip $1)' ] && echo ://))
endef

# macro to set environment variable to a non empty value
define SET_ENV
$(if $($(strip $2)), $(strip $1)='$(strip $($(strip $2)))')
endef

# host compilation
HOST_ARCH ?= $(shell $(HOST_CC) -dumpmachine 2>&- || uname -m)
HOST_BUILD_DIR = $(strip $(BUILD_DIR))/host
SET_HOST_CC = $(call SET_ENV, CC, HOST_CC)

# target compilation
TARGET_NAME ?= $(if $(TOOLCHAIN_PREFIX), $(TOOLCHAIN_PREFIX:-=), $(HOST_ARCH))
TARGET_BUILD_DIR = $(strip $(BUILD_DIR))/$(strip $(TARGET_NAME))
SET_PATH = $(if $(TOOLCHAIN_PATH), PATH="$(abspath $(TOOLCHAIN_PATH))/bin:$$PATH")
SET_ARCH = $(call SET_ENV, ARCH, TARGET_ARCH)
SET_CROSS_COMPILE = $(call SET_ENV, CROSS_COMPILE, TOOLCHAIN_PREFIX)
SET_CC = $(call SET_ENV, CC, TARGET_CC)
SET_CXX = $(call SET_ENV, CXX, TARGET_CXX)
SET_CPPFLAGS = $(call SET_ENV, CPPFLAGS, TARGET_CPPFLAGS)
SET_EXTRA_CPPFLAGS = $(call SET_ENV, EXTRA_CPPFLAGS, TARGET_CPPFLAGS)
SET_CFLAGS = $(call SET_ENV, CFLAGS, TARGET_CFLAGS)
SET_EXTRA_CFLAGS = $(call SET_ENV, EXTRA_CFLAGS, TARGET_CFLAGS)
SET_CXXFLAGS = $(call SET_ENV, CXXFLAGS, TARGET_CXXFLAGS)
SET_EXTRA_CXXFLAGS = $(call SET_ENV, EXTRA_CXXFLAGS, TARGET_CXXFLAGS)
SET_LDFLAGS = $(call SET_ENV, LDFLAGS, TARGET_LDFLAGS)
SET_EXTRA_LDFLAGS = $(call SET_ENV, EXTRA_LDFLAGS, TARGET_LDFLAGS)
TARGET_STATIC = $(findstring -static, $(TARGET_LDFLAGS))
TARGET_STRIP = $(strip $(TOOLCHAIN_PATH_PREFIX))strip -s
CONFIGURE_HOST = $(if $(TOOLCHAIN_PREFIX), --host=$(strip $(TOOLCHAIN_PREFIX:-=)))
