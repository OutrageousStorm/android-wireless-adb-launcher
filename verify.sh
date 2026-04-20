#!/bin/bash
# verify.sh — Check if wireless ADB is working
# Usage: ./verify.sh <device_ip>
set -e

IP="${1:?Usage: $0 <device_ip>}"
PORT="${2:-5555}"

echo "🔍 Verifying wireless ADB connection to $IP:$PORT"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Check if adb can reach it
if adb connect "$IP:$PORT" 2>&1 | grep -q "connected"; then
    echo "✅ Connected to $IP:$PORT"
    
    # Run a quick test
    MODEL=$(adb -s "$IP:$PORT" shell getprop ro.product.model 2>/dev/null)
    ANDROID=$(adb -s "$IP:$PORT" shell getprop ro.build.version.release 2>/dev/null)
    echo "   Device: $MODEL (Android $ANDROID)"
    
    # List connected devices
    echo ""
    echo "Connected devices:"
    adb devices | grep -E "^[^L]" | awk '{print "  " $0}'
else
    echo "❌ Failed to connect to $IP:$PORT"
    echo "Make sure:"
    echo "  1. Device has wireless ADB enabled (Settings → Developer Options)"
    echo "  2. IP and port are correct"
    echo "  3. Both are on same network"
    exit 1
fi
