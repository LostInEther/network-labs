#!/bin/bash
# Removes the TCP data-phase lab. Run with: sudo bash cleanup.sh
pkill -f sender.py 2>/dev/null || true
for ns in client01 rtr01 srv01; do ip netns del $ns 2>/dev/null || true; done
echo "lab removed"
