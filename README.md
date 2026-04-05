# tengu-caddy

Caddy web server with the Cloudflare DNS plugin built in. Pre-built binaries for macOS and Linux, plus .deb packages for servers.

## Features

- Caddy web server with automatic HTTPS
- Cloudflare DNS-01 ACME challenge support (not included in stock Caddy)
- Works behind Cloudflare proxy (orange cloud)
- Automatic certificate renewal

## Install

### Homebrew (macOS / Linux)

```bash
brew install tengu-apps/tap/tengu-caddy
```

### Debian/Ubuntu (.deb)

```bash
# ARM64 (e.g., Hetzner CAX)
curl -fsSLO https://github.com/tengu-apps/tengu-caddy/releases/latest/download/tengu-caddy_amd64.deb
sudo dpkg -i tengu-caddy_amd64.deb

# AMD64
curl -fsSLO https://github.com/tengu-apps/tengu-caddy/releases/latest/download/tengu-caddy_arm64.deb
sudo dpkg -i tengu-caddy_arm64.deb
```

### Binary download

Download standalone binaries from [Releases](https://github.com/tengu-apps/tengu-caddy/releases).

## Configuration

Edit `/etc/caddy/Caddyfile`:

```caddyfile
{
    email you@example.com
    acme_dns cloudflare {env.CF_API_TOKEN}
}

example.com {
    reverse_proxy localhost:8080
}
```

Add your Cloudflare API token to the systemd service:

```bash
sudo mkdir -p /etc/systemd/system/caddy.service.d
sudo tee /etc/systemd/system/caddy.service.d/cloudflare.conf << EOF
[Service]
Environment="CF_API_TOKEN=your-cloudflare-api-token"
EOF
sudo systemctl daemon-reload
sudo systemctl restart caddy
```

## Building

```bash
# Build for current architecture
make deb

# Build for specific architecture
make deb ARCH=arm64
make deb ARCH=amd64
```

## License

Caddy is licensed under Apache 2.0. This packaging is MIT.
