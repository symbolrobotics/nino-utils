#!/bin/bash

# shell script to send joint to two different positions continually

DELAY=11 # pause between two commands
count=1

echo "Setting default speaker"
pactl set-default-sink alsa_output.usb-Jieli_Technology_UACDemoV1.0_5035811512F4521F-00.iec958-stereo

python3 Dev/speech.py 
echo "Move head to zero position: level head"

cansend can0 064#6B01000005000000;cansend can0 064#6C01000005000000
sleep "$DELAY"

echo "Start moving head continuously"

while true; do
	echo "Looking up"
	cansend can0 064#6B012D0005020000;cansend can0 064#6C012D0005010000
	sleep "$DELAY"
	echo "Looking straight"
	cansend can0 064#6B01000005010000;cansend can0 064#6C01000005020000
	sleep "$DELAY"
	echo "Looking left"
	cansend can0 064#6B015A0005020000;cansend can0 064#6C015A0005020000
	sleep "$DELAY"
	echo "Looking right"
	cansend can0 064#6B015A0005010000;cansend can0 064#6C015A0005010000
	sleep "$DELAY"
	echo "Looking straight"
	cansend can0 064#6B01000005000000;cansend can0 064#6C01000005000000
	sleep "$DELAY"
	echo "$count"
	count=$((count + 1))
done
