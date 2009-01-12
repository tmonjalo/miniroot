TOOLCHAIN_BUILD_DIR = $(BUILD_DIR)/$(CROSS_PREFIX:-=)
TOOLCHAIN_CC = $(TOOLCHAIN_BUILD_DIR)/bin/$(CROSS_PREFIX)cc

ifeq ($(CROSS_PATH),)
ifneq ($(CROSS_PREFIX),)
all: $(TOOLCHAIN_CC)
endif
endif

$(TOOLCHAIN_CC):
	@ echo NOT YET IMPLEMENTED
	@ should use crosstool-ng
