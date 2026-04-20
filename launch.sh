#!/bin/bash
# launch.sh -- One-command wireless ADB setup
# Usage: ./launch.sh
#        ./launch.sh 192.168.1.100

set -e
IP="${1:-}"
PORT=5555

if [[ -z "$IP" ]]; then
    echo "Wireless ADB Launcher"
    echo "===================="
    echo ""
    echo "Option 1: Auto-discover device"
    echo "  ./launch.sh"
    echo ""
    echo "Option 2: Connect to specific IP"
    echo "  ./launch.sh 192.168.1.100"
    echo ""
    
    # Try to find device
    echo "Scanning for ADB devices..."
    DEVICES=$(adb devices | tail -n +2 | grep -E '\t' | awk '{print $1}')
    
    if [[ -z "$DEVICES" ]]; then
        echo "No USB ADB devices found."
        exit 1
    fi
    
    echo "Found USB devices:"
    echo "$DEVICES" | nl
    read -p "Select device (number or IP): " CHOICE
    
    if [[ "$CHOICE" =~ ^[0-9]+$ ]]; then
        IP=$(echo "$DEVICES" | sed -n "${CHOICE}p")
    else
        IP="$CHOICE"
    fi
fi

echo ""
echo "Enabling wireless ADB on $IP..."
adb shell setprop service.adb.tcp.port 5555
adb shell stop adbd
adb shell start adbd

if [[ ! "$IP" =~ ^[0-9.]+$ ]]; then
    IP=$(adb shell ip addr show wlan0 | grep "inet " | awk '{print $2}' | cut -d/ -f1)
    echo "  Device IP: $IP"
fi

echo ""
echo "Connecting..."
adb connect "$IP:$PORT"

echo ""
echo "Done! Device connected at $IP:$PORT"
