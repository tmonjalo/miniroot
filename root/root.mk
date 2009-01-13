ROOT_BUILD_DIR = $(BUILD_DIR)/$(ROOT_DIR)
ROOT_BUILD_LIB_DIR = $(ROOT_BUILD_DIR)/lib
ROOT_BUILD_BIN_DIRS += $(ROOT_BUILD_DIR)/bin $(ROOT_BUILD_DIR)/sbin

.PHONY: root root_update_libs
clean: root_clean

root: busybox root_update_libs

root_update_libs:
	mkdir -p $(ROOT_BUILD_LIB_DIR)
	$(SET_CROSS_PATH) $(MKLIBS) \
		$(if $(CROSS_PREFIX), --target $(CROSS_PREFIX)) \
		-D $(foreach DIR, $(BUILD_LIB_DIRS), -L $(DIR)) \
		--dest-dir $(ROOT_BUILD_LIB_DIR) \
		$(foreach DIR, $(ROOT_BUILD_BIN_DIRS), $(DIR)/*)
	$(SSTRIP) $(ROOT_BUILD_LIB_DIR)/*

root_clean:
	- rm -rf $(ROOT_BUILD_DIR)
