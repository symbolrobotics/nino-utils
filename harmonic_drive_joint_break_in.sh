#!/bin/bash

# shell script to send joint to two different positions continually

DELAY_3_SEC=3 # pause between two commands
DELAY_5_MIN=300 # break in for five minutes

echo "Starting joint break-in"
echo "Joint Default ID: 199 Hex C7"

cansend can0 064#C7095A0001000000
echo "Moving joint clockwise"
# sleep "$DELAY_3_SEC"
cansend can0 064#C7093C0001000000
# CSF17: 064#C709280001000000
# CSF8: 064#C709200001000000
sleep "$DELAY_5_MIN"

echo "Stopping joint"
cansend can0 064#C7093C0001000000
sleep "$DELAY_3_SEC"

echo "Moving joint counterclockwise"

cansend can0 064#C7093C0002000000
# CSF17: 064#C709280002000000
# CSF8: 064#C709200002000000
sleep "$DELAY_5_MIN"

echo "Stopping joint"
cansend can0 064#C709000001000000

echo "Break-in period completed"
