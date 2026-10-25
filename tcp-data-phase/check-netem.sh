#!/bin/bash
# Checks whether this kernel can add latency with netem. Run with: sudo bash check-netem.sh
ip netns add netem-test
if ip netns exec netem-test tc qdisc add dev lo root netem delay 10ms 2>/dev/null; then
  echo "netem available: you can add latency to the lab"
else
  echo "netem not available on this kernel: the latency step won't work here"
fi
ip netns del netem-test
