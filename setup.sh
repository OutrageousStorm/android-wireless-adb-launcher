#!/bin/bash
# setup.sh -- One-command wireless ADB setup and management
# Usage: ./setup.sh                    (interactive menu)
#        ./setup.sh enable             (enable wireless debugging)
#        ./setup.sh connect <IP>       (connect to device IP)
#        ./setup.sh daemon             (background monitoring)

set -e
BOLD='\033[1m'; CYAN='\033[0;36m'; GREEN='\033[0;32m'; RED='\033[0;31m'; NC='\033[0m'

enable_wireless() {
    echo -e "${CYAN}Enabling wireless debugging...${NC}"
    adb shell settings put global adb_enabled 1
    adb shell settings put secure adb_enabled 1
    adb shell setprop ctl.stop adbd
    adb shell setprop ctl.start adbd
    
    # Android 11+ wireless pairing
    if adb shell getprop ro.build.version.sdk | grep -qE "^(30|3[1-9]|[4-9][0-9])"; then
        PORT=$(adb shell settings get global adb_secure_port | grep -oE '[0-9]+')
        PORT=${PORT:-5555}
        echo -e "${GREEN}✓ Wireless ADB enabled on port $PORT${NC}"
        echo "Next: ./setup.sh pair <IP> <PORT>"
    fi
}

pair_device() {
    local ip=${1:-$(adb shell ifconfig | grep "inet " | grep -v 127 | awk '{print $2}')}
    local port=${2:-5555}
    
    if [[ -z "$ip" ]]; then
        echo -e "${RED}Could not find device IP. Connect USB first.${NC}"
        exit 1
    fi
    
    echo -e "${CYAN}Pairing with $ip:$port...${NC}"
    # Get pairing port (Android 11+)
    local pair_port=$(adb shell settings get global adb_secure_port)
    pair_port=${pair_port:-5037}
    
    adb pair $ip:$pair_port
    echo -e "${GREEN}✓ Paired${NC}"
}

connect_device() {
    local ip=${1}
    if [[ -z "$ip" ]]; then
        read -p "Device IP address: " ip
    fi
    adb connect $ip:5555
    echo -e "${GREEN}✓ Connected to $ip${NC}"
}

daemon() {
    echo -e "${CYAN}Wireless ADB daemon (Ctrl+C to stop)${NC}"
    while true; do
        # Reconnect any devices that went offline
        offline=$(adb devices | grep offline)
        if [[ ! -z "$offline" ]]; then
            echo "[$(date '+%H:%M:%S')] Reconnecting offline devices..."
            adb devices | grep offline | awk '{print $1}' | while read dev; do
                adb connect ${dev%:*}:5555
            done
        fi
        sleep 30
    done
}

menu() {
    echo -e "\n${BOLD}🌐 Wireless ADB Setup${NC}"
    echo "1) Enable wireless debugging (USB first)"
    echo "2) Pair with device (Android 11+)"
    echo "3) Connect by IP"
    echo "4) List connected devices"
    echo "5) Daemon mode (auto-reconnect)"
    echo "6) Exit"
    read -p "Choice: " choice
    
    case $choice in
        1) enable_wireless ;;
        2) pair_device ;;
        3) connect_device ;;
        4) adb devices ;;
        5) daemon ;;
        6) exit 0 ;;
    esac
    menu
}

# Main
if [[ $# -eq 0 ]]; then
    menu
else
    case "$1" in
        enable)  enable_wireless ;;
        pair)    pair_device "$2" "$3" ;;
        connect) connect_device "$2" ;;
        daemon)  daemon ;;
        *)       echo "Unknown command: $1"; exit 1 ;;
    esac
fi
