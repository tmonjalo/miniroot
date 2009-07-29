# options can be set in config.mk
ROOT_DEV_TABLE ?= $(ROOT_DIR)/default_dev_table # <file>
ROOT_SKEL_DIR ?= $(ROOT_DIR)/default_skel # [directory]
ROOT_SKEL_SRC ?= $(ROOT_SKEL_DIR) # [directory | tarball | VCS URL]

ROOT_DIR := $(patsubst %/,%,$(dir $(lastword $(MAKEFILE_LIST))))
ROOT_SKEL_SRC_DIR = $(shell $(TOOLS_DIR)/get_src_dir.sh '$(ROOT_DIR)' '$(ROOT_SKEL_SRC)' '$(ROOT_SKEL_DIR)')
ROOT_BUILD_DIR = $(BUILD_DIR)/$(ROOT_DIR)
ROOT_BUILD_LIB_DIR = $(ROOT_BUILD_DIR)/lib

FIND_ROOT_BINS_FILE = find $(ROOT_BUILD_DIR) -type f -perm +100 -exec file '{}' \;
FIND_ROOT_BINS = $(FIND_ROOT_BINS_FILE) | sed -n 's,^\(.*\):.*ELF.*executable.*,\1,p'
FIND_ROOT_BINS_NOT_STRIPPED = $(FIND_ROOT_BINS_FILE) | sed -n 's,^\(.*\):.*ELF.*executable.*not stripped.*,\1,p'

.PHONY : root root_clean \
	root_lib root_lib_init root_lib_so root_bin root_bin_init \
	root_skel root_skel_init root_dev root_dev_init root_clean
clean : root_clean

root : busybox packages root_lib root_bin root_skel

root_lib : $(if $(TARGET_STATIC), , root_lib_init root_lib_so)
root_lib_init :
	@ printf '\n=== LIBRARIES ===\n'
$(ROOT_BUILD_LIB_DIR) :
	mkdir -p $(ROOT_BUILD_LIB_DIR)
root_lib_so : $(MKLIBS) $(SSTRIP) | $(ROOT_BUILD_LIB_DIR)
	$(SET_PATH) $(MKLIBS) \
		$(if $(TOOLCHAIN_PREFIX), --target $(TOOLCHAIN_PREFIX)) \
		-D $(foreach DIR, $(TARGET_LIB_DIRS), -L $(DIR)) \
		--dest-dir $(ROOT_BUILD_LIB_DIR) \
		`$(FIND_ROOT_BINS)`
	find $(ROOT_BUILD_LIB_DIR) -type f | xargs -r $(SSTRIP) 2>/dev/null || true

root_bin_init :
	@ printf '\n=== BINARIES ===\n'
root_bin : root_bin_init $(SSTRIP)
	$(FIND_ROOT_BINS_NOT_STRIPPED) | xargs -r $(TARGET_STRIP)
	$(FIND_ROOT_BINS) | xargs -r $(SSTRIP)

root_skel_init :
	@ printf '\n=== SKELETON ===\n'
	@ $(TOOLS_DIR)/init_src.sh '$(ROOT_DIR)' '$(ROOT_SKEL_SRC)' '' '' '$(ROOT_SKEL_DIR)'
root_skel : root_skel_init
	tar --create --exclude-vcs --directory $(ROOT_SKEL_SRC_DIR) . | tar --extract --directory $(ROOT_BUILD_DIR)

root_dev_init :
	@ printf '\n=== DEVICES ===\n'
root_dev : root_dev_init $(MAKEDEVS) | $(dir $(FAKEROOT_SCRIPT))
	@ echo 'set -e' > $(FAKEROOT_SCRIPT)
	echo '$(MAKEDEVS) -d $(ROOT_DEV_TABLE) $(abspath $(ROOT_BUILD_DIR))' >> $(FAKEROOT_SCRIPT)

root_clean :
	- rm -rf $(ROOT_BUILD_DIR)
