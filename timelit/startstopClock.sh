#!/bin/sh

BASEDIR="/mnt/us/timelit"

clockrunning=1

# check if the clock 'app' is not running (by checking if the clockisticking file is there) 
test -f "$BASEDIR/clockisticking" || clockrunning=0

if [ $clockrunning -eq 0 ]; then

	# Stop power management and framework (if available on this Kindle model)
	[ -f /etc/init.d/powerd ] && /etc/init.d/powerd stop
	[ -f /etc/init.d/framework ] && /etc/init.d/framework stop

	# When powerd is still running (no init script, or other setups), keep the clock visible:
	# 1 = do not start screensaver on idle; restored to 0 when the clock stops.
	if command -v lipc-set-prop >/dev/null 2>&1; then
		lipc-set-prop com.lab126.powerd preventScreenSaver 1 2>/dev/null || true
	fi
	
	eips -c  # clear display
	#echo "Clock is not ticking. Lets wind it."
	#eips "Clock is not ticking. Lets wind it."

	# run showMetadata.sh to enable the keystrokes that will show the metadata
    sh "$BASEDIR/showMetadata.sh"

    touch "$BASEDIR/clockisticking"
    sh "$BASEDIR/timelit.sh"

	# Start crond so the display updates every minute (cron runs timelit.sh each minute)
	mkdir -p "$BASEDIR/cron" "$BASEDIR/logs"
	if [ ! -f "$BASEDIR/cron/root" ]; then
		echo '* * * * * /mnt/us/timelit/timelit.sh >>/mnt/us/timelit/logs/timelit-cron.log 2>&1' > "$BASEDIR/cron/root"
	fi
	killall crond 2>/dev/null || true
	# BusyBox on some Kindles (e.g. older firmware) does not support -L; crond exits and no updates run.
	crond -b -c "$BASEDIR/cron" -L "$BASEDIR/logs/crond.log" 2>/dev/null || \
		crond -b -c "$BASEDIR/cron" 2>/dev/null || true

else

    rm "$BASEDIR/clockisticking"
	# Stop cron so timelit.sh is no longer run every minute
	killall crond 2>/dev/null || true
	# Quietly stop metadata watcher (may not be running if script name differs)
	killall showMetadata.sh showMetadataOLD.sh waitforkey 2>/dev/null || true

	# Restart framework and power management (if available on this Kindle model)
	if [ -f /etc/init.d/framework ]; then
		eips -c  # clear display
		/etc/init.d/framework start
		[ -f /etc/init.d/powerd ] && /etc/init.d/powerd start
		else
		# No framework init script: try to bring Home UI back.
		# (Some Kindle models don't have /etc/init.d/framework but still have appmgrd.)
		# Force a full refresh/clear first to avoid partial-refresh ghosting.
		eips -f -c 2>/dev/null || eips -c 2>/dev/null || true
		[ -w /proc/keypad ] && echo "send 102" >/proc/keypad 2>/dev/null || true
		if command -v lipc-set-prop >/dev/null 2>&1; then
			lipc-set-prop com.lab126.appmgrd start app://com.lab126.booklet.home 2>/dev/null || true
		fi
		:
	fi

	# Re-enable normal screensaver / idle behaviour when leaving clock mode
	if command -v lipc-set-prop >/dev/null 2>&1; then
		lipc-set-prop com.lab126.powerd preventScreenSaver 0 2>/dev/null || true
	fi

fi