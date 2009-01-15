IMAGE_BUILD_DIR = $(BUILD_DIR)/$(IMAGE_DIR)
FAKEROOT_SCRIPT = $(IMAGE_BUILD_DIR)/fakeroot.sh
ROOT_IMAGE = $(IMAGE_BUILD_DIR)/root.gz

.PHONY: image image_clean
clean: image_clean

# scheduling rule
image: linux root $(ROOT_IMAGE)

$(IMAGE_BUILD_DIR):
	mkdir -p $(IMAGE_BUILD_DIR)

$(ROOT_IMAGE):
	echo 'cd $(ROOT_BUILD_DIR) && find | cpio --quiet --create --format=newc | gzip --best > $(ROOT_IMAGE)' >> $(FAKEROOT_SCRIPT)
	fakeroot sh $(FAKEROOT_SCRIPT)

image_clean:
	- rm -rf $(IMAGE_BUILD_DIR)
