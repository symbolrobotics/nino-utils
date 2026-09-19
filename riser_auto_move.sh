#!/bin/sh
set -eu

CYCLES=10
DELAY=10
LOG="riser_hall_$(date +%Y%m%d_%H%M%S)_$$.log"
DIAG="${LOG%.log}_diagnostics.txt"
EVENTS="${LOG%.log}_events.txt"
CAPTURE_PID=""

cleanup() {
    trap - EXIT INT TERM

    # Disable optional telemetry only. This does NOT stop the motors.
    cansend can0 064#6708000000000000 2>/dev/null || true
    cansend can0 064#6808000000000000 2>/dev/null || true

    if [ -n "$CAPTURE_PID" ]; then
        kill "$CAPTURE_PID" 2>/dev/null || true
        wait "$CAPTURE_PID" 2>/dev/null || true
    fi

    grep -E ' 06[78] .*\] +(0C|11|12) ' "$LOG" > "$DIAG" || true
    grep -E ' 06[78] .*\] +0C ' "$LOG" > "$EVENTS" || true

    printf '\nSaved:\n  %s\n  %s\n  %s\n' "$LOG" "$DIAG" "$EVENTS"
    echo "Motors have NOT been disabled by this script."
}

trap cleanup EXIT
trap 'exit 130' INT
trap 'exit 143' TERM

# Capture commands and riser feedback before sending anything.
candump -tz can0,064:7FF,067:7FF,068:7FF > "$LOG" &
CAPTURE_PID=$!
sleep 1

if ! kill -0 "$CAPTURE_PID" 2>/dev/null; then
    echo "CAN capture failed; aborting before motion." >&2
    exit 1
fi

# Enable position, requested/measured current, and trajectory telemetry.
cansend can0 064#6708000101010000
cansend can0 064#6808000101010000

# Arms 109/110: horizontal at 0 degrees, 7-second trajectory.
echo "Moving arms 109/110 to horizontal."
cansend can0 064#6D01000000000700
cansend can0 064#6E01000000000700
sleep "$DELAY"

count=1
while [ "$count" -le "$CYCLES" ]; do

    echo "Cycle $count/$CYCLES: up (-60/+60 degrees = -43691/+43691 counts, 6 seconds)"
    cansend can0 064#67015555FFFF0600
    cansend can0 064#6801ABAA00000600
    sleep "$DELAY"

    echo "Cycle $count/$CYCLES: rest (-1/+1 degrees = -728/+728 counts, 7 seconds)"
    cansend can0 064#670128FDFFFF0700
    cansend can0 064#6801D80200000700
    sleep "$DELAY"

    echo "Cycle $count/$CYCLES completed."
    count=$((count + 1))
done

echo "$CYCLES cycles completed. Risers remain at the elevated target."
sleep 2
