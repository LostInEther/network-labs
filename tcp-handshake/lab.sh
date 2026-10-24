#!/bin/bash
# TCP handshake lab: client01 (198.51.100.10) -- rtr01 -- web01 (203.0.113.10)
# Blog post: https://josephoshaughnessy.hashnode.dev/tcp-handshake-wireshark
# Run with: sudo bash lab.sh
set -e
for ns in client01 rtr01 web01; do ip netns del $ns 2>/dev/null || true; done
for ns in client01 rtr01 web01; do
  ip netns add $ns
  ip netns exec $ns ip link set lo up
done

ip link add c-eth0 type veth peer name r-eth0
ip link add r-eth1 type veth peer name w-eth0
ip link set c-eth0 netns client01
ip link set r-eth0 netns rtr01
ip link set r-eth1 netns rtr01
ip link set w-eth0 netns web01

ip netns exec client01 ip link set c-eth0 name eth0
ip netns exec rtr01    ip link set r-eth0 name eth0
ip netns exec rtr01    ip link set r-eth1 name eth1
ip netns exec web01    ip link set w-eth0 name eth0

ip netns exec client01 ip addr add 198.51.100.10/24 dev eth0
ip netns exec rtr01    ip addr add 198.51.100.1/24  dev eth0
ip netns exec rtr01    ip addr add 203.0.113.1/24   dev eth1
ip netns exec web01    ip addr add 203.0.113.10/24  dev eth0

ip netns exec client01 ip link set eth0 up
ip netns exec rtr01    ip link set eth0 up
ip netns exec rtr01    ip link set eth1 up
ip netns exec web01    ip link set eth0 up

ip netns exec client01 ip route add default via 198.51.100.1
ip netns exec web01    ip route add default via 203.0.113.1
ip netns exec rtr01    sysctl -qw net.ipv4.ip_forward=1

echo "lab up"
