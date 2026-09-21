#!/bin/bash

# shell script to send joint to two different positions continually

# CAN protocol v3: ID = class<<8 | node; commands go on 2nn with the node
# repeated in byte 0. Run with nino-bot stopped (one host at a time);
# without a heartbeat the joint starts broadcasting on its first command.
# The board on the bench is flashed as the joint it is going to be (there
# is no bench node), so its node id is the argument, 101..120.

NODE="${1:?usage: $0 <node 101..120>}"
if [ "$NODE" -lt 101 ] || [ "$NODE" -gt 120 ]; then
	echo "node must be 101..120" >&2
	exit 1
fi
HEX=$(printf '%02X' "$NODE") # 103 -> 67: identifier 267, payload byte 0 67

DELAY_3_SEC=3 # pause between two commands
DELAY_5_MIN=300 # break in for five minutes

echo "Starting joint break-in on node $NODE (ID 2$HEX)"

cansend can0 "2$HEX#${HEX}095A0001000000"
echo "Moving joint clockwise"
# sleep "$DELAY_3_SEC"
cansend can0 "2$HEX#${HEX}093C0001000000"
# CSF17: 2nn#nn09280001000000
# CSF8: 2nn#nn09200001000000
sleep "$DELAY_5_MIN"

echo "Stopping joint"
cansend can0 "2$HEX#${HEX}093C0001000000"
sleep "$DELAY_3_SEC"

echo "Moving joint counterclockwise"

cansend can0 "2$HEX#${HEX}093C0002000000"
# CSF17: 2nn#nn09280002000000
# CSF8: 2nn#nn09200002000000
sleep "$DELAY_5_MIN"

echo "Stopping joint"
cansend can0 "2$HEX#${HEX}09000001000000"

echo "Break-in period completed"
