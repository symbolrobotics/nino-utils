#!/bin/bash

# shell script to send joint to two different positions continually

DELAY=0.0001 # pause between two commands
count=1
echo "Blasting CAN Bus to test robustness"

while true;do
	#cansend can0 069#00B4000601000000
	cansend can0 064#000A000001000000
	sleep "$DELAY"
	echo "$count"
	count=$((count + 1))
done
