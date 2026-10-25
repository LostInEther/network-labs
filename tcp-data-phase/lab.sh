#!/bin/bash
# TCP data-phase lab: client01 (198.51.100.10) -- rtr01 -- srv01 (203.0.113.10)
# Blog post: https://josephoshaughnessy.hashnode.dev/tcp-retransmissions-zero-window
# Run with: sudo bash lab.sh
set -e
for ns in client01 rtr01 srv01; do ip netns del $ns 2>/dev/null || true; done
for ns in client01 rtr01 srv01; do
  ip netns add $ns
  ip netns exec $ns ip link set lo up
done

ip link add c0 type veth peer name r0
ip link add r1 type veth peer name s0
ip link set c0 netns client01
ip link set r0 netns rtr01
ip link set r1 netns rtr01
ip link set s0 netns srv01

ip netns exec client01 ip addr add 198.51.100.10/24 dev c0
ip netns exec rtr01    ip addr add 198.51.100.1/24  dev r0
ip netns exec rtr01    ip addr add 203.0.113.1/24   dev r1
ip netns exec srv01    ip addr add 203.0.113.10/24  dev s0

ip netns exec client01 ip link set c0 up
ip netns exec rtr01    ip link set r0 up
ip netns exec rtr01    ip link set r1 up
ip netns exec srv01    ip link set s0 up

ip netns exec client01 ip route add default via 198.51.100.1
ip netns exec srv01    ip route add default via 203.0.113.1
ip netns exec rtr01    sysctl -qw net.ipv4.ip_forward=1

# Real packet sizes in captures (no segmentation offload)
for p in "client01 c0" "srv01 s0" "rtr01 r0" "rtr01 r1"; do
  set -- $p
  ip netns exec $1 ethtool -K $2 tso off gso off gro off >/dev/null 2>&1 || true
done

# Shape the router's link towards the client to 50 Mbit/s, like a WAN circuit
ip netns exec rtr01 tc qdisc add dev r0 root tbf rate 50mbit burst 64kb latency 100ms

echo "lab up"
