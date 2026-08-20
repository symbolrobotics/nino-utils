#!/bin/bash

# shell script to play sound on the USB speaker (Jieli UACDemoV1.0)
#
# usage:
#   ./speaker.sh                 # play the default test wav
#   ./speaker.sh play FILE.wav   # play a wav file
#   ./speaker.sh test            # tone via speaker-test
#   ./speaker.sh say "hello"     # text to speech (needs spd-say)
#   ./speaker.sh volume 80       # set playback volume in percent
#   ./speaker.sh info            # show detected card

CARD_NAME="UACDemo" # substring of the card name in /proc/asound/cards
DEFAULT_WAV="/usr/share/sounds/alsa/Front_Center.wav"

# find the ALSA card index of the USB speaker
find_card() {
	local idx
	idx=$(awk -v name="$CARD_NAME" '$0 ~ name {print $1; exit}' /proc/asound/cards)
	if [ -z "$idx" ]; then
		echo "Error: no ALSA card matching '$CARD_NAME' found. Is the speaker plugged in?" >&2
		echo "Available cards:" >&2
		cat /proc/asound/cards >&2
		exit 1
	fi
	echo "$idx"
}

# find the PipeWire node.name for the USB speaker (empty if PipeWire isn't
# running or doesn't know about this card yet)
find_pw_sink() {
	command -v pw-dump >/dev/null || return 0
	pw-dump 2>/dev/null |
		grep -o "\"node.name\": *\"[^\"]*${CARD_NAME}[^\"]*\"" |
		head -1 |
		sed -E 's/.*"([^"]+)"$/\1/'
}

CARD=$(find_card) || exit 1
DEVICE="plughw:${CARD},0"
PW_SINK=$(find_pw_sink)

case "${1:-play}" in
play)
	WAV="${2:-$DEFAULT_WAV}"
	if [ ! -f "$WAV" ]; then
		echo "Error: file not found: $WAV" >&2
		exit 1
	fi
	if [ -n "$PW_SINK" ] && command -v pw-play >/dev/null; then
		# a desktop session (PipeWire/WirePlumber) holds the ALSA device
		# exclusively, so route through PipeWire instead of raw ALSA
		echo "Playing $WAV via PipeWire sink $PW_SINK"
		pw-play --target="$PW_SINK" "$WAV"
	else
		echo "Playing $WAV on card $CARD ($DEVICE)"
		aplay -D "$DEVICE" "$WAV"
	fi
	;;
test)
	if [ -n "$PW_SINK" ]; then
		# route the tone through the "pipewire" ALSA PCM plugin, which
		# shares the device instead of opening it exclusively
		echo "Playing test tone via PipeWire (default sink)"
		speaker-test -D pipewire -t sine -f 440 -l 1
	else
		echo "Playing test tone on card $CARD ($DEVICE)"
		speaker-test -D "$DEVICE" -t sine -f 440 -l 1
	fi
	;;
say)
	TEXT="${2:-Hello from the robot}"
	if ! command -v spd-say >/dev/null; then
		echo "Error: spd-say not installed (apt install speech-dispatcher)" >&2
		exit 1
	fi
	echo "Saying: $TEXT"
	spd-say -w "$TEXT"
	;;
volume)
	LEVEL="${2:-80}"
	echo "Setting volume of card $CARD to ${LEVEL}%"
	amixer -c "$CARD" sset PCM "${LEVEL}%" 2>/dev/null ||
		amixer -c "$CARD" sset Speaker "${LEVEL}%" 2>/dev/null ||
		amixer -c "$CARD" sset Master "${LEVEL}%" ||
		echo "Warning: no PCM/Speaker/Master control on this card" >&2
	;;
info)
	echo "Card index : $CARD"
	echo "Device     : $DEVICE"
	aplay -l | grep -A1 "card ${CARD}:"
	;;
*)
	echo "Usage: $0 {play [FILE.wav] | test | say \"text\" | volume PERCENT | info}" >&2
	exit 1
	;;
esac
