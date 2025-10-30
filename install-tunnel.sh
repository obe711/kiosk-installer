#!/bin/sh

docker run -d --restart unless-stopped --name nexus_tunnel cloudflare/cloudflared:latest tunnel --no-autoupdate run --token \
  "$1"