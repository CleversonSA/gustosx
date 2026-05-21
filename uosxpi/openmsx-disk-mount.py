#!/usr/bin/env python3
# -*- coding: utf-8 -*-

# ===================================================
#  Mounts a disk drive with the path or DSK file given
#  from CLI
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
    ap = argparse.ArgumentParser(description="Mounts a disk drive with the path or DSK file given from CLI")
    ap.add_argument("--disk-path", help="Full path filename of the DSK or virtual path to be mounted")
    ap.add_argument("--drive", default="a", help="Floppy drive to be assigned (a or b). Default 'a'")
    ap.add_argument("--check-mounted-storage", help="Check if a drive(diska, hda) is already mounted.")
    ap.add_argument("--with-storage", help="Only use with --check-mounted-storage, validate if the existing mounted path is the same of this parameter, to avoid conflict.")
    ap.add_argument("--get-storage-info", action="store_true", help="Only use with --check-mounted-storage, get the storage raw info")
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

    if args.disk_path and not (Path(args.disk_path).exists()):
        print(f"Error: Invalid DSK file or path: {args.disk_path}", file=sys.stderr)
        sys.exit(2)

    
    if args.check_mounted_storage:
        mounted_storage = args.check_mounted_storage

        if mounted_storage and not ((mounted_storage == "diska") or (mounted_storage == "hda")):
            print(f"Error: Invalid storage device: {mounted_storage}", file=sys.stderr)
            sys.exit(2)


    disk_drive=args.drive.lower()
    if not (disk_drive == "a") and not ( disk_drive== "b"):
        print(f"Error: Invalid drive letter: {disk_drive}", file=sys.stderr)
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

            if args.check_mounted_storage:
                cmd = wrap_command(f"{args.check_mounted_storage}")
                s.sendall(cmd.encode("utf8"))
       
                raw = read_until_reply(rfile, timeout=args.timeout)
                try:
                    if "empty" in raw:
                        print ("false")
                    elif args.with_storage and not ( args.with_storage in raw ):
                        print ("false")
                    else:
                        if args.get_storage_info:
                            print(raw)
                        else:
                            print ("true")

                except ValueError:
                    m = re.search(r"(-?\d+)", raw)
                    if not m:
                        raise ValueError(f"Invalid response: {raw}")

            else:
           
                cmd = wrap_command(f"disk{disk_drive} \"{args.disk_path}\"")
                s.sendall(cmd.encode("utf8"))
                if args.debug:
                    print (cmd)

                # Due OpenMSX 20+ LED is only ready only,
                # now I have to send a message instead
                cmd = wrap_command(f"message \"** Disk ready **\" info")
                s.sendall(cmd.encode("utf8"))
                if args.debug:
                    print (cmd)


            s.close()
            
    except (socket.timeout, TimeoutError) as e:
        print(f"Timeout error: {e}", file=sys.stderr)
        sys.exit(3)
    except Exception as e:
        print(f"General error: {e}", file=sys.stderr)
        sys.exit(1)

if __name__ == "__main__":
    main()

