# options can be set in config.mk
HOST_CC ?= gcc
#TARGET_ARCH =
#TOOLCHAIN_PATH =
#TOOLCHAIN_PREFIX =
#TARGET_CC =
#TARGET_CXX =

TOOLCHAIN_BUILD_DIR = $(BUILD_DIR)/$(TOOLCHAIN_PREFIX:-=)
TOOLCHAIN_CC = $(TOOLCHAIN_BUILD_DIR)/bin/$(TOOLCHAIN_PREFIX)cc

ifeq '$(TARGET_ARCH)' ''
ifneq '$(TOOLCHAIN_PATH)' ''
tools : $(TOOLCHAIN_CC)
TOOLCHAIN_PATH = $(TOOLCHAIN_BUILD_DIR)
endif
endif

$(TOOLCHAIN_CC) :
	@ printf '\n=== TOOLCHAIN ===\n'
	@ echo 'NOT YET IMPLEMENTED'
	@ echo 'should use crosstool-ng'
	@ false
