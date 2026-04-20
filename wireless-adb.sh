#!/bin/bash
set -e

PORT=${PORT:-5555}
echo "📡 Wireless ADB"
adb devices | grep -q "device$" || { echo "No USB device"; exit 1; }

DEVICE_IP=$(adb shell ip route | grep "src" | awk '{print $NF}' | head -1)
[[ -z "$DEVICE_IP" ]] && { echo "No IP"; exit 1; }

echo "Device IP: $DEVICE_IP:$PORT"
adb tcpip $PORT
sleep 2
adb connect $DEVICE_IP:$PORT
sleep 2

if adb devices | grep -q "$DEVICE_IP"; then
    echo "✅ Wireless ADB enabled!"
else
    echo "❌ Failed"
    exit 1
fi
