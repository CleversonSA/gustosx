#!/usr/bin/env python3
# -*- coding: utf-8 -*-

# ===================================================
#  Get Command and String from MSX emulated memory
#
#  Author: Cleverson SA
# ===================================================

import argparse
import glob
import os
import socket
import sys
import time
import re
from pathlib import Path
from typing import List

# -- Socket files 
DEFAULT_DIR = "/tmp/openmsx-umsxpi"
DEFAULT_PATTERN = "socket.*"

# -- OpenMSX MSX RAM memory mapper
CMD_ADDRS = "0xCF00"
PARAM_ADDRS = ["0xCF01", "0xCF02", "0xCF03", "0xCF04", "0xCF05", "0xCF06", "0xCF07", "0xCF08", "0xCF09", "0xCF0A", "0xCF0B", "0xCF0C", "0xCF0D", "0xCF0E", "0xCF0F"]


def find_latest_socket(dir_path: str, pattern: str) -> str:
    candidates = sorted(
        glob.glob(os.path.join(dir_path, pattern)),
        key=lambda p: os.path.getmtime(p),
        reverse=True,
    )
    if not candidates:
        raise FileNotFoundError(
            f"None socket found in {dir_path!r} with pattern {pattern!r}"
        )
    return candidates[0]

def wrap_command(cmd: str) -> str:
    s = cmd.strip()
    if not s.startswith("<command"):
        s = f"<command>{s}</command>"
    if not s.endswith("\n"):
        s += "\n"
    return s

RE_REPLY = re.compile(r"<reply\b[^>]*>(.*?)</reply>")
def read_until_reply(rfile, timeout: float) -> str:
    """Read lines until find <reply ...>...</reply> or timeout."""
    start = time.time()
    while True:
        line = rfile.readline()
        if not line:
            raise RuntimeError("Socket closed before response!")
        line = line.strip()
        
        m = RE_REPLY.search(line)
        if m:
            return m.group(1)  # content between <reply>...</reply>
        if time.time() - start > timeout:
            raise TimeoutError("Timeout waiting <reply ...> from OpenMSX.")

def send_peek(s: socket.socket, rfile, addr: str, timeout: float) -> int:
    """send peek command <addr> and return a integer value (0..255)."""
    cmd = wrap_command(f"peek {addr}")
    s.sendall(cmd.encode("utf-8"))
    raw = read_until_reply(rfile, timeout=timeout)
    try:
        val = int(raw, 0)
    except ValueError:
        m = re.search(r"(-?\d+)", raw)
        if not m:
            raise ValueError(f"Invalid peek response {addr!r}: {raw!r}")
        val = int(m.group(1), 10)
    return max(0, min(255, val))

def bytes_to_ascii_str(values: List[int]) -> str:
    """Convert byte array to ASCII printable strings."""
    chars = []
    for v in values:
        try:
            ch = chr(v)
            if 32 <= v <= 126 or v in (9, 10, 13):
                chars.append(ch)
            elif 0 == v:
                break
            else:
                chars.append('?')
        except ValueError:
            chars.append('?')
    return "".join(chars)

def main():
    ap = argparse.ArgumentParser(description="Read command and string from OpenMSX Emulated RAM.")
    ap.add_argument("--socket-path", help="Socket file path.")
    ap.add_argument("--dir", default=DEFAULT_DIR, help=f"Socket dir (default: {DEFAULT_DIR})")
    ap.add_argument("--pattern", default=DEFAULT_PATTERN, help=f"Socket pattern file (default: {DEFAULT_PATTERN})")
    ap.add_argument("--timeout", type=float, default=5.0, help="Timeout seconds (default: 5.0)")
    ap.add_argument("--debug", action="store_true", help="Verbose debug.")
    args = ap.parse_args()

    addrs = PARAM_ADDRS

    if args.socket_path:
        sock_path = args.socket_path
    else:
        sock_path = find_latest_socket(args.dir, args.pattern)

    if not Path(sock_path).exists():
        print(f"Error: socket file not found: {sock_path}", file=sys.stderr)
        sys.exit(2)


    try:
        with socket.socket(socket.AF_UNIX, socket.SOCK_STREAM) as s:
            s.settimeout(args.timeout)
            s.connect(sock_path)

            rfile = s.makefile("r", encoding="utf-8", newline="\n")

            banner = rfile.readline().strip()
            if args.debug:
                print(f"[recv] {banner}")

            ctrl_line = "<openmsx-control>\n"
            s.sendall(ctrl_line.encode("utf-8"))
            if args.debug:
                print(f"[sent] {ctrl_line.strip()}")


            cmd = send_peek(s, rfile, CMD_ADDRS, timeout=args.timeout)
            if args.debug:
                print(f"[peek (command)] -> {cmd} (0x{cmd:02X})")

            values = []
            for addr in addrs:
                val = send_peek(s, rfile, addr, timeout=args.timeout)
                values.append(val)
                if args.debug:
                    print(f"[peek {addr}] -> {val} (0x{val:02X})")

            result_str = bytes_to_ascii_str(values)

            print(f"0x{cmd:02X}\t{result_str}")

            s.close()

            
    except (socket.timeout, TimeoutError) as e:
        print(f"Timeout error: {e}", file=sys.stderr)
        sys.exit(3)
    except Exception as e:
        print(f"General error: {e}", file=sys.stderr)
        sys.exit(1)

if __name__ == "__main__":
    main()

