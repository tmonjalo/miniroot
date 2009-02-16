SSTRIP_SRC = $(TOOLS_DIR)/sstrip.c
SSTRIP = $(TOOLS_BUILD_DIR)/sstrip

.PHONY: sstrip_clean
tools: $(SSTRIP)
tools_clean: sstrip_clean

$(SSTRIP): $(SSTRIP_SRC) | $(dir $(SSTRIP))
	$(HOST_CC) $< -o $@

sstrip_clean:
	- rm -rf $(SSTRIP_BUILD_DIR)
