#!/bin/bash

BLUE='\033[0;34m'
echo -e "\n"
echo -e "${BLUE}Activating CAN FD Bus at 500 kbps for IMU Testing...\n"

# --- Teardown any previous state ---
sudo ip link set can0 down 2>/dev/null
sudo killall slcand 2>/dev/null
sleep 0.5

# --- gs_usb mode (candlelight firmware) ---
# This is the recommended approach for Ubuntu 22.04+ (kernel 5.15+).
# The adapter must be flashed with candlelight firmware:
#   https://github.com/candle-usb/candleLight_fw/releases
# Once flashed, the adapter no longer appears as /dev/ttyACM0.
# The gs_usb driver exposes it directly as can0 — no slcand needed.

sudo modprobe can
sudo modprobe can_raw
sudo modprobe gs_usb

sleep 1

# 500000 = 500 kbps (Matches the factory default bitrate of the Y200 IMU)
sudo ip link set can0 type can bitrate 500000
sudo ip link set can0 txqueuelen 1000
sudo ip link set can0 up

echo -e "${BLUE}Activated CAN Bus at 500kbps.${BLUE}"
echo -e "${BLUE}Sending 29-bit Extended NMT Activation Pulse to unlock data fields...\n"

# Push a background delay loop to flash the 29-bit CANopen operational state frame
(sleep 0.5 && candump can0 -n 1 -H | grep -q "710" && cansend can0 00000000#0100) &

echo -e "${BLUE}Dumping messages below (Verify 710 drops from 7F to 05, and 000000A9/B data rolls):${BLUE}\n"

candump can0

exit 0
