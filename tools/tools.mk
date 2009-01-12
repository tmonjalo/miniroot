.PHONY: tools tools_clean
all: tools

include $(TOOLS_DIR)/toolchain.mk
include $(TOOLS_DIR)/external_tools.mk
include $(TOOLS_DIR)/sstrip.mk
include $(TOOLS_DIR)/makedevs.mk
