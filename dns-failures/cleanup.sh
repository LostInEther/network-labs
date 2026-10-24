#!/bin/bash
# Removes the DNS failures lab. Run with: sudo bash cleanup.sh
[ -f /tmp/dns-lab/dnsmasq.pid ] && kill "$(cat /tmp/dns-lab/dnsmasq.pid)" 2>/dev/null
for ns in client01 rtr01 dns01; do ip netns del $ns 2>/dev/null || true; done
rm -rf /etc/netns/client01 /tmp/dns-lab
echo "lab removed"
