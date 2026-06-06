#!/bin/bash

# shell script to send joint to two different positions continually

DELAY=7 # pause between two commands
count=1

echo "Setting default speaker"
pactl set-default-sink alsa_output.usb-Jieli_Technology_UACDemoV1.0_5035811512F4521F-00.iec958-stereo

python3 Dev/speech.py 
echo "Move shoulder to 15 degrees  position: arm straight down"

cansend can0 064#6D01F4FF05000000;cansend can0 064#6F01000005000000
sleep "$DELAY"

echo "Start moving shoulder continuously"

while true; do
	echo "Raising left shoulder 60 degrees"
	cansend can0 064#6D01C4FF06000000
	sleep "$DELAY"
	echo "Opening left shoulder 60 degrees"
	cansend can0 064#6F013C0006000000
	sleep "$DELAY"
	echo "Lowering left shoulder to 15 degrees"
	cansend can0 064#6D01F4FF06000000
	sleep "$DELAY"
	echo "Closing shoulder to zero degrees"
	cansend can0 064#6F01000006000000
	sleep "$DELAY"
	echo "Opening both joints at once to 60 degrees"
	cansend can0 064#6D01C4FF06000000;cansend can0 064#6F012D0006000000
	sleep "$DELAY"
	echo "Closing both joints at once"
	cansend can0 064#6D01F4FF06000000;cansend can0 064#6F01000006000000
	sleep "$DELAY"
	echo "$count"
	count=$((count + 1))
done
