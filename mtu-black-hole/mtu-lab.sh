#!/bin/bash
# MTU black hole lab: client01 -- rtr01 ==(1400 MTU link)== rtr02 -- web01
# Blog post: https://josephoshaughnessy.hashnode.dev/mtu-black-hole
# Run with: sudo bash mtu-lab.sh
set -e
for ns in client01 rtr01 rtr02 web01; do ip netns del $ns 2>/dev/null || true; done
for ns in client01 rtr01 rtr02 web01; do
  ip netns add $ns
  ip netns exec $ns ip link set lo up
done

ip link add c0  type veth peer name r1a
ip link add r1b type veth peer name r2a
ip link add r2b type veth peer name w0
ip link set c0  netns client01
ip link set r1a netns rtr01
ip link set r1b netns rtr01
ip link set r2a netns rtr02
ip link set r2b netns rtr02
ip link set w0  netns web01

ip netns exec client01 ip addr add 198.51.100.10/24 dev c0
ip netns exec rtr01    ip addr add 198.51.100.1/24  dev r1a
ip netns exec rtr01    ip addr add 192.0.2.1/30     dev r1b
ip netns exec rtr02    ip addr add 192.0.2.2/30     dev r2a
ip netns exec rtr02    ip addr add 203.0.113.1/24   dev r2b
ip netns exec web01    ip addr add 203.0.113.10/24  dev w0

# The narrow link in the middle of the path
ip netns exec rtr01 ip link set r1b mtu 1400
ip netns exec rtr02 ip link set r2a mtu 1400

ip netns exec client01 ip link set c0  up
ip netns exec rtr01    ip link set r1a up
ip netns exec rtr01    ip link set r1b up
ip netns exec rtr02    ip link set r2a up
ip netns exec rtr02    ip link set r2b up
ip netns exec web01    ip link set w0  up

ip netns exec client01 ip route add default via 198.51.100.1
ip netns exec web01    ip route add default via 203.0.113.1
ip netns exec rtr01    ip route add 203.0.113.0/24 via 192.0.2.2
ip netns exec rtr02    ip route add 198.51.100.0/24 via 192.0.2.1
ip netns exec rtr01    sysctl -qw net.ipv4.ip_forward=1
ip netns exec rtr02    sysctl -qw net.ipv4.ip_forward=1

echo "lab up"
