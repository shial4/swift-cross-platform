#!/bin/bash

# Start the Android emulator
emulator -avd Nexus_6P_API_30 -no-audio -no-window -gpu swiftshader -verbose &

# Wait for the emulator to finish booting
boot_complete=""
while [ -z "$boot_complete" ]; do
    boot_complete=$(adb shell getprop sys.boot_completed 2>/dev/null | tr -d '\r')
    sleep 5
done

# Output emulator information
emulator -list-avds
adb devices

# Add any additional setup or commands needed for your specific use case

# Exit
exit 0
