#!/bin/bash

# shell script to send joint to two different positions continually

# CAN protocol v3: ID = class<<8 | node; commands go on 2nn with the node
# repeated in byte 0. Run with nino-bot stopped (one host at a time);
# without a heartbeat the joint starts broadcasting on its first command.

DELAY_3_SEC=3 # pause between two commands
DELAY_5_MIN=300 # break in for five minutes

echo "Starting joint break-in"
echo "Joint Default ID: 199 Hex C7"

cansend can0 2C7#C7095A0001000000
echo "Moving joint clockwise"
# sleep "$DELAY_3_SEC"
cansend can0 2C7#C7093C0001000000
# CSF17: 2C7#C709280001000000
# CSF8: 2C7#C709200001000000
sleep "$DELAY_5_MIN"

echo "Stopping joint"
cansend can0 2C7#C7093C0001000000
sleep "$DELAY_3_SEC"

echo "Moving joint counterclockwise"

cansend can0 2C7#C7093C0002000000
# CSF17: 2C7#C709280002000000
# CSF8: 2C7#C709200002000000
sleep "$DELAY_5_MIN"

echo "Stopping joint"
cansend can0 2C7#C709000001000000

echo "Break-in period completed"
