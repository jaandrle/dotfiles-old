#!/usr/bin/env python3

"""
Save or restore X11 desktop window arrangement.
Requires the `wmctrl` package to work.

Examples:
    window_arrange.py save
    window_arrange.py restore
    window_arrange.py --profile ~/.winlayout-home save
    window_arrange.py --profile ~/.winlayout-office restore
"""

import argparse
import codecs
import os
import subprocess
import sys


def shell_exec(command):
    return subprocess.check_output(command, shell=True).decode("utf-8")


def is_normal_window(window_id):
    window_type = shell_exec('xprop -id ' + window_id)
    return ' _NET_WM_WINDOW_TYPE_NORMAL' in window_type


def save_windows(profile_filename):
    window_list = [
        line.split()[:6]
        for line in shell_exec('wmctrl -lG').splitlines()
    ]
    relevant_window_ids = [
        ' '.join(window_spec)
        for window_spec in window_list
        if is_normal_window(window_spec[0])
    ]
    with codecs.open(profile_filename, 'w', 'utf-8') as out:
        out.write('\n'.join(relevant_window_ids))


def restore_windows(profile_filename):
    with codecs.open(profile_filename, 'r', 'utf-8') as sf:
        window_list = [
            line.split()
            for line in sf.read().splitlines()
        ]
        for window_spec in window_list:
            cmd = 'wmctrl -ir {} -e 0,{}'.format(window_spec[0], ','.join(window_spec[2:]))
            shell_exec(cmd)


def parse_args():
    default_profile = os.path.join(os.environ['HOME'], '.windowlayout')
    parser = argparse.ArgumentParser(description='Save or restore X11 desktop window arrangement.')
    parser.add_argument('--profile', type=str, default=default_profile, help='profile filename')
    parser.add_argument('command', type=str, choices=['save', 'restore'])
    return parser.parse_args()


def main():
    args = parse_args()

    if args.command == 'save':
        save_windows(args.profile)
    elif args.command == 'restore':
        restore_windows(args.profile)


if __name__ == '__main__':
    main()
