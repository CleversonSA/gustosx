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
PARAM_ADDRS = ["0xCF01", "0xCF02", "0xCF03", "0xCF04", "0xCF05", "0xCF06", "0xCF07", "0xCF08", "0xCF09", "0xCF0A", "0xCF0B", "0xCF0C", "0xCF0D", "0xCF0E", "0xCF0F", "0xCF10", "0xCF11", "0xCF12", "0xCF13", "0xCF14", "0xCF15", "0xCF16", "0xCF18", "0xCF19","0xCF1A","0xCF1B", "0xCF1C", "0xCF1D", "0xCF1E", "0xCF1F", "0xCF20", "0xCF21", "0xCF22", "0xCF23", "0xCF24", "0xCF25", "0xCF26", "0xCF27", "0xCF28", "0xCF29", "0xCF2A", "0xCF2B", "0xCF2C", "0xCF2D", "0xCF2E", "0xCF2F", "0xCF30", "0xCF31", "0xCF32", "0xCF33", "0xCF34", "0xCF35", "0xCF36", "0xCF37", "0xCF38", "0xCF39", "0xCF3A", "0xCF3B", "0xCF3C", "0xCF3D", "0xCF3E", "0xCF3F"]


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


def main():
    ap = argparse.ArgumentParser(description="Set a command and string to OpenMSX Emulated RAM.")
    ap.add_argument("--socket-path", help="Socket file path.")
    ap.add_argument("--dir", default=DEFAULT_DIR, help=f"Socket dir (default: {DEFAULT_DIR})")
    ap.add_argument("--pattern", default=DEFAULT_PATTERN, help=f"Socket pattern file (default: {DEFAULT_PATTERN})")
    ap.add_argument("--timeout", type=float, default=5.0, help="Timeout seconds (default: 5.0)")
    ap.add_argument("--command", default="0xF0", help="Byte command to send to RAM (default: 0xF0)")
    ap.add_argument("--message", help="String message to be stored in RAM. If this parameter is ommited, the string area will be filled with a zero")
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


            cmd = wrap_command(f"poke {CMD_ADDRS} {args.command}")
            s.sendall(cmd.encode("utf-8"))
            if args.debug:
                print(f"[sent] (command)] -> {cmd}")

            if args.message:
                last_pos = 0
                for i in range(len(args.message)):
                    byte_str = args.message[i:i+1]

                    cmd = wrap_command(f"poke {addrs[i]} {ord(byte_str)}")
                    s.sendall(cmd.encode("utf-8"))
                    if args.debug:
                        print(f"[poke {addrs[i]} -> {byte_str} {ord(byte_str)}")

                    last_pos = last_pos + 1
                 
                cmd = wrap_command(f"poke {addrs[last_pos]} 0")
                s.sendall(cmd.encode("utf-8"))
                if args.debug:
                    print(f"[poke {addrs[last_pos]} -> 0")
           
            else:
                cmd = wrap_command(f"poke {addrs[0]} 0")
                s.sendall(cmd.encode("utf-8"))
                if args.debug:
                    print(f"[poke {addrs[0]} -> 0")
            

            s.close()

            
    except (socket.timeout, TimeoutError) as e:
        print(f"Timeout error: {e}", file=sys.stderr)
        sys.exit(3)
    except Exception as e:
        print(f"General error: {e}", file=sys.stderr)
        sys.exit(1)

if __name__ == "__main__":
    main()

