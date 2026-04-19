# 🌐 Wireless ADB Launcher

One-command wireless ADB setup — no USB required after pairing.

## Usage

```bash
# Interactive menu
./setup.sh

# Enable wireless debugging (Android 11+)
./setup.sh enable

# Pair with device (one-time, shows pairing code on screen)
./setup.sh pair 192.168.1.100

# Connect by IP
./setup.sh connect 192.168.1.100

# Auto-reconnect daemon
./setup.sh daemon
```

## How it works

1. **Enable** (USB connected): Enables ADB over TCP on device
2. **Pair** (Android 11+): One-time pairing with code shown on device screen
3. **Connect**: Connect wirelessly from any PC on same network
4. **Daemon**: Background process that auto-reconnects if device goes offline

## Requirements
- Android 11+ for pairing
- Android 5+ for basic wireless ADB (no pairing, less secure)
- USB debugging enabled on device
- adb in PATH
