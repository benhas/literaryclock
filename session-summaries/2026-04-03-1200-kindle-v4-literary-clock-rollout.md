# Session summary — 2026-04-03 ~12:00

**Rolling out the literary clock to a jailbroken Kindle 4 (non-touch), firmware 4.1.4, serial `90231703328203T3`, with SSH/usbnet.**

---

## Goals

- Confirm **display resolution** vs generated images (Kindle 4 = **600×800**).
- Deploy **timelit** + **Kindle 4** PNGs; start/stop via **`startstopClock.sh`**; reliable **per-minute** updates.
- Document quirks: **no Python** on device, **minimal shell**, **crond** / BusyBox, **timezone conf**.

---

## Device identification

- Serial prefix **`9023`** → **Kindle 4 NoTouch Black (2012)** ([MobileRead serial table](https://wiki.mobileread.com/wiki/Kindle_Serial_Numbers)).
- Panel **600×800**; firmware build does not change hardware resolution.

---

## Repository / script changes (this session)

| Area | Change |
|------|--------|
| **`quote to image/quote_to_image.py`** | Added **`DISPLAY_PROFILE`** (`paperwhite2` 758×1024 vs **`kindle4`** 600×800 + layout). |
| **`timelit/timelit.sh`** | Random PNG selection: **`python3`** if present at `/usr/bin/python3` or `/mnt/us/python/bin/python3`, else **`awk`** (no Kindle Python required). |
| **`timelit/showMetadata.sh`** | **Added** — `startstopClock.sh` requires it; runs **`waitforkey`** when present, else exits 0 (non-keyboard models). |
| **`timelit/startstopClock.sh`** | **`crond`** start: try **`-L` log path**, then **fallback without `-L`** for BusyBox that rejects **`-L`** (symptom: no **`timelit-cron.log`**, display stuck on first minute). |

---

## Environment notes on Kindle 4

- **`command -v`** unavailable (**`-sh: command: not found`**); use **`which`** / direct paths.
- **`python` / `python3`** not installed — **awk** path in **`timelit.sh`** used successfully.
- **`eips`** and **`crond`** at **`/usr/sbin/`** present.
- **`lipc-set-prop`** / **`com.lab126.powerd`** may error (**`lipcErrNoSuchSource`**); non-blocking for core clock.
- **Battery** capacity sysfs often missing — log line **`could not read capacity`**; expected.

---

## Deployment flow used

1. Set **`DISPLAY_PROFILE = 'kindle4'`**, run **`quote_to_image.py`**, copy **`quote_*.png`** to **`/mnt/us/timelit/images/`** (FTP drag-and-drop acceptable).
2. Copy **`timelit/`** to **`/mnt/us/timelit/`**; **`chmod +x`** shell scripts (**including `showMetadata*.sh`**).
3. Add **`conf/<MAC-dashes>.conf`** with **`export TZ='...'`** (Australian eastern: **`EST-10EDT`**-style strings from **`timelit/conf/timezones list`**). Resolved **`no conf found`** once MAC file present; log showed **`loaded conf '...00-bb-3a-06-c3-0b.conf'`**.
4. **`startstopClock.sh`** → first **`timelit.sh`** run OK; **`timelit-cron.log`** missing until **updated `startstopClock.sh`** ( **`crond`** **`-L`** fallback).
5. After fix: **`timelit-cron.log`** showed successive minutes (e.g. **`1418`**, **`1419`**). **`ps | grep crond`** not always visible; process may not appear as **`busybox`** in a simple grep — **log + changing image** treated as ground truth.

---

## Docs added / updated (post-session)

- **`agent-instructions/kindle-4-literary-clock.md`** — agent-oriented Kindle 4 rollout checklist.
- **`README.md`** — device profiles, optional Python on Kindle, **`showMetadata`**, **`crond`** fallback, chmod list.
- This file — session summary.

---

## Outcome

Literary clock **runs on Kindle 4** with **600×800** assets, **no device Python**, **MAC conf** for TZ, and **minute updates** via **`crond`** with **BusyBox-safe** startup. KUAL was deferred until after SSH workflow was stable.
