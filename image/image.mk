IMAGE_BUILD_DIR = $(BUILD_DIR)/$(IMAGE_DIR)

.PHONY: image image_clean
clean: image_clean

image: linux root

image_clean:
