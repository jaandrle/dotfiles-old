#!/usr/bin/env python3
import subprocess
import os
import sys

wfile = os.environ["HOME"]+"/.windowlist"
arg = sys.argv[1]

def get(command):
    return subprocess.check_output(["/bin/bash", "-c", command]).decode("utf-8")

def check_window(w_id):
    w_type = get("xprop -id "+w_id)
    if " _NET_WM_WINDOW_TYPE_NORMAL" in w_type:
        return True
    else:
        return False

def read_windows():
    w_list =  [l.split()[:6] for l in get("wmctrl -lG").splitlines()]
    relevant = [(" ").join(w) for w in w_list if check_window(w[0]) == True]
    with open(wfile, "wt") as out:
        for item in relevant:
            out.write(item+"\n")
    get("alert 'Windows positions saved.'")

def restore_windows():
    try:
        wlist = [l.split() for l in open(wfile).read().splitlines()]
    except FileNotFoundError:
        pass
    else:
        for w in wlist:
            try:
                cmd = "wmctrl -ir "+w[0]+" -e 0,"+(",").join(w[2:])
                subprocess.Popen(["/bin/bash", "-c", cmd])
            except:
                pass

if arg == "-restore":
    restore_windows()
elif arg == "-get":
    read_windows()
