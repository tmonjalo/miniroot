MAKEDEVS_SRC = $(TOOLS_DIR)/makedevs.c
MAKEDEVS_BUILD_DIR = $(BUILD_DIR)/makedevs
MAKEDEVS = $(MAKEDEVS_BUILD_DIR)/makedevs

.PHONY: makedevs_clean
tools: $(MAKEDEVS)
tools_clean: makedevs_clean

$(MAKEDEVS): $(MAKEDEVS_SRC) $(MAKEDEVS_BUILD_DIR)
	mkdir -p $(MAKEDEVS_BUILD_DIR)
	$(HOST_CC) -Wall -Werror -O2 $< -o $@

makedevs_clean:
	- rm -rf $(MAKEDEVS_BUILD_DIR)
