#!/bin/bash

# shell script to send joint to two different positions continually

DELAY=11 # pause between two commands
count=1
echo "Start moving joint"

while true; do
	cansend can0 064#6901680109000000
	sleep "$DELAY"
	cansend can0 064#690198FE09000000
	sleep "$DELAY"
	echo "$count"
	count=$((count + 1))
done
