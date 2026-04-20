#!/usr/bin/env python3
"""
wireless_adb.py -- Enable and connect to Android device via wireless ADB
Usage: python3 wireless_adb.py --ip 192.168.1.100
       python3 wireless_adb.py --usb-to-tcp
"""
import subprocess, argparse

def adb(cmd):
    subprocess.run(f"adb shell {cmd}", shell=True, capture_output=True)

parser = argparse.ArgumentParser()
parser.add_argument("--ip")
parser.add_argument("--usb-to-tcp", action="store_true")
args = parser.parse_args()

if args.usb_to_tcp:
    print("Enabling wireless debugging over TCP...")
    adb("setprop service.adb.tcp.port 5555")
    adb("stop adbd && start adbd")
    print("✓ Enabled on port 5555")
elif args.ip:
    cmd = f"adb connect {args.ip}:5555"
    subprocess.run(cmd, shell=True)
    print(f"✓ Connected to {args.ip}")
else:
    parser.print_help()
