#!/bin/bash

BLUE='\033[0;34m'
echo -e "\n"
echo -e "${BLUE}Activating 1 Mbps Interface for Standalone Y200 Testing...\n"

# --- 1. Teardown & Driver Preparation ---
sudo ip link set can0 down 2>/dev/null
sudo killall slcand 2>/dev/null
sleep 0.5

sudo modprobe can
sudo modprobe can_raw
sudo modprobe gs_usb
sleep 0.5

# --- 2. Initialize Interface at Your Target 1 Mbps Speed ---
sudo ip link set can0 type can bitrate 1000000
sudo ip link set can0 txqueuelen 1000
sudo ip link set can0 up

echo -e "${BLUE}Bus online at 1,000,000 bps."
echo -e "${BLUE}Injecting Hexfellow Operational Firmware Wakeup Sequence...${BLUE}\n"

# --- 3. Hexfellow Native Hardware Overrides ---
# These specific payloads force Node 0x10's core to bypass the 7F stall.
cansend can0 00000000#0110000000000000
sleep 0.1
cansend can0 00000010#0100000000000000
sleep 0.1

echo "Streaming Decoded Telemetry (Press Ctrl+C to terminate)..."
echo "------------------------------------------------------------------"
echo -e "Component\tX-Axis\t\tY-Axis\t\tZ-Axis"
echo "------------------------------------------------------------------"

# --- 4. Stream and Parse Array Frames Real-time ---
candump can0 | grep --line-buffered -E "000000A9|000000AB" | while read -r line; do
    # Isolate payload bytes and mapping identifiers
    raw_payload=$(echo "$line" | awk -F']' '{print $2}' | tr -d ' ')
    frame_id=$(echo "$line" | awk '{print $2}')

    # Little-Endian Reassembly (Byte-swap to Big-Endian)
    hex_x="${raw_payload:2:2}${raw_payload:0:2}"
    hex_y="${raw_payload:6:2}${raw_payload:4:2}"
    hex_z="${raw_payload:10:2}${raw_payload:8:2}"

    # Base string-to-decimal integer conversions
    val_x=$(printf "%d" "0x$hex_x")
    val_y=$(printf "%d" "0x$hex_y")
    val_z=$(printf "%d" "0x$hex_z")

    # Handle Signed Variables (Two's Complement Adjustment)
    [ $val_x -gt 32767 ] && val_x=$((val_x - 65536))
    [ $val_y -gt 32767 ] && val_y=$((val_y - 65536))
    [ $val_z -gt 32767 ] && val_z=$((val_z - 65536))

    # Match ID definitions to UI tags
    if [ "$frame_id" == "000000A9" ]; then
        sensor="[ACCEL]"
    else
        sensor="[GYRO ]"
    fi

    printf "\r%s\tX: %d\t\tY: %d\t\tZ: %d\t\t" "$sensor" "$val_x" "$val_y" "$val_z"
done
