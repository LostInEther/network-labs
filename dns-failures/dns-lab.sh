#!/bin/bash
# DNS failures lab: client01 (198.51.100.10) -- rtr01 -- dns01 (203.0.113.53)
# Blog post: https://josephoshaughnessy.hashnode.dev/dns-failures-dig-tcpdump
# Run with: sudo bash dns-lab.sh
set -e
for ns in client01 rtr01 dns01; do ip netns del $ns 2>/dev/null || true; done
for ns in client01 rtr01 dns01; do
  ip netns add $ns
  ip netns exec $ns ip link set lo up
done

ip link add c0  type veth peer name r0
ip link add r1  type veth peer name d0
ip link set c0 netns client01
ip link set r0 netns rtr01
ip link set r1 netns rtr01
ip link set d0 netns dns01

ip netns exec client01 ip addr add 198.51.100.10/24 dev c0
ip netns exec rtr01    ip addr add 198.51.100.1/24  dev r0
ip netns exec rtr01    ip addr add 203.0.113.1/24   dev r1
ip netns exec dns01    ip addr add 203.0.113.53/24  dev d0

ip netns exec client01 ip link set c0 up
ip netns exec rtr01    ip link set r0 up
ip netns exec rtr01    ip link set r1 up
ip netns exec dns01    ip link set d0 up

ip netns exec client01 ip route add default via 198.51.100.1
ip netns exec dns01    ip route add default via 203.0.113.1
ip netns exec rtr01    sysctl -qw net.ipv4.ip_forward=1

# A small DNS server on dns01 answering for lab.example
mkdir -p /tmp/dns-lab
cat > /tmp/dns-lab/dnsmasq.conf <<'CONF'
no-resolv
no-hosts
listen-address=203.0.113.53
bind-interfaces
local=/lab.example/
host-record=www.lab.example,203.0.113.80
host-record=mail.lab.example,203.0.113.25
txt-record=big.lab.example,"v=spf1 ip4:192.0.2.0/24 ip4:198.51.100.0/24 ip4:203.0.113.0/24 include:spf.provider-one.example include:spf.provider-two.example ~all"
txt-record=big.lab.example,"google-site-verification=AbCdEfGhIjKlMnOpQrStUvWxYz0123456789AbCdEfGhIjKlMnOpQrStUvWxYz0123456789AbCdEfGhIjKlMnOpQrStUvWxYz0123456789AbCdEfGhIjKl"
txt-record=big.lab.example,"ms-domain-verification=AbCdEfGhIjKlMnOpQrStUvWxYz0123456789AbCdEfGhIjKlMnOpQrStUvWxYz0123456789AbCdEfGhIjKlMnOpQrStUvWxYz0123456789AbCdEfGhIjKl"
txt-record=big.lab.example,"atlassian-domain-verification=AbCdEfGhIjKlMnOpQrStUvWxYz0123456789AbCdEfGhIjKlMnOpQrStUvWxYz0123456789AbCdEfGhIjKlMnOpQrStUvWxYz0123456789AbCdEfGhIjKl"
txt-record=big.lab.example,"docusign=AbCdEfGhIjKlMnOpQrStUvWxYz0123456789AbCdEfGhIjKlMnOpQrStUvWxYz0123456789AbCdEfGhIjKlMnOpQrStUvWxYz0123456789AbCdEfGhIjKl"
txt-record=big.lab.example,"facebook-domain-verification=AbCdEfGhIjKlMnOpQrStUvWxYz0123456789AbCdEfGhIjKlMnOpQrStUvWxYz0123456789AbCdEfGhIjKlMnOpQrStUvWxYz0123456789AbCdEfGhIjKl"
txt-record=big.lab.example,"apple-domain-verification=AbCdEfGhIjKlMnOpQrStUvWxYz0123456789AbCdEfGhIjKlMnOpQrStUvWxYz0123456789AbCdEfGhIjKlMnOpQrStUvWxYz0123456789AbCdEfGhIjKl"
txt-record=big.lab.example,"adobe-idp-site-verification=AbCdEfGhIjKlMnOpQrStUvWxYz0123456789AbCdEfGhIjKlMnOpQrStUvWxYz0123456789AbCdEfGhIjKlMnOpQrStUvWxYz0123456789AbCdEfGhIjKl"
txt-record=big.lab.example,"zoom-domain-verification=AbCdEfGhIjKlMnOpQrStUvWxYz0123456789AbCdEfGhIjKlMnOpQrStUvWxYz0123456789AbCdEfGhIjKlMnOpQrStUvWxYz0123456789AbCdEfGhIjKl"
CONF
ip netns exec dns01 dnsmasq --conf-file=/tmp/dns-lab/dnsmasq.conf --pid-file=/tmp/dns-lab/dnsmasq.pid

# Point client01 at dns01 (ip netns exec uses /etc/netns/<name>/resolv.conf)
mkdir -p /etc/netns/client01
echo "nameserver 203.0.113.53" > /etc/netns/client01/resolv.conf

echo "lab up"
