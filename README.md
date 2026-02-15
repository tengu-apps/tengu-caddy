# tengu-caddy

Pre-built Caddy .deb packages with Cloudflare DNS plugin for Tengu PaaS.

## Features

- Caddy web server with automatic HTTPS
- Cloudflare DNS-01 ACME challenge support
- Works behind Cloudflare proxy (orange cloud)
- Automatic certificate renewal

## Installation

Download from [Releases](https://github.com/saiden-dev/tengu-caddy/releases):

```bash
# ARM64 (e.g., Hetzner CAX)
wget https://github.com/saiden-dev/tengu-caddy/releases/latest/download/tengu-caddy_2.10.2-1_arm64.deb
sudo dpkg -i tengu-caddy_2.10.2-1_arm64.deb

# AMD64
wget https://github.com/saiden-dev/tengu-caddy/releases/latest/download/tengu-caddy_2.10.2-1_amd64.deb
sudo dpkg -i tengu-caddy_2.10.2-1_amd64.deb
```

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
