#!/bin/sh

BASEDIR="/mnt/us/timelit"

## Shortcircuit if we aren't running

# If the Kindle is not being used as clock, then just quit
test -f "$BASEDIR/clockisticking" || exit


## Set some defaults for the settings
# Default timezone (overridden by /mnt/us/timelit/conf/<MAC>.conf if present)
# Australian Eastern Standard Time / Australian Eastern Daylight Time
# (derived from `timelit/conf/timezones list`: EST-10EDT)
TZ='EST-10EDT,M10.5.0/3:00:00,M3.5.0/2:00:00'


## Load the kindle-specific settings
MAC_RAW="$(cat /sys/class/net/wlan0/address 2>/dev/null | tr -d '\r\n')"
MAC_DASH="$(echo "$MAC_RAW" | sed 's/:/-/g')"

# Try a few conf naming conventions:
# - <mac-with-dashes>.conf (what this repo uses)
# - <mac-with-colons>.conf (common when created manually)
# - default.conf (manual override if desired)
CONF_LOADED=""
for conf in \
	"$BASEDIR/conf/${MAC_DASH}.conf" \
	"$BASEDIR/conf/${MAC_RAW}.conf" \
	"$BASEDIR/conf/default.conf"
do
	if [ -f "$conf" ]; then
		. "$conf"
		CONF_LOADED="$conf"
		break
	fi
done

# Diagnostic (prints to SSH/cron logs; not to the e-ink screen)
if [ -n "$CONF_LOADED" ]; then
	echo "timelit: loaded conf '$CONF_LOADED' (MAC='$MAC_RAW')"
else
	echo "timelit: no conf found for MAC='$MAC_RAW' (tried '$BASEDIR/conf/${MAC_DASH}.conf', '$BASEDIR/conf/${MAC_RAW}.conf', '$BASEDIR/conf/default.conf')"
fi

## Run the main program

# Find the current minute of the day
MinuteOTheDay="$(env TZ="$TZ" date -R +"%H%M")";
HourOfDay="$(env TZ="$TZ" date -R +"%H")";
MinuteOfHour="$(env TZ="$TZ" date -R +"%M")";

# ALTERNATIVE TIME KEEPING - comment out the one above and uncomment this one to simply pull the 
# internal Kindle time (Settings -> menu -> device time) for your time if you can't figure
# out the correct timezone coding
# MinuteOTheDay="$(date -R +"%H%M")";

# Battery / low-energy mode:
# - check battery capacity once per hour
# - if battery < 20%, prefer battery images (quote_8888_*) every 10 minutes
BATTERY_LAST_HOUR_FILE="$BASEDIR/battery_last_hour"
BATTERY_LOW_FLAG_FILE="$BASEDIR/battery_low"
BATTERY_PERCENT_FILE="$BASEDIR/battery_percent"

low_battery=0
[ -f "$BATTERY_LOW_FLAG_FILE" ] && low_battery="$(cat "$BATTERY_LOW_FLAG_FILE" 2>/dev/null | tr -cd '0-9' || echo 0)"

last_hour="$(cat "$BATTERY_LAST_HOUR_FILE" 2>/dev/null | tr -cd '0-9' || echo '')"
if [ "$HourOfDay" != "$last_hour" ]; then
	# Probe capacity from common sysfs locations.
	# (Paperwhite-ish devices vary by model/kernel; scan any */capacity entry.)
	battery_cap=""
	for cap_file in /sys/class/power_supply/*/capacity; do
		if [ -f "$cap_file" ]; then
			battery_cap="$(cat "$cap_file" 2>/dev/null | tr -cd '0-9')"
			[ -n "$battery_cap" ] && break
		fi
	done

	if [ -n "$battery_cap" ]; then
		echo "$battery_cap" > "$BATTERY_PERCENT_FILE" 2>/dev/null || true
		if [ "$battery_cap" -lt 20 ]; then
			low_battery=1
		else
			low_battery=0
		fi
		echo "$low_battery" > "$BATTERY_LOW_FLAG_FILE" 2>/dev/null || true
		echo "timelit: battery check hour=$HourOfDay capacity=${battery_cap}% low=$low_battery"
	else
		echo "timelit: battery check hour=$HourOfDay could not read capacity"
	fi
	# Always mark this hour as "checked" to avoid re-probing every minute.
	echo "$HourOfDay" > "$BATTERY_LAST_HOUR_FILE" 2>/dev/null || true
fi

# If we're in low-battery mode and we're on a 10-minute boundary, and battery
# images exist, switch MinuteOTheDay to 8888 so the next selection uses quote_8888_*.
if [ "$low_battery" -eq 1 ]; then
	mod10="$(expr "$MinuteOfHour" % 10 2>/dev/null || echo 1)"
	if [ "$mod10" -eq 0 ]; then
		lines_bat="$(find "$BASEDIR/images/quote_8888"* 2>/dev/null | wc -l | tr -cd '0-9')"
		if [ "$lines_bat" -gt 0 ]; then
			MinuteOTheDay="8888"
			echo "timelit: low battery active; showing quote_8888_* for minute $HourOfDay:$MinuteOfHour"
		fi
	fi
fi

# Check if there is at least one image for this minute
lines="$(find "$BASEDIR/images/quote_$MinuteOTheDay"* 2>/dev/null | wc -l)"
if [ $lines -eq 0 ]; then
    echo "no images found for '$MinuteOTheDay', using placeholder (9999)"
    MinuteOTheDay="9999"
    lines="$(find "$BASEDIR/images/quote_$MinuteOTheDay"* 2>/dev/null | wc -l)"
    if [ $lines -eq 0 ]; then
        echo "no placeholder images (quote_9999_*) found, exiting"
        exit
    fi
fi
echo "$lines files found for '$MinuteOTheDay'"


# Randomly pick a png file for that minute (since we have multiple for some minutes)
ThisMinuteImage=$(find "$BASEDIR/images/quote_$MinuteOTheDay"* 2>/dev/null | python3 -c "import sys; import random; print(''.join(random.sample(sys.stdin.readlines(), 1)).rstrip())")

echo "$ThisMinuteImage" > "$BASEDIR/clockisticking"

# Flip the path to show the source if desired
if [ -f "$BASEDIR/showsource" ]; then
	# find the matching image with metadata
	ThisMinuteImage=$(echo $ThisMinuteImage | sed 's/.png//')_credits.png
	ThisMinuteImage=$(echo $ThisMinuteImage | sed 's/images/images\/metadata/')
fi

# Do a full repaint every 20 minutes
clearFlag=""
if echo "$MinuteOTheDay" | grep -q '^..[024]0$'; then
	clearFlag="-f"
fi

# Show that image (skip if path empty to avoid eips "option requires an argument" error)
if [ -n "$ThisMinuteImage" ] && [ -f "$ThisMinuteImage" ]; then
	eips $clearFlag -g "$ThisMinuteImage"
else
	echo "No image to show: ThisMinuteImage='$ThisMinuteImage'" >&2
fi

# If there's an upgrade status file, print it
#if [ -f "$BASEDIR/../updatestatus" ]; then
#    eips 0 39 "`cat $BASEDIR/../updatestatus`"
#fi
