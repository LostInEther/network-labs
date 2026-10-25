#!/usr/bin/env python3
"""Runs on srv01. Waits for a connection on port 5000 and sends data as fast as it can."""
import socket, sys
size_mb = int(sys.argv[1]) if len(sys.argv) > 1 else 20
s = socket.socket(); s.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
s.bind(("0.0.0.0", 5000)); s.listen(1)
print(f"sender: waiting on port 5000, will send {size_mb} MB", flush=True)
conn, addr = s.accept()
chunk = b"x" * 65536
for _ in range(size_mb * 16):
    conn.sendall(chunk)
conn.close(); print("sender: done", flush=True)
