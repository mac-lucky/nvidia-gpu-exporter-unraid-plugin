# Makefile for NVIDIA GPU Exporter Unraid Plugin

PLUGIN_NAME = nvidia_gpu_exporter
AUTHOR = utkuozdemir

# Automatically get the latest version from GitHub releases
LATEST_RELEASE_URL = https://api.github.com/repos/$(AUTHOR)/$(PLUGIN_NAME)/releases/latest
VERSION := $(shell curl -s $(LATEST_RELEASE_URL) | grep '"tag_name":' | sed -E 's/.*"v([^"]+)".*/\1/')

.PHONY: all clean plugin check-deps package install validate version

all: plugin

# Show the detected version
version:
	@echo "Latest version detected: $(VERSION)"

# Validate the plugin XML structure
validate:
	@echo "Validating plugin..."
	@./validate_plugin.sh

# Check if required tools are installed
check-deps:
	@command -v wget >/dev/null 2>&1 || { echo "wget is required but not installed." >&2; exit 1; }
	@command -v tar >/dev/null 2>&1 || { echo "tar is required but not installed." >&2; exit 1; }
	@command -v curl >/dev/null 2>&1 || { echo "curl is required but not installed." >&2; exit 1; }

# Download the binary release and calculate MD5
plugin: check-deps
	@echo "Creating Unraid plugin package..."
	@echo "Using latest version: $(VERSION)"
	@mkdir -p build
	
	# Download the release if not present
	@if [ ! -f "build/$(PLUGIN_NAME)_$(VERSION)_linux_x86_64.tar.gz" ]; then \
		echo "Downloading $(PLUGIN_NAME) v$(VERSION)..."; \
		wget -O "build/$(PLUGIN_NAME)_$(VERSION)_linux_x86_64.tar.gz" \
			"https://github.com/$(AUTHOR)/$(PLUGIN_NAME)/releases/download/v$(VERSION)/$(PLUGIN_NAME)_$(VERSION)_linux_x86_64.tar.gz"; \
	fi
	
	# Calculate MD5 sum
	@MD5=$$(md5sum "build/$(PLUGIN_NAME)_$(VERSION)_linux_x86_64.tar.gz" | cut -d' ' -f1); \
	echo "MD5 checksum: $$MD5"; \
	sed -i.bak "s/PLACEHOLDER_MD5/$$MD5/g" "$(PLUGIN_NAME).plg"; \
	sed -i.bak "s/PLACEHOLDER_VERSION/$(VERSION)/g" "$(PLUGIN_NAME).plg"
	
	@echo "Plugin ready: $(PLUGIN_NAME).plg"
	@echo "Validating plugin..."
	@./validate_plugin.sh

# Package the plugin for distribution
package: plugin
	@echo "Creating plugin package..."
	@mkdir -p dist
	@tar -czf "dist/$(PLUGIN_NAME)-$(VERSION)-unraid-plugin.tar.gz" \
		$(PLUGIN_NAME).plg \
		usr/ \
		README.md
	@echo "Plugin package created: dist/$(PLUGIN_NAME)-$(VERSION)-unraid-plugin.tar.gz"

# Clean build artifacts
clean:
	@echo "Cleaning build artifacts..."
	@rm -rf build/
	@rm -rf dist/
	@rm -f $(PLUGIN_NAME).plg.bak
	@# Reset MD5 and version placeholders
	@sed -i.bak "s/[a-f0-9]\{32\}/PLACEHOLDER_MD5/g" "$(PLUGIN_NAME).plg" && rm -f "$(PLUGIN_NAME).plg.bak"
	@sed -i.bak 's/<!ENTITY version   "[^"]*">/<!ENTITY version   "PLACEHOLDER_VERSION">/' "$(PLUGIN_NAME).plg" && rm -f "$(PLUGIN_NAME).plg.bak"

# Install to a local Unraid server (for testing)
# Usage: make install UNRAID_HOST=192.168.1.100
install: plugin
	@if [ -z "$(UNRAID_HOST)" ]; then \
		echo "Please specify UNRAID_HOST: make install UNRAID_HOST=192.168.1.100"; \
		exit 1; \
	fi
	@echo "Installing to Unraid server at $(UNRAID_HOST)..."
	@scp $(PLUGIN_NAME).plg root@$(UNRAID_HOST):/tmp/
	@ssh root@$(UNRAID_HOST) "installpkg /tmp/$(PLUGIN_NAME).plg"

# Show help
help:
	@echo "Available targets:"
	@echo "  plugin   - Create the plugin file with correct MD5 checksum and latest version"
	@echo "  version  - Show the latest version detected from GitHub"
	@echo "  validate - Validate the plugin XML structure"
	@echo "  package  - Create a distributable plugin package"
	@echo "  install  - Install to remote Unraid server (set UNRAID_HOST)"
	@echo "  clean    - Clean build artifacts and reset placeholders"
	@echo "  help     - Show this help message"
