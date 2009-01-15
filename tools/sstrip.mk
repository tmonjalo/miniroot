SSTRIP_SRC = $(TOOLS_DIR)/sstrip.c
SSTRIP_BUILD_DIR = $(BUILD_DIR)/sstrip
SSTRIP = $(SSTRIP_BUILD_DIR)/sstrip

.PHONY: sstrip_clean
tools: $(SSTRIP)
tools_clean: sstrip_clean

$(SSTRIP): $(SSTRIP_SRC) $(SSTRIP_BUILD_DIR)
	mkdir -p $(SSTRIP_BUILD_DIR)
	$(HOST_CC) $< -o $@

sstrip_clean:
	- rm -rf $(SSTRIP_BUILD_DIR)
