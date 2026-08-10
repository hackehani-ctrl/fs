# Ubuntu VNC/noVNC Docker image

This repository contains a Dockerfile that builds an Ubuntu 22.04 image with XFCE, TigerVNC and noVNC (websockify).

Included files
- Dockerfile: builds the image and installs required packages
- entrypoint.sh: initializes VNC password from VNC_PASS env and starts vncserver + websockify
- docker-compose.yml: example compose file including a Caddy reverse-proxy for TLS
- Caddyfile: simple reverse proxy configuration (replace your.domain.example)

Quick start
1) Build the image:
   docker compose build

2) Set a strong VNC password and start:
   VNC_PASS="your_secure_password" docker compose up -d

3) Point your domain to the host running the containers and update Caddyfile with your domain.
   Caddy will obtain TLS certs automatically.

Important security notes
- The VNC raw port 5901 is bound to localhost only in docker-compose. Do NOT expose 5901 publicly.
- noVNC (6080) is proxied via Caddy which provides TLS. Make sure to use a domain with valid DNS.
- The entrypoint uses VncAuth if VNC_PASS is provided; otherwise it falls back to insecure mode.

If you want, I can:
- Switch the Dockerfile to generate the VNC password at build time (less secure), or keep it runtime via env (safer).
- Add supervisor to manage processes instead of the entrypoint script.
- Create a PR with these files on a feature branch instead of pushing to main.
