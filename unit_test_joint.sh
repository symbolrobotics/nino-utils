#!/bin/bash

# shell script to send joint to two different positions continually

DELAY=11 # pause between two commands
count=1
sleep "$DELAY"
echo "Start moving joint"

while true; do
	cansend can0 064#C7015A0005000000
	sleep "$DELAY"
	cansend can0 064#C7015A0009020000
	sleep "$DELAY"
        cansend can0 064#C701000009000000
        sleep "$DELAY"
	cansend can0 064#C701B40009000000
        sleep "$DELAY"
	echo "$count"
	count=$((count + 1))
done
