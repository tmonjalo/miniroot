TOOLS_DIR := $(patsubst %/,%,$(dir $(lastword $(MAKEFILE_LIST))))
TOOLS_BUILD_DIR = $(BUILD_DIR)/$(TOOLS_DIR)

.PHONY: tools tools_clean
clean: tools_clean

$(TOOLS_BUILD_DIR):
	mkdir -p $(TOOLS_BUILD_DIR)

include $(TOOLS_DIR)/toolchain.mk
include $(TOOLS_DIR)/external_tools.mk
include $(TOOLS_DIR)/sstrip.mk
include $(TOOLS_DIR)/makedevs.mk
