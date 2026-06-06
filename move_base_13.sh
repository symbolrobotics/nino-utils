#!/bin/bash

# shell script to send joint to two different positions continually

DELAY=15 # pause between two commands
count = 1
echo "Start moving joint"

#while true; do
	cansend can0 001#0D01460006020000
	sleep "$DELAY"
	cansend can0 001#0D01000009010000
	sleep "$DELAY"
	echo "$count"
	count=$((count + 1))
#done
