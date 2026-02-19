# Step 1 — Generate images

Instructions for an AI coding agent to generate quote images using the Python script in the `quote to image` folder.

## Prerequisites

1. **Python 3.6+** must be available. Check with:
   ```bash
   python3 --version
   ```

2. **Pillow** must be installed. Install if needed:
   ```bash
   pip3 install pillow
   ```

## Required files in `quote to image`

Before running the script, ensure these exist in the same folder as `quote_to_image.py`:

- `litclock_annotated_br2.csv` — quote data (pipe `|` delimited)
- `bookerly.ttf` — font for normal text
- `bookerlybold.ttf` — font for highlighted (time) text
- `baskervilleboldbt.ttf` — font for author/title (metadata)

If any font or the CSV is missing, report it and do not run the script until the user provides them or they are present.

## Execute image generation

1. **Create the output directory** if it does not exist (the script does not create it):
   ```bash
   mkdir -p "/Users/benhas/Code/literaryclock/quote to image/images"
   ```
   If generating without metadata, also create: `quote to image/images/nometadata/`

2. **Change directory** to the quote-to-image folder (from the repository root):
   ```bash
   cd "quote to image"
   ```
   Or using the absolute path:
   ```bash
   cd /Users/benhas/Code/literaryclock/quote\ to\ image
   ```

3. **Run the script** (from inside `quote to image`):
   - To generate images for **all** quotes in the CSV:
     ```bash
     python3 quote_to_image.py
     ```
   - To generate only the **first N** images (e.g. 5), pass a number:
     ```bash
     python3 quote_to_image.py 5
     ```

4. **Output locations** (the `images/` directory must exist before running; see step 1):
   - With metadata (default): `quote to image/images/` — files like `quote_HHMM_0.png`
   - Without metadata: set `include_metadata = False` in `quote_to_image.py` (line 17); output goes to `quote to image/images/nometadata/`

## Optional configuration (edit before running)

Edit `quote to image/quote_to_image.py` only if the user requests:

- **No author/title on images:** set `include_metadata = False` (line 17).
- **Different CSV:** set `csvpath` (line 13) to the filename in the same folder.
- **Different fonts:** set `fntname_norm`, `fntname_high`, `fntname_mdata` (lines 21–23) and ensure the corresponding `.ttf` files are in `quote to image/`.
- **Limit count for testing:** pass a number as the first argument when running the script (e.g. `python3 quote_to_image.py 5`).

## Verification

- After a successful run, PNG files should appear under `quote to image/images/` (or `quote to image/images/nometadata/` if metadata is disabled).
- If the script prints `WARNING: missing timestring at csv line X`, that row is skipped; the rest still run.
- On `KeyboardInterrupt` (Ctrl+C), the script exits with the message "I hate work".

## CSV format reference

Each non-header line: `24h time|timestring|quote|Book Title|Author`  
Example: `16:15|quarter past four|At a quarter past four he stumbled home drunk|Foo-Book Title|Bar-Author`  
Edit the CSV in a text editor, not Excel, to avoid breaking on commas inside quotes.
