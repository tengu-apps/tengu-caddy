VERSION := 2.11.2
REVISION := 3
CADDY_PLUGINS := github.com/caddy-dns/cloudflare@v0.2.4

ARCH := $(shell dpkg --print-architecture 2>/dev/null || uname -m | sed 's/x86_64/amd64/' | sed 's/aarch64/arm64/')
OS := linux
PACKAGE_NAME := tengu-caddy
DEB_NAME := $(PACKAGE_NAME)_$(VERSION)-$(REVISION)_$(ARCH).deb

BUILD_DIR := build
STAGING_DIR := $(BUILD_DIR)/staging

.PHONY: all clean build deb install

all: deb

clean:
	rm -rf $(BUILD_DIR)

# Download pre-built Caddy with plugins from official API
$(BUILD_DIR)/caddy:
	@mkdir -p $(BUILD_DIR)
	@echo "Downloading Caddy $(VERSION) for $(OS)/$(ARCH) with plugins..."
	curl -sL "https://caddyserver.com/api/download?os=$(OS)&arch=$(ARCH)&p=$(CADDY_PLUGINS)" -o $@
	chmod +x $@
	@echo "Verifying binary..."
	@file $@

build: $(BUILD_DIR)/caddy

# Build .deb package
deb: $(BUILD_DIR)/caddy
	@echo "Building .deb package..."
	@mkdir -p $(STAGING_DIR)/DEBIAN
	@mkdir -p $(STAGING_DIR)/usr/bin
	@mkdir -p $(STAGING_DIR)/usr/lib/systemd/system
	@mkdir -p $(STAGING_DIR)/etc/caddy

	@# Binary
	cp $(BUILD_DIR)/caddy $(STAGING_DIR)/usr/bin/caddy

	@# Systemd service
	cp debian/caddy.service $(STAGING_DIR)/usr/lib/systemd/system/

	@# Default Caddyfile
	cp debian/Caddyfile $(STAGING_DIR)/etc/caddy/

	@# Control file
	sed 's/{{VERSION}}/$(VERSION)-$(REVISION)/g; s/{{ARCH}}/$(ARCH)/g' debian/control > $(STAGING_DIR)/DEBIAN/control

	@# Scripts
	cp debian/postinst $(STAGING_DIR)/DEBIAN/
	cp debian/prerm $(STAGING_DIR)/DEBIAN/
	cp debian/postrm $(STAGING_DIR)/DEBIAN/
	chmod 755 $(STAGING_DIR)/DEBIAN/postinst $(STAGING_DIR)/DEBIAN/prerm $(STAGING_DIR)/DEBIAN/postrm

	@# Conffiles
	cp debian/conffiles $(STAGING_DIR)/DEBIAN/

	@# Build package
	dpkg-deb --build $(STAGING_DIR) $(BUILD_DIR)/$(DEB_NAME)
	@echo "Built: $(BUILD_DIR)/$(DEB_NAME)"

install: deb
	sudo dpkg -i $(BUILD_DIR)/$(DEB_NAME)
