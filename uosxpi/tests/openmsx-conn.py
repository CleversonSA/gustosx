#!/usr/bin/env python3
# -*- coding: utf-8 -*-


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
DEFAULT_DIR = "/tmp/openmsx-pi"
DEFAULT_PATTERN = "socket.*"

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



def main():
    ap = argparse.ArgumentParser(description="Read command and string from OpenMSX Emulated RAM.")
    ap.add_argument("--socket-path", help="Socket file path.")
    ap.add_argument("--dir", default=DEFAULT_DIR, help=f"Socket dir (default: {DEFAULT_DIR})")
    ap.add_argument("--pattern", default=DEFAULT_PATTERN, help=f"Socket pattern file (default: {DEFAULT_PATTERN})")
    ap.add_argument("--timeout", type=float, default=5.0, help="Timeout seconds (default: 5.0)")
    ap.add_argument("--debug", action="store_true", help="Verbose debug.")
    args = ap.parse_args()


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

            print(f"Chamado")
            s.shutdown(socket.SHUT_RDWR)
            s.close()

            
    except (socket.timeout, TimeoutError) as e:
        print(f"Timeout error: {e}", file=sys.stderr)
        sys.exit(3)
    except Exception as e:
        print(f"General error: {e}", file=sys.stderr)
        sys.exit(1)

if __name__ == "__main__":
    main()

