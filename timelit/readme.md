All the files you need to copy to /mnt/us/timelit

## Cronjob (updating every minute)

When you **start** the clock with `startstopClock.sh`, it now also starts **crond** so that `timelit.sh` runs every minute and the displayed quote image changes with the time. When you **stop** the clock, crond is stopped as well.

### Checking that the cronjob is working

On the Kindle (e.g. over SSH):

1. **Is crond running?**
   ```sh
   ps | grep crond
   ```
   You should see a line with `crond` (and possibly `-b`, `-c /mnt/us/timelit/cron`, etc.).

2. **Is the clock log growing every minute?**
   ```sh
   tail -5 /mnt/us/timelit/logs/timelit-cron.log
   ```
   Wait 1–2 minutes and run `tail` again. You should see new lines each minute (e.g. `timelit: loaded conf '...'`, `N files found for 'HHMM'`). If the file is empty or unchanged, cron is not running or the cron file is missing.

3. **Cron daemon log** (optional):
   ```sh
   cat /mnt/us/timelit/logs/crond.log
   ```
   Shows crond’s own messages (e.g. if it failed to start).

If the clock display doesn’t change: ensure you started it with `startstopClock.sh` (so crond was started), then run the checks above. If `timelit-cron.log` is growing but the screen doesn’t change, the issue may be with `eips` or the image path; check the log for errors.

## Stopping the clock

Run `./startstopClock.sh` again to stop the clock. On Kindle models without a framework init script, the last quote image will remain visible (the screen is not cleared). **Press the power button once** (sleep then wake) to return to the normal Kindle UI when you're ready.

## Screensaver while the clock runs

`startstopClock.sh` toggles the system screensaver behaviour via **lipc** when `lipc-set-prop` is available:

- **Clock start:** `lipc-set-prop com.lab126.powerd preventScreenSaver 1` — idle screensaver should not kick in while the clock is running (especially when `powerd` is still running because there is no `/etc/init.d/powerd` stop on your model).
- **Clock stop:** `preventScreenSaver 0` — normal idle/screensaver timeout returns.

On models that stop `powerd` via `/etc/init.d/powerd stop` while the clock runs, the lipc calls may no-op or fail harmlessly (`2>/dev/null`); stopping the clock still restores behaviour when `powerd` is started again.

To check the current value: `lipc-get-prop com.lab126.powerd preventScreenSaver` (`1` = prevent screensaver, `0` = allow).

## Battery low indication (quote_8888)

While the clock is running, `timelit.sh` does an **hourly** check of Kindle battery capacity.

- If battery is **< 20%**, then during that period:
  - on **every 10-minute boundary** (minutes `00,10,20,30,40,50`), the clock switches to images whose filenames start with `quote_8888` (e.g. `quote_8888_0.png`, `quote_8888_1.png`, ...).
  - other minutes continue to use the normal time-based quote images.

Internals (files created under `/mnt/us/timelit/`):
- `battery_last_hour`
- `battery_low`
- `battery_percent`

## Setting date and time to your local time

The clock picks an image by **minute of the day** (e.g. 14:30 → `quote_1430_*.png`). If you see “no images found”, the minute the script is using doesn’t match your images. Fix the Kindle’s time and/or timezone.

### 1. Set the Kindle’s system time (device time)

- On the Kindle: **Settings** → **Device Options** → **Device Time** (or **Date & Time**).
- Set to your local time, either:
  - **Set automatically** (if the Kindle can reach the network), or  
  - **Set manually** and enter your local date and time.

### 2. Tell the script to use “device time” (simplest)

If you set the Kindle time to your local time in Settings, you can make the script use that time directly:

1. On the Kindle, edit `/mnt/us/timelit/timelit.sh` (or edit locally and copy via SSH).
2. **Comment out** the line that uses `TZ`:
   ```sh
   # MinuteOTheDay="$(env TZ="$TZ" date -R +"%H%M")";
   ```
3. **Uncomment** the “ALTERNATIVE TIME KEEPING” line:
   ```sh
   MinuteOTheDay="$(date -R +"%H%M")";
   ```
4. Save. The script will then use whatever time is shown in **Settings → Device Time**.

### 3. Keep system time as UTC and set timezone in a conf file

If the Kindle stays on UTC (or another fixed time), you can keep the default script and only set your timezone in a **conf file** so the script *displays* your local time:

1. On the Kindle, get the WiFi MAC address:
   ```sh
   cat /sys/class/net/wlan0/address
   ```
   Example: `28:ef:01:28:de:16` → use filename `28-ef-01-28-de-16.conf`.

2. In `/mnt/us/timelit/conf/`, create or edit that file (e.g. `28-ef-01-28-de-16.conf`) and set `TZ` for your region, for example:
   - UK (GMT/BST):  
     `export TZ='GMT0BST,M3.5.0/1:00:00,M10.5.0/2:00:00'`
   - US Eastern:  
     `export TZ='EST5EDT'`
   - US Pacific:  
     `export TZ='PST8PDT'`
   - US Central:  
     `export TZ='CST6CDT'`
   - Fixed offset (e.g. UTC+1, no DST):  
     `export TZ='GMT-1'`

3. The script loads this file automatically. No need to make the script executable again unless you replaced the file.
