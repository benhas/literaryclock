# Agent instructions — Literary clock on Kindle 4 (non-touch)

Use this checklist when deploying this fork to a **Kindle 4**–class device (e.g. serial prefix **`9023`** / **`B023`** black, **`B00E`** silver per [MobileRead Kindle serial numbers](https://wiki.mobileread.com/wiki/Kindle_Serial_Numbers)). Firmware build ID does not change the panel resolution.

---

## 1. Panel resolution and image generation

- Native **full-screen** resolution: **600×800** (not 758×1024 Paperwhite 2).
- In **`quote to image/quote_to_image.py`**, set:
  ```python
  DISPLAY_PROFILE = 'kindle4'
  ```
  Regenerate PNGs on a host with Python + Pillow:
  ```bash
  mkdir -p "quote to image/images"
  cd "quote to image"
  python3 quote_to_image.py
  ```
- Deploy only these PNGs to **`/mnt/us/timelit/images/`** on the device.

---

## 2. Runtime: Python on the device is optional

- Many Kindle 4 setups have **no `python3`** on PATH (and some shells lack a `command` builtin—use `which`, not `command -v`).
- **`timelit/timelit.sh`** uses **`python3`** when `/usr/bin/python3` or `/mnt/us/python/bin/python3` exists; otherwise it uses **`awk`** to pick a random matching PNG. Do not require a Kindle Python install for the clock to run.

---

## 3. Files that must exist under `/mnt/us/timelit/`

- **`timelit.sh`**, **`startstopClock.sh`**, **`showMetadata.sh`**, **`showMetadataOLD.sh`** — `startstopClock.sh` invokes **`showMetadata.sh`** on start; without it, start fails.
- **`showMetadata.sh`** may **no-op** on models without `/usr/bin/waitforkey` (no keyboard); that is fine.
- **`images/`** — all **`quote_HHMM_*.png`** for the dataset, plus **`quote_9999_*`** placeholders and optional **`quote_8888_*`** battery quotes if generated.

---

## 4. Executable bits

After FTP/USB copy, set execute permission (FTP often drops it):

```sh
chmod +x /mnt/us/timelit/timelit.sh \
        /mnt/us/timelit/startstopClock.sh \
        /mnt/us/timelit/showMetadata.sh \
        /mnt/us/timelit/showMetadataOLD.sh \
        /mnt/us/timelit/version.sh
```

---

## 5. Timezone (`conf/`)

- **`timelit.sh`** loads, in order: `conf/<wlan0-MAC-with-dashes>.conf`, `conf/<MAC-with-colons>.conf`, `conf/default.conf`.
- The WiFi MAC comes from **`cat /sys/class/net/wlan0/address`** (may be a usb/gadget style MAC on some setups).
- **Exactly one** of MAC-named **`export TZ='...'`** or **`default.conf`** is enough; see **`timelit/conf/timezones list`**. Australian eastern often uses `EST-10EDT` forms (Australian “EST”, not US Eastern).
- If **`timelit-cron.log`** or stdout shows **`no conf found`**, add **`default.conf`** or the dashed-MAC file until **`loaded conf '...'`** appears.

Alternative: **device time only** — edit **`timelit.sh`** to use **ALTERNATIVE TIME KEEPING** per **`timelit/readme.md`**.

---

## 6. Starting / stopping

```sh
cd /mnt/us/timelit
./startstopClock.sh    # start (or stop if already running — toggles)
```

- First run stops framework/powerd when those init scripts exist (Kindle 4 typically has them).
- **`lipc-set-prop com.lab126.powerd preventScreenSaver`** may log **`lipcErrNoSuchSource`** on older firmware; often harmless if the display still updates.
- **Battery sysfs** may be missing → **`could not read capacity`** in logs; normal; low-battery **`quote_8888_*`** mode may not trigger.

---

## 7. Minute updates (`crond`)

- **`startstopClock.sh`** creates **`/mnt/us/timelit/cron/root`**, runs **`killall crond`**, then starts **`crond -b -c /mnt/us/timelit/cron`**, **with a fallback** if **`-L`** is unsupported (older BusyBox exits when `-L` is passed—**always ship the current `startstopClock.sh`** from this repo).
- **Success criterion:** **`/mnt/us/timelit/logs/timelit-cron.log`** gains a new line about each minute while the clock is **on**. **`ps | grep crond`** may be empty if the process name is not visible as `crond`; trust the log and the changing image.
- **`cron/root`** must use **Unix line endings** (no `\\r`). Repair with:
  ```sh
  printf '%s\n' '* * * * * /mnt/us/timelit/timelit.sh >>/mnt/us/timelit/logs/timelit-cron.log 2>&1' > /mnt/us/timelit/cron/root
  ```

---

## 8. Optional metadata / credits images

- Do **not** create **`/mnt/us/timelit/showsource`** unless **`images/metadata/*_credits.png`** exists, or **`timelit.sh`** will point **`eips`** at missing files.

---

## 9. KUAL (after SSH clock works)

- Install **`extensions/literaryclock/`** to **`/mnt/us/extensions/literaryclock/`** with **both** **`config.xml`** and **`menu.json`** (see **`agent-instructions/kual-literary-clock-shortcut.md`**).

---

## 10. Reference docs in repo

- **`timelit/readme.md`** — cron checks, stopping, screensaver, battery behavior.
- **`README.md`** — fork overview, Step 1–3, Option B cron.
- **`agent-instructions/Step 1 - generate images.md`** — CSV, fonts, `DISPLAY_PROFILE` note in main README / this file.
