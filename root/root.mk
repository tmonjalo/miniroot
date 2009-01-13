ROOT_BUILD_DIR = $(BUILD_DIR)/$(ROOT_DIR)
ROOT_BUILD_LIB_DIR = $(ROOT_BUILD_DIR)/lib
ROOT_BUILD_BIN_DIRS += $(ROOT_BUILD_DIR)/bin $(ROOT_BUILD_DIR)/sbin

.PHONY: root root_update_libs
clean: root_clean

root: busybox packages root_libs

root_libs:
	@ echo '=== LIBRARIES ==='
	mkdir -p $(ROOT_BUILD_LIB_DIR)
	$(SET_CROSS_PATH) $(MKLIBS) \
		$(if $(CROSS_PREFIX), --target $(CROSS_PREFIX)) \
		-D $(foreach DIR, $(CROSS_LIB_DIRS), -L $(DIR)) \
		--dest-dir $(ROOT_BUILD_LIB_DIR) \
		$(foreach DIR, $(ROOT_BUILD_BIN_DIRS), $(DIR)/*)
	$(SSTRIP) $(ROOT_BUILD_LIB_DIR)/*

root_clean:
	- rm -rf $(ROOT_BUILD_DIR)
