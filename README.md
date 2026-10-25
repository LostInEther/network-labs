# network-labs

Lab scripts from my networking blog, [josephoshaughnessy.hashnode.dev](https://josephoshaughnessy.hashnode.dev).

Every lab runs on a single Linux machine using network namespaces, so there are no VMs to build. Each namespace has its own interfaces, routes and firewall, so it behaves like a separate host. Ubuntu, Debian and WSL 2 all work.

## Requirements

```bash
sudo apt install -y iproute2 iptables tcpdump curl python3 ethtool iputils-ping iputils-tracepath dnsmasq-base dnsutils
```

On Windows, use WSL 2. WSL 1 doesn't support network namespaces, so check your version with `wsl -l -v` in PowerShell.

## Labs

| Lab | What it covers | Blog post |
| --- | --- | --- |
| [tcp-handshake](tcp-handshake/) | A three-node lab for breaking the TCP handshake three ways: closed port, silent drop and lost SYN-ACK | [Diagnosing a Failed TCP Handshake in Wireshark](https://josephoshaughnessy.hashnode.dev/tcp-handshake-wireshark) |
| [mtu-black-hole](mtu-black-hole/) | A four-node lab with a 1400-byte link in the middle, for reproducing and fixing a Path MTU Discovery black hole | [Finding an MTU Black Hole with ping, tcpdump and Wireshark](https://josephoshaughnessy.hashnode.dev/mtu-black-hole) |
| [tcp-data-phase](tcp-data-phase/) | A 50 Mbit/s link with a sender and receiver, for reading packet loss (dup ACKs, fast retransmits) and zero windows in Wireshark | [Diagnosing Slow TCP Transfers in Wireshark](https://josephoshaughnessy.hashnode.dev/tcp-retransmissions-zero-window) |
| [dns-failures](dns-failures/) | A client, a router and a dnsmasq server, for breaking DNS five ways: bad answers, silent drops, rejects, blocked TCP 53 and the wrong resolver | [Diagnosing DNS Failures with dig and tcpdump](https://josephoshaughnessy.hashnode.dev/dns-failures-dig-tcpdump) |

## Usage

```bash
cd tcp-handshake
sudo bash lab.sh       # build the lab
# ...follow the blog post...
sudo bash cleanup.sh   # remove it
```

The scripts use documentation address ranges (198.51.100.0/24, 203.0.113.0/24 and 192.0.2.0/24), so nothing clashes with a real network.

If you edit a script on Windows and Bash complains about `$'\r'`, the file has picked up Windows line endings. Fix it with `sed -i 's/\r$//' lab.sh`.
