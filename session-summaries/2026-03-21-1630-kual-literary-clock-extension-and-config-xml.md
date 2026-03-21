# Session summary — 2026-03-21 ~16:30

**KUAL shortcut for Literary Clock: troubleshooting, root cause, fix, and documentation.**

---

## Goal

Add a **KUAL** menu entry so the literary clock can be toggled from the launcher (not only via SSH), using the extension under `extensions/literaryclock/`.

---

## What we tried first

- Copied **`menu.json`** (and folder contents) to `/mnt/us/extensions/literaryclock/`.
- Confirmed on-device:
  - `/mnt/us/timelit/startstopClock.sh` exists and is **executable**.
  - `/mnt/us/extensions/literaryclock/menu.json` **parses** as valid JSON (`python3 -c "import json; ..."`).
  - `/mnt/us/extensions/KUAL.cfg` only contained `KUAL_sort_mode="ABC"` (nothing obviously blocking extensions).
- Restarted KUAL and rebooted the Kindle — **Literary Clock still did not appear** in the top-level menu.

**Observed KUAL top level:** KUAL, Helper, Rename OTA binaries, USBNetwork, Quit — i.e. other extensions loaded, but not literaryclock.

---

## Corrections / dead ends

1. **`menu.json` schema tweaks**  
   Adjusted optional fields (e.g. `internal` prefixed with `status …`, removed `exitmenu`) to align with common KUAL2/KOReader-style examples. **This did not fix visibility** — the extension still never registered.

2. **SSH intermittently refused**  
   `ssh kindle` sometimes returned **Connection refused** to the Kindle’s Wi‑Fi IP; user resumed debugging when usbnet/SSH was available again.

3. **Log / package discovery**  
   Searches for KUAL-related files under `/mnt/us/mrpackages`, `/tmp`, `/var/log` did not surface obvious logs in the snippets shared; the decisive fix did not depend on logs.

---

## Root cause

**KUAL2 discovers extensions via `config.xml`, not by finding `menu.json` alone.**

Per MobileRead’s KUAL2 documentation: KUAL scans `/mnt/us/extensions/` (subject to search depth / excludes in `KUAL.cfg`) for **`config.xml`**, reads the `<menu type="json" …>` tag (typically `menu.json`), and only then loads that JSON.

Working extensions on the device (**USBNetwork**, **Rename OTA binaries**) include **`config.xml`** alongside **`menu.json`**. The literaryclock folder initially had only **`menu.json`**, so KUAL **never loaded** the extension despite valid JSON.

---

## Fix (what worked)

1. Added **`extensions/literaryclock/config.xml`** in the repo, matching the same structural pattern as USBNetwork:
   - `<extension>` → `<information>` → `<menus>` → `<menu type="json" dynamic="true">menu.json</menu>`

2. User copied **`config.xml`** and **`menu.json`** to `/mnt/us/extensions/literaryclock/` and restarted KUAL.

3. **Result:** **Literary Clock** appeared in KUAL’s top-level menu; **Toggle Clock** runs `/mnt/us/timelit/startstopClock.sh`.

---

## Files created or updated (repository)

| Path | Action |
|------|--------|
| `extensions/literaryclock/config.xml` | **Added** — required for KUAL2 extension discovery |
| `extensions/literaryclock/menu.json` | **Updated** during session (schema tweaks; final working combo with `config.xml`) |
| `extensions/literaryclock/README.md` | **Updated** — notes that both `config.xml` and `menu.json` are required |
| `agent-instructions/kual-literary-clock-shortcut.md` | **Added** — agent-oriented install/troubleshooting for KUAL |
| `session-summaries/2026-03-21-1630-kual-literary-clock-extension-and-config-xml.md` | **Added** — this file |

---

## Quick reference for future sessions

- Install path on Kindle: `/mnt/us/extensions/literaryclock/` with **both** `config.xml` and `menu.json`.
- Compare with a known-good extension: `cat /mnt/us/extensions/usbnet/config.xml` vs `cat /mnt/us/extensions/literaryclock/config.xml`.
- Copy from repo root (example):  
  `scp extensions/literaryclock/config.xml extensions/literaryclock/menu.json kindle:/mnt/us/extensions/literaryclock/`

---

## Outcome

KUAL shortcut **works** after adding **`config.xml`**. Earlier confusion was due to assuming `menu.json` alone was sufficient for KUAL2.
