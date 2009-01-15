ROOT_SKEL_DIR = $(ROOT_DIR)/skel
ROOT_BUILD_DIR = $(BUILD_DIR)/$(ROOT_DIR)
ROOT_BUILD_LIB_DIR = $(ROOT_BUILD_DIR)/lib
ROOT_BUILD_BIN_DIRS += $(ROOT_BUILD_DIR)/bin $(ROOT_BUILD_DIR)/sbin

.PHONY: root root_lib_init root_lib root_bin_init root_bin root_skel root_dev_init root_dev root_clean
clean: root_clean

# scheduling rule
root: busybox packages root_lib root_bin root_skel root_dev

root_lib_init:
	@ echo '=== LIBRARIES ==='
root_lib: root_lib_init $(MKLIBS) $(SSTRIP)
	mkdir -p $(ROOT_BUILD_LIB_DIR)
	$(SET_CROSS_PATH) $(MKLIBS) \
		$(if $(CROSS_PREFIX), --target $(CROSS_PREFIX)) \
		-D $(foreach DIR, $(CROSS_LIB_DIRS), -L $(DIR)) \
		--dest-dir $(ROOT_BUILD_LIB_DIR) \
		$(foreach DIR, $(ROOT_BUILD_BIN_DIRS), $(DIR)/*)
	$(SSTRIP) $(ROOT_BUILD_LIB_DIR)/*

root_bin_init:
	@ echo '=== BINARIES ==='
root_bin: root_bin_init $(SSTRIP)
	$(foreach DIR, $(ROOT_BUILD_BIN_DIRS), $(SSTRIP) $(DIR)/* ;)

root_skel:
	@ echo '=== SKELETON ==='
	cp -a $(ROOT_SKEL_DIR)/* $(ROOT_BUILD_DIR)

root_dev_init:
	@ echo '=== DEVICES ==='
root_dev: root_dev_init $(MAKEDEVS)
	fakeroot sh -c "chown -R 0:0 $(ROOT_BUILD_DIR) ; ls -l $(ROOT_BUILD_DIR)/dev ; \
		$(MAKEDEVS) -d $(ROOT_DIR)/device_table.txt $(ROOT_BUILD_DIR) ; \
		ls -l $(ROOT_BUILD_DIR)/dev"

root_clean:
	- rm -rf $(ROOT_BUILD_DIR)
