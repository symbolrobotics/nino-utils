#!/bin/bash

# shell script to send joint to two different positions continually

DELAY=7 # pause between two commands
count=1

echo "Setting default speaker"
pactl set-default-sink alsa_output.usb-Jieli_Technology_UACDemoV1.0_5035811512F4521F-00.iec958-stereo

python3 Dev/speech.py 
echo "Move elbow to zero position: forearm tucked in"

cansend can0 064#6D01CEFF09000000
cansend can0 064#6F01000009000000
sleep "$DELAY"

echo "Start moving elbow continuously"

while true; do
	echo "Moving down"
	cansend can0 064#6D0188FF06000000
	cansend can0 064#6F01280006000000
	sleep "$DELAY"
	echo "Moving up"
	cansend can0 064#6D01CEFF06000000
        cansend can0 064#6F01000006000000
	sleep "$DELAY"
	echo "$count"
	count=$((count + 1))
done
