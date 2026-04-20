#!/usr/bin/env node
const { exec } = require('child_process');

async function run(cmd) {
    return new Promise((resolve, reject) => {
        exec(cmd, (err, stdout) => {
            if (err) reject(err);
            else resolve(stdout.trim());
        });
    });
}

async function main() {
    console.log('\n📱 Wireless ADB Launcher\n');
    
    try {
        await run('adb version');
    } catch (e) {
        console.error('❌ adb not in PATH');
        process.exit(1);
    }

    let devices = await run('adb devices');
    if (!devices.includes('device')) {
        console.error('❌ No USB devices connected');
        process.exit(1);
    }

    let ipaddr = await run('adb shell ip addr show wlan0');
    let match = ipaddr.match(/inet\s+([\d.]+)/);
    let ip = match ? match[1] : null;

    if (!ip) {
        console.error('❌ Could not detect IP');
        process.exit(1);
    }

    console.log('🔧 Enabling wireless ADB...\n');
    await run('adb tcpip 5555');
    await new Promise(r => setTimeout(r, 1000));
    await run('adb connect ' + ip + ':5555');
    
    console.log('✅ Wireless ADB ready!');
    console.log('   Device: ' + ip + ':5555');
    console.log('   Run: adb connect ' + ip);
}

main().catch(console.error);
