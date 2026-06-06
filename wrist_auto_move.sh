#!/bin/bash

# shell script to send joint to two different positions continually

DELAY=7 # pause between two commands
count=1

echo "Setting default speaker"
pactl set-default-sink alsa_output.usb-Jieli_Technology_UACDemoV1.0_5035811512F4521F-00.iec958-stereo

python3 Dev/speech.py 
echo "Move wrist to zero position: level hand"

cansend can0 064#7901000005000000;cansend can0 064#7701000005000000
sleep "$DELAY"

echo "Start moving wrist continuously"

while true; do
	echo "Moving up"
	cansend can0 064#79015A0005020000;cansend can0 064#77015A0005010000
	sleep "$DELAY"
	#echo "Moving straight"
	#cansend can0 064#7901000005010000;cansend can0 064#7701000005020000
	#sleep "$DELAY"
	echo "Rotating right"
	cansend can0 064#7901B40005000000
	sleep "$DELAY"
	echo "Rotating left"
	cansend can0 064#7901000005000000
	sleep "$DELAY"
	echo "Rotating straight"
	cansend can0 064#7901000005000000;cansend can0 064#7701000005000000
	sleep "$DELAY"
	echo "$count"
	count=$((count + 1))
done
