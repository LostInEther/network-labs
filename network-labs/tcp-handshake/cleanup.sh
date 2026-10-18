#!/bin/bash
# Removes the TCP handshake lab. Run with: sudo bash cleanup.sh
pkill -f "http.server 80" 2>/dev/null || true
for ns in client01 rtr01 web01; do ip netns del $ns 2>/dev/null || true; done
echo "lab removed"
