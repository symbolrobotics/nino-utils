#!/bin/bash

BLUE='\033[0;34m'
echo -e "\n"
echo -e "${BLUE}Activating CAN FD Bus\n"

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

# 1000000 = 1 Mbps (matches the original -s8 setting)
sudo ip link set can0 type can bitrate 1000000
sudo ip link set can0 txqueuelen 1000
sudo ip link set can0 up

echo -e "${BLUE}Actived CAN FD Bus and dumping messages below\n"

candump can0

exit 0
