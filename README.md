# literaryclock
Repurposing a Kindle into a clock which tells time entirely through real book quotes. A fascinating conversation piece as well as a beautiful and functional clock.

Non-destructive, the clock can be exited and the Kindle used as normal at any point.

Every time is from a real book quote and the current selection of quotes runs to slightly over 2300+ times for the 1440 minutes of a day. Every quote has the time preserved in it's original written format which means times can vary from 24h clock (1315h) to written format (twenty and seven past three). There are still a number of times still missing and some quotes are vague enough to be used to fill in some gaps.

This repository is a fork of [elegantalchemist/literaryclock](https://github.com/elegantalchemist/literaryclock) with changes for newer Kindle models, optional operation without Launchpad, and a different cron setup. See [Changes from the original repository](#changes-from-the-original-repository) below.

<p align="center">
<img src="https://github.com/elegantalchemist/literaryclock/blob/main/images/literaryclockrunning.jpg" height="600">
</p>

## Materials
* **Kindle** — Originally developed for Kindle 3 Keyboard; this fork has been tested on newer models (e.g. without `/etc/init.d/framework`). Scripts use `python3` and avoid reliance on Launchpad for start/stop.
* **Computer connection** for use with SSH and transferring files

## Build Overview
The overview is fairly simple. Jailbreak the Kindle, install USBNetwork (and optionally Launchpad), install Python. Copy the timelit folder (and images) to the Kindle, configure timezone, then either use the **original** method (Launchpad + system crontab) or this fork’s **alternative** method (no Launchpad required, cron via `crond` and a writable cron dir under `/mnt/us/timelit`).

Start and stop the clock by running `./startstopClock.sh` (or via a KUAL menu item or Launchpad key combo). Detailed timezone and stop instructions are in `timelit/readme.md`.

* **WARNING** None of this is what the Kindle is designed to do and it's not hard to get it wrong and brick the Kindle. Do not proceed unless you are comfortable with this risk.

## **Step 1 - Make Some Images**
* Run the quote_to_image python script to generate your images in the 'images' folder. The script is designed to run in the same folder as the quotes csv file. There are various things you can do at this point - change fonts, link the files in different ways, etc.
* If you prefer to generate images without the author and title in them, you can change the line that says "include_metadata" to "False". These will be saved to /images/nometadata/ by default.
* You'll need to have Python and the Pillow module installed - `pip3 install pillow`. Installing Python is OS dependent but otherwise very straightfoward.
* The end result is you should have a folder containing 2,300+ images. This folder can be copied into the timelit folder so they run like .../timelit/images/.
* When it comes to copy the timelit folder across this can be done in one step, scripts and images all together.
* Generating the images should take less than 5 minutes. If this is a problem for you, I have included a zipped folder with all the metadata images also.
* There's also an older, PHP version of this script (requires Imagick and gd), which produces similar results. It's a bit less accurate and a chore to setup, so use at your own risk.

## **Step 2** - Jailbreak the Kindle and install appropriate software — see the sources folder for these files
* **Optional but useful** Update the Kindle Amazon firmware to the newest; this helps with time and date setting in the background. Firmwares available here — pay attention to your serial number: https://www.amazon.com/gp/help/customer/display.html?nodeId=GX3VVAQS4DYDE5KE
* **Jailbreak the Kindle** Connect the Kindle to USB, extract and copy over the jailbreak install file (directly to the root of the visible USB storage section, not into any folders) for the correct Kindle model. Disconnect from USB, Menu → Settings → Menu → Update. When you reconnect to USB it will now have a linkjail folder. Find your code for the jailbreak files here: https://wiki.mobileread.com/wiki/Kindle_Serial_Numbers
* **Install Launchpad** (optional in this fork) Same as before, copy over the appropriate launchpad files, update, restart. It will now have a launchpad folder. You can start/stop the clock without Launchpad by running `startstopClock.sh` (e.g. via SSH or KUAL).
* **Install usbNetwork** Same as before, copy over the appropriate usbnetwork files, update, restart. It will now have a usbnet folder.
* **Install Python** Same as before, copy over the appropriate python files, update, restart. It will now have a python folder. The scripts in this fork use `python3`.


## **Step 3** - Install the scripts for this project
* Connect the Kindle to USB and you will see the storage on your computer available. This is `/mnt/us/` in the Linux filesystem, so it's easier to copy and paste over USB than using rsync or SSH.
* Copy the timelit folder into `/mnt/us` so you have `/mnt/us/timelit/` with the scripts and the quote images in `/mnt/us/timelit/images/` (either from `quote to image/images/` or `images/nometadata/`).
* **Timezone config:** In `timelit/conf/`, create or rename a config file to your WiFi MAC address (lowercase, hyphens instead of colons). Get it with `cat /sys/class/net/wlan0/address` on the Kindle (e.g. `74:75:48:a7:77:5b` → `74-75-48-a7-77-5b.conf`). This fork’s `timelit.sh` also looks for `<mac-with-colons>.conf` and `default.conf`. Edit the file to set your timezone, e.g. `export TZ='EST5EDT'`. See `timelit/readme.md` and `timelit/conf/timezones list` for examples.
* Copy the utils folder to `/mnt/us/` if you use the original cron/clean-clock method below.
* If you use **Launchpad**, copy `startClock.ini` to `/mnt/us/launchpad/` (key combo for SSH and clock). Restart the Kindle so key combos are active.
* If you use **KUAL**, copy the `extensions/literaryclock` folder to `/mnt/us/extensions/` so you have `/mnt/us/extensions/literaryclock/menu.json`. Restart KUAL or reboot your Kindle for the menu to appear. See `extensions/literaryclock/README.md` for details on checking your KUAL version.
* Activate SSH over Wi‑Fi by editing the `config` file in `/mnt/us/usbnet/etc` and set “allow ssh over wifi” to true.
* Make the scripts executable (e.g. over SSH): `chmod +x /mnt/us/timelit/timelit.sh /mnt/us/timelit/startstopClock.sh`

### Starting the clock and updating every minute

You can use either the **original** method (system crontab + Launchpad) or this fork’s **alternative** (no root filesystem write, no Launchpad required).

**Option A — Original: system crontab + Launchpad**
* SSH in, then:
  ```sh
  mntroot rw
  nano /etc/crontab/root
  # Add: * * * * * /bin/sh /mnt/us/timelit/timelit.sh
  # Save (ctrl+x, yes). Then:
  cp /mnt/us/utils/clean-clock.sh /etc/init.d/clean-clock
  cd /etc/rcS.d && ln -s ../init.d/clean-clock S77clean-clock
  mntroot ro
  reboot
  ```
* After reboot: Shift+release, then C starts the clock; Shift+C again stops it and returns to normal.

**Option B — This fork: crond from user storage (no Launchpad required)**

On some Kindles, `crontab` fails (e.g. `/var/spool/cron/crontabs` missing). You can run `crond` with a cron directory under `/mnt/us/timelit`:

1. On the Kindle (e.g. via SSH): `mkdir -p /mnt/us/timelit/cron /mnt/us/timelit/logs`
2. Create the crontab file:  
   `echo '* * * * * /mnt/us/timelit/timelit.sh >>/mnt/us/timelit/logs/timelit-cron.log 2>&1' > /mnt/us/timelit/cron/root`
3. Start the clock and crond:
   - Start clock: `cd /mnt/us/timelit && ./startstopClock.sh`
   - Start minute-updates: `crond -b -c /mnt/us/timelit/cron -L /mnt/us/timelit/logs/crond.log`
4. To stop: run `./startstopClock.sh` again to exit clock mode; `killall crond` to stop the cron updates.

* **Start/stop:** Run `./startstopClock.sh` once to start the clock (and, if you use Option B, start `crond` as above). Run `./startstopClock.sh` again to stop and return to the Kindle UI. On some models the menu bar may not reappear immediately — press the power button once if needed. See `timelit/readme.md` for stopping and timezone details.
* This project disables the metadata function so no buttons affect the clock while it’s running. Non-destructive: the Kindle can be used normally when the clock is stopped.

## Changes from the original repository

This fork ([elegantalchemist/literaryclock](https://github.com/elegantalchemist/literaryclock)) adds or changes the following:

| Area | Original | This fork |
|------|----------|-----------|
| **Launchpad** | Required for Shift+C start/stop. | Optional. Start/stop via `./startstopClock.sh` (e.g. SSH or KUAL). |
| **Cron** | System crontab: `mntroot rw`, edit `/etc/crontab/root`, install `clean-clock` in `/etc/init.d`. | Supports **Option B**: run `crond -c /mnt/us/timelit/cron` with crontab in `timelit/cron/root` — no root filesystem write. Handy when `crontab` fails (e.g. missing `/var/spool/cron/crontabs`). |
| **Python** | Scripts call `python`. | Scripts call `python3` (Kindle typically has `python3` only). |
| **Newer Kindles** | Assumes `/etc/init.d/powerd` and `/etc/init.d/framework` exist. | `startstopClock.sh` checks for these; if absent, restores UI via `lipc-set-prop` and full eips refresh to reduce ghosting. |
| **Config loading** | Single MAC-named conf file. | `timelit.sh` tries, in order: `<mac-with-dashes>.conf`, `<mac-with-colons>.conf`, `default.conf`, and logs what was loaded. |
| **Missing minute** | No image for current minute could cause script to exit or show nothing. | Fallback to placeholder images (`quote_9999_*.png`) when no image exists for the current minute; CSV includes placeholder quotes. |
| **Screensaver** | Stopping powerd (when present) prevents screensaver. | Same; plus documented: `lipc-set-prop com.lab126.powerd preventScreenSaver 1` to keep screen on when powerd is running. |
| **Docs** | Inline in main README. | Extra `timelit/readme.md` for timezone, device time, stopping, and power-button workaround. |

## Uninstall
* All of the source files also have 'uninstall' variants to remove them from the Kindle if you wished to take it right back to the start.
* Delete all the folders and files you created yourself (but not the ones created by the updates like usbnet, python etc)
* Copy across the uninstall variants of each update one at a time and apply as an update, python, usbnet, launchapd, jailbreak.

## Credits
* **Original literaryclock repo** — [elegantalchemist/literaryclock](https://github.com/elegantalchemist/literaryclock) (this repo is a fork with the changes listed above).
* The original project instructables by tjaap — https://www.instructables.com/Literary-Clock-Made-From-E-reader/
* Updated and modified scripts for running it by knobunc — https://github.com/knobunc/kindle-clock
* Hugely expanded list of quotes from JohannesNE — https://github.com/JohannesNE/literature-clock
* Original project ideas and crowdsourced quotes — the Guardian — http://litclock.mohawkhq.com/

## NSFW Warning
A number of the literary quotes contain NSFW language. I have little to no interest in filtering them out and they remain here unredacted. If you wanted to you could do a ctrl+f search and replace for common profanity through the quotes.
