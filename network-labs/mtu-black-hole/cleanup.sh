#!/bin/bash
# Removes the MTU black hole lab. Run with: sudo bash cleanup.sh
pkill -f "http.server 80" 2>/dev/null || true
for ns in client01 rtr01 rtr02 web01; do ip netns del $ns 2>/dev/null || true; done
echo "lab removed"
