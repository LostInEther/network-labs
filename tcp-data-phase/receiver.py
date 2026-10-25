#!/usr/bin/env python3
"""Runs on client01. Connects to srv01:5000 and reads the data.
   --stall N    connect, read nothing for N seconds, then read normally (causes a zero window)"""
import socket, sys, time
stall = 0
if "--stall" in sys.argv: stall = float(sys.argv[sys.argv.index("--stall") + 1])
s = socket.socket()
if stall: s.setsockopt(socket.SOL_SOCKET, socket.SO_RCVBUF, 32768)   # small buffer so it fills quickly
s.connect(("203.0.113.10", 5000))
start = time.time()
if stall:
    print(f"receiver: connected, not reading for {stall:.0f}s", flush=True); time.sleep(stall)
total = 0
while True:
    data = s.recv(65536)
    if not data: break
    total += len(data)
secs = time.time() - start
print(f"receiver: {total/1e6:.1f} MB in {secs:.2f}s = {total*8/secs/1e6:.0f} Mbit/s", flush=True)
