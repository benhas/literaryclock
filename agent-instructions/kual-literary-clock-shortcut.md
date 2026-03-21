# KUAL shortcut — Literary Clock

Instructions for installing the **Literary Clock** entry in **KUAL** (Kindle Unified Application Launcher) so the user can start/stop the clock from the launcher instead of only SSH.

---

## What appears in KUAL

After a correct install, KUAL’s **top-level menu** includes an entry **Literary Clock** (alongside built-in items like USBNetwork, Rename OTA binaries, etc.). Opening it shows **Toggle Clock**, which runs `/mnt/us/timelit/startstopClock.sh`.

Source files in this repo: `extensions/literaryclock/` (`config.xml`, `menu.json`, optional `README.md`).

---

## Critical requirement: `config.xml` + `menu.json`

**KUAL2 does not load an extension from `menu.json` alone.**

It scans `/mnt/us/extensions/` (and subfolders per `KUAL_search_depth` in `KUAL.cfg`) for **`config.xml`**. That file points to `menu.json`. Extensions that only had `menu.json` in a folder will **never** show in KUAL—even if `menu.json` is valid JSON.

Working extensions on the Kindle (e.g. **USBNetwork**) always ship both:

- `config.xml` — declares the extension and `<menu type="json" dynamic="true">menu.json</menu>`
- `menu.json` — defines buttons and actions

The Literary Clock extension must follow the same pattern.

---

## Installation on the Kindle

1. **Copy the whole folder** from the repo to the Kindle:
   - From: `extensions/literaryclock/`
   - To: `/mnt/us/extensions/literaryclock/`
   - Required files on the device:
     - `/mnt/us/extensions/literaryclock/config.xml`
     - `/mnt/us/extensions/literaryclock/menu.json`

2. **Make the clock script executable** (if not already):
   ```sh
   chmod +x /mnt/us/timelit/startstopClock.sh
   ```

3. **Restart KUAL** or reboot the Kindle so menus are rescanned.

---

## Copy from a computer (examples)

From the repository root (adjust `kindle` to your SSH host):

```sh
scp -r extensions/literaryclock kindle:/mnt/us/extensions/
ssh kindle 'chmod +x /mnt/us/timelit/startstopClock.sh'
```

Or copy only the two required files if the folder already exists:

```sh
scp extensions/literaryclock/config.xml extensions/literaryclock/menu.json kindle:/mnt/us/extensions/literaryclock/
```

---

## Verify on the Kindle (SSH)

```sh
ls -l /mnt/us/extensions/literaryclock/
cat /mnt/us/extensions/literaryclock/config.xml
python3 -c "import json; json.load(open('/mnt/us/extensions/literaryclock/menu.json')); print('menu.json OK')"
ls -l /mnt/us/timelit/startstopClock.sh
```

Expected:

- `config.xml` contains `<extension>`, `<information>`, `<menus>`, and `<menu type="json" dynamic="true">menu.json</menu>` (same idea as `/mnt/us/extensions/usbnet/config.xml`).
- `menu.json` parses without error.
- `startstopClock.sh` exists and is executable (`-rwx`).

---

## Troubleshooting

| Symptom | Likely cause |
|--------|----------------|
| **Literary Clock** never appears at top level | Missing **`config.xml`** in `/mnt/us/extensions/literaryclock/` — add it and restart KUAL. |
| JSON is valid but menu still missing | Same as above; KUAL2 discovers extensions via `config.xml`, not by scanning for `menu.json` alone. |
| Button does nothing | `startstopClock.sh` not executable or wrong path in `menu.json`. |
| Other extensions show errors | Open KUAL’s **KUAL** submenu for extension/log messages (KUAL2 logs invalid extensions there). |

---

## Reference: `config.xml` shape

Match the structure used by other extensions on the device (e.g. USBNetwork). The Literary Clock repo ships:

- `extensions/literaryclock/config.xml`
- `extensions/literaryclock/menu.json`

Do not duplicate `menu.json` at `/mnt/us/extensions/menu.json` unless you intend a different extension layout; the standard is one subfolder per extension under `/mnt/us/extensions/<name>/`.

---

## End-user doc

See also `extensions/literaryclock/README.md` for a shorter install note.
