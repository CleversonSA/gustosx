#!/usr/bin/env python3
# -*- coding: utf-8 -*-

# ===================================================
#  Start custom binding keys at OpenMSX 
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
    ap = argparse.ArgumentParser(description="Start custom bindinds at OpenMSX from CLI")
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

            rfile = s.makefile("r", encoding="utf-8", newline="\n")

            banner = rfile.readline().strip()
            if args.debug:
                print(f"[recv] {banner}")

            ctrl_line = "<openmsx-control>\n"
            s.sendall(ctrl_line.encode("utf-8"))
            if args.debug:
               print(f"[sent] {ctrl_line.strip()}")

            #-----------------------------------------------------
            # bind:
            #   key = CTRL+UP
            #   command = DISK FOLDER SELECTOR (0xF2)
            #   params = DIRFIRST
            #-----------------------------------------------------
            cmd = wrap_command('bind CTRL+UP { poke 0xCF00 0xF2; poke 0xCF01 68;poke 0xCF02 73;poke 0xCF03 82;poke 0xCF04 70;poke 0xCF05 73;poke 0xCF06 82;poke 0xCF07 83;poke 0xCF08 84;poke 0xCF09 0; message "(DISK SELECTOR) Goto FIRST folder"; }\n') 
            s.sendall(cmd.encode("utf8"))
            if args.debug:
                print(f"[sent] {cmd}")
       
            raw = read_until_reply(rfile, timeout=args.timeout)
            if args.debug:
                print (raw)

            
            #-----------------------------------------------------
            # bind:
            #   key = CTRL+LEFT
            #   command = DISK FOLDER SELECTOR (0xF2)
            #   params = DIRPREVIOUS
            #-----------------------------------------------------
            cmd = wrap_command('bind CTRL+LEFT { poke 0xCF00 0xF2; poke 0xCF01 68;poke 0xCF02 73;poke 0xCF03 82;poke 0xCF04 80;poke 0xCF05 82;poke 0xCF06 69;poke 0xCF07 86;poke 0xCF08 73;poke 0xCF09 79;poke 0xCF0A 85;poke 0xCF0B 83;poke 0xCF0C 0;message "(DISK SELECTOR) Goto PREVIOUS folder"; }\n') 
            s.sendall(cmd.encode("utf8"))
            if args.debug:
                print(f"[sent] {cmd}")
       
            raw = read_until_reply(rfile, timeout=args.timeout)
            if args.debug:
                print (raw)


            #-----------------------------------------------------
            # bind:
            #   key = CTRL+RIGHT
            #   command = DISK FOLDER SELECTOR (0xF2)
            #   params = DIRNEXT
            #-----------------------------------------------------
            cmd = wrap_command('bind CTRL+RIGHT { poke 0xCF00 0xF2; poke 0xCF01 68;poke 0xCF02 73;poke 0xCF03 82;poke 0xCF04 78;poke 0xCF05 69;poke 0xCF06 88;poke 0xCF07 84;poke 0xCF08 0;message "(DISK SELECTOR) Goto NEXT folder"; }\n') 
            s.sendall(cmd.encode("utf8"))
            if args.debug:
                print(f"[sent] {cmd}")
       
            raw = read_until_reply(rfile, timeout=args.timeout)
            if args.debug:
                print (raw)


            #-----------------------------------------------------
            # bind:
            #   key = CTRL+DOWN
            #   command = DISK FOLDER SELECTOR (0xF2)
            #   params = DIRLAST
            #-----------------------------------------------------
            #cmd = wrap_command('bind CTRL+DOWN { poke 0xCF00 0xF2; poke 0xCF01 68;poke 0xCF02 73;poke 0xCF03 82;poke 0xCF04 76;poke 0xCF05 65;poke 0xCF06 83;poke 0xCF07 84;poke 0xCF08 0;message "(DISK SELECTOR) Goto LAST folder"; }\n') 
            #s.sendall(cmd.encode("utf8"))
            #if args.debug:
            #    print(f"[sent] {cmd}")
       
            #raw = read_until_reply(rfile, timeout=args.timeout)
            #if args.debug:
            #    print (raw)

            
            #-----------------------------------------------------
            # bind:
            #   key = ALT+UP
            #   command = DISK FOLDER SELECTOR (0xF2)
            #   params = DSKFIRST
            #-----------------------------------------------------
            cmd = wrap_command('bind ALT+UP { poke 0xCF00 0xF2; poke 0xCF01 68;poke 0xCF02 83;poke 0xCF03 75;poke 0xCF04 70;poke 0xCF05 73;poke 0xCF06 82;poke 0xCF07 83;poke 0xCF08 84;poke 0xCF09 0;message "(DISK SELECTOR) Goto FIRST file"; }\n') 
            s.sendall(cmd.encode("utf8"))
            if args.debug:
                print(f"[sent] {cmd}")
       
            raw = read_until_reply(rfile, timeout=args.timeout)
            if args.debug:
                print (raw)


            #-----------------------------------------------------
            # bind:
            #   key = ALT+LEFT
            #   command = DISK FOLDER SELECTOR (0xF2)
            #   params = DSKPREVIOUS
            #-----------------------------------------------------
            cmd = wrap_command('bind ALT+LEFT { poke 0xCF00 0xF2; poke 0xCF01 68;poke 0xCF02 83;poke 0xCF03 75;poke 0xCF04 80;poke 0xCF05 82;poke 0xCF06 69;poke 0xCF07 86;poke 0xCF08 73;poke 0xCF09 79;poke 0xCF0A 85;poke 0xCF0B 83;poke 0xCF0C 0;message "(DISK SELECTOR) Goto PREVIOUS file"; }\n') 
            s.sendall(cmd.encode("utf8"))
            if args.debug:
                print(f"[sent] {cmd}")
       
            raw = read_until_reply(rfile, timeout=args.timeout)
            if args.debug:
                print (raw)


            #-----------------------------------------------------
            # bind:
            #   key = ALT+RIGHT
            #   command = DISK FOLDER SELECTOR (0xF2)
            #   params = DSKNEXT
            #-----------------------------------------------------
            cmd = wrap_command('bind ALT+RIGHT { poke 0xCF00 0xF2; poke 0xCF01 68;poke 0xCF02 83;poke 0xCF03 75;poke 0xCF04 78;poke 0xCF05 69;poke 0xCF06 88;poke 0xCF07 84;poke 0xCF08 0;message "(DISK SELECTOR) Goto NEXT file"; }\n') 
            s.sendall(cmd.encode("utf8"))
            if args.debug:
                print(f"[sent] {cmd}")
       
            raw = read_until_reply(rfile, timeout=args.timeout)
            if args.debug:
                print (raw)

            #-----------------------------------------------------
            # bind:
            #   key = ALT+DOWN
            #   command = DISK FOLDER SELECTOR (0xF2)
            #   params = DSKLAST
            #-----------------------------------------------------
            #cmd = wrap_command('bind ALT+DOWN { poke 0xCF00 0xF2; poke 0xCF01 68;poke 0xCF02 83;poke 0xCF03 75;poke 0xCF04 76;poke 0xCF05 65;poke 0xCF06 83;poke 0xCF07 84;poke 0xCF08 0;message "(DISK SELECTOR) Goto LAST file"; }\n') 
            #s.sendall(cmd.encode("utf8"))
            #if args.debug:
            #    print(f"[sent] {cmd}")
       
            #raw = read_until_reply(rfile, timeout=args.timeout)
            #if args.debug:
            #    print (raw)


            #-----------------------------------------------------
            # bind:
            #   key = CTRL+DOWN
            #   command = DISK FOLDER SELECTOR (0xF2)
            #   params = DIRSELECT
            #-----------------------------------------------------
            cmd = wrap_command('bind CTRL+DOWN { poke 0xCF00 0xF2; poke 0xCF01 68;poke 0xCF02 73;poke 0xCF03 82;poke 0xCF04 83;poke 0xCF05 69;poke 0xCF06 76;poke 0xCF07 69;poke 0xCF08 67;poke 0xCF09 84;poke 0xCF0A 0;message "(DISK SELECTOR) OPEN FOLDER"; }\n') 
            s.sendall(cmd.encode("utf8"))
            if args.debug:
                print(f"[sent] {cmd}")
       
            raw = read_until_reply(rfile, timeout=args.timeout)
            if args.debug:
                print (raw)


            #-----------------------------------------------------
            # bind:
            #   key = ALT+DOWN
            #   command = DISK FOLDER SELECTOR (0xF2)
            #   params = DSKSELECT
            #-----------------------------------------------------
            cmd = wrap_command('bind ALT+DOWN { poke 0xCF00 0xF2; poke 0xCF01 68;poke 0xCF02 83;poke 0xCF03 75;poke 0xCF04 83;poke 0xCF05 69;poke 0xCF06 76;poke 0xCF07 69;poke 0xCF08 67;poke 0xCF09 84;poke 0xCF0A 0;message "(DISK SELECTOR) OPEN DSK FILE"; }\n') 
            s.sendall(cmd.encode("utf8"))
            if args.debug:
                print(f"[sent] {cmd}")
       
            raw = read_until_reply(rfile, timeout=args.timeout)
            if args.debug:
                print (raw)


            #-----------------------------------------------------
            # bind:
            #   key = CTRL+SHIFT+DOWN
            #   command = DISK FOLDER SELECTOR (0xF2)
            #   params = DSKEJECT
            #-----------------------------------------------------
            cmd = wrap_command('bind CTRL+SHIFT+DOWN { poke 0xCF00 0xF2; poke 0xCF01 68;poke 0xCF02 83;poke 0xCF03 75;poke 0xCF04 69;poke 0xCF05 74;poke 0xCF06 69;poke 0xCF07 67;poke 0xCF08 84;poke 0xCF09 0;message "(DISK SELECTOR) EJECT DISK"; }\n') 
            s.sendall(cmd.encode("utf8"))
            if args.debug:
                print(f"[sent] {cmd}")
       
            raw = read_until_reply(rfile, timeout=args.timeout)
            if args.debug:
                print (raw)



            #-----------------------------------------------------
            # bind:
            #   key = CTRL+SHIFT+UP
            #   command = DISK FOLDER SELECTOR (0xF2)
            #   params = DSKINTERNAL
            #-----------------------------------------------------
            cmd = wrap_command('bind CTRL+SHIFT+UP { poke 0xCF00 0xF2; poke 0xCF01 68;poke 0xCF02 83;poke 0xCF03 75;poke 0xCF04 73;poke 0xCF05 78;poke 0xCF06 84;poke 0xCF07 69;poke 0xCF08 82;poke 0xCF09 78;poke 0xCF0A 65;poke 0xCF0B 76;poke 0xCF0C 0;message "(DISK SELECTOR) OPEN INTERNAL DISK"; }\n') 
            s.sendall(cmd.encode("utf8"))
            if args.debug:
                print(f"[sent] {cmd}")
       
            raw = read_until_reply(rfile, timeout=args.timeout)
            if args.debug:
                print (raw)


            s.close()
            
    except (socket.timeout, TimeoutError) as e:
        print(f"Timeout error: {e}", file=sys.stderr)
        sys.exit(3)
    except Exception as e:
        print(f"General error: {e}", file=sys.stderr)
        sys.exit(1)

if __name__ == "__main__":
    main()

