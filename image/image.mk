IMAGE_BUILD_DIR = $(BUILD_DIR)/$(IMAGE_DIR)
FAKEROOT_SCRIPT = $(IMAGE_BUILD_DIR)/fakeroot.sh
ROOT_CPIO = $(IMAGE_BUILD_DIR)/root.cpio
ROOT_CPIO_GZ = $(IMAGE_BUILD_DIR)/root.gz

.PHONY: image image_init image_clean
clean: image_clean

# scheduling rule
image_linux_initramfs: linux root $(ROOT_CPIO)
image_root_gz: root $(ROOT_CPIO_GZ)

image_init:
	@ echo '=== IMAGE ==='
	mkdir -p $(IMAGE_BUILD_DIR)

$(ROOT_CPIO): root_dev image_init
	echo 'cd $(ROOT_BUILD_DIR) && find | cpio --quiet --create --format=newc > $(abspath $@)' >> $(FAKEROOT_SCRIPT)
	fakeroot sh $(FAKEROOT_SCRIPT)

$(ROOT_CPIO_GZ): root_dev image_init
	echo 'cd $(ROOT_BUILD_DIR) && find | cpio --quiet --create --format=newc | gzip --best > $(abspath $@)' >> $(FAKEROOT_SCRIPT)
	fakeroot sh $(FAKEROOT_SCRIPT)

image_clean:
	- rm -rf $(IMAGE_BUILD_DIR)
