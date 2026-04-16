#!/bin/sh
set -e

# Fix nginx pid file permissions
mkdir -p /run/nginx

# Start terminal-server on port 32352 (background)
cd /app/dashboard/terminal-server
node bin/server.js &

# Start nginx (background, proxies /terminal→32352 and rest→8081)
nginx

# Start Flask on port 8081 (foreground — keeps container alive)
cd /app
exec uv run python dashboard/backend/app.py
