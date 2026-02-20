# Literary Clock KUAL Extension

This KUAL extension adds menu items to control the literary clock.

## Installation

1. Copy the `literaryclock` folder to your Kindle's `/mnt/us/extensions/` directory
2. Ensure the `startstopClock.sh` script is executable:
   ```bash
   chmod +x /mnt/us/timelit/startstopClock.sh
   ```
3. Restart KUAL or your Kindle for the menu to appear

## Usage

After installation, you'll see a "Literary Clock" menu in KUAL with:

- **Toggle Clock** - Toggles the clock on or off. If the clock is running, it will stop it and return to the Kindle UI. If the clock is stopped, it will start it and begin displaying literary quotes.

## How to Check Your KUAL Version

To determine which version of KUAL your Kindle is running:

### Method 1: Check Installation Files (Most Reliable)
1. Connect your Kindle to your computer via USB
2. Navigate to the `mrpackages` folder on your Kindle
3. Look for files named `Update_KUALBooklet_*_install.bin`
4. The version number is typically in the filename (e.g., `Update_KUALBooklet_2.4_install.bin` means version 2.4)

### Method 2: Check KUAL Log File
1. SSH into your Kindle
2. Check the KUAL log file (location varies by setup, commonly in `/mnt/us/extensions/` or `/var/log/`)
3. Look for version information in the log

### Method 3: Check KUAL Interface
1. Launch KUAL on your Kindle
2. Some versions display version information in the menu or about screen
3. Look for an "About" or "Info" option in the KUAL menu

### Method 4: Check Device Model
- **Modern Kindles** (released after 2012): Typically use KUAL (Coplate) version
- **Legacy devices**: May use KUAL v2.7.37 or earlier versions
- Current public release for KUAL2 is version 2.4

## Menu File Format Compatibility

This extension uses the standard KUAL2 menu.json format, which is compatible with:
- KUAL2 v2.4 and later
- KUAL (Coplate) versions
- Most KUAL v2.7.x versions

If you're using an older version of KUAL (pre-2.0), you may need to use a different format. Check the KUAL documentation for your specific version.

## Troubleshooting

If the menu doesn't appear:
1. Verify the folder structure: `/mnt/us/extensions/literaryclock/menu.json`
2. Check that `menu.json` has valid JSON syntax (no trailing commas, proper quotes)
3. Ensure `startstopClock.sh` is executable
4. Restart KUAL or reboot your Kindle
5. Check KUAL's log file for error messages
