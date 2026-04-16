#!/bin/bash
set -e

# Start terminal-server on port 32352
cd /app/dashboard/terminal-server
node bin/server.js &
TERMINAL_PID=$!

# Start nginx (proxies /terminal → 32352, rest → 8081)
nginx -g "daemon off;" &
NGINX_PID=$!

# Start Flask on port 8081
cd /app
EVONEXUS_PORT=8081 uv run python dashboard/backend/app.py &
FLASK_PID=$!

# Wait for any process to exit
wait -n $TERMINAL_PID $NGINX_PID $FLASK_PID
