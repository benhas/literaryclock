# Rules: Matching Minute of the Day to Highlighted Quote Text

These rules describe how the **minute of the day** (first column) in `litclock_annotated_br2.csv` corresponds to the **highlighted fragment** (second column) within the **full quote** (third column). They were reverse-engineered from that file for use by coding agents.

---

## 1. Data source and structure

- **File**: `quote to image/litclock_annotated_br2.csv`
- **Format**: Pipe-delimited (`|`). No header in the sense of CSV with commas; first row is header.
- **Columns**:
  1. **time** — Minute of the day in 24-hour form `HH:MM` (e.g. `00:00`, `07:30`, `12:15`, `19:45`).
  2. **timestring** — The fragment of the quote that is highlighted as denoting this time.
  3. **quote** — Full literary quote.
  4. **title** — Work title.
  5. **author** — Author name.
  6. (Sixth column; often `unknown`.)

- **Exclusion**: Ignore every row where the first column is **`99:99`**. Those are filler entries and do not represent a real minute.

---

## 2. Core matching principle

- The **timestring** (column 2) is a substring of the **quote** (column 3). It is the exact span of text that was chosen to be highlighted for that time.
- The **time** (column 1) is the minute of the day (24h) that the highlighted text is intended to denote.
- So: **time** ↔ **timestring** is the pairing; the **quote** is the context. When the link between time and highlight is not obvious (e.g. “the clock struck twelve”), the full quote is what disambiguates or justifies the choice.

---

## 3. Rules for what can match a given minute (HH:MM)

For a given `HH:MM`, the highlighted text (timestring) can be any phrase that:

1. **Appears verbatim in the quote** (allowing normalisation of whitespace and possibly casing where the same word form is used).
2. **Denotes that moment in the 24-hour day**, either exactly or as a conventional approximation (e.g. “about one o’clock”, “nearly six”).

The following forms are all valid ways to express a time and can therefore be used as the timestring for the corresponding minute.

### 3.1 Special names for 00:00 and 12:00

- **00:00 (midnight)**  
  - Words: `midnight`, `Midnight`.  
  - Also: `twelve o'clock`, `twelve o’clock`, `twelve` (when the quote clearly means midnight), `12.00 pm` in 24h/night contexts, `0000h`, `0000h.`.

- **12:00 (noon)**  
  - Words: `noon`, `Noon`, `High noon`.  
  - Also: `twelve o'clock`, `twelve o’clock`, `twelve` (when the quote clearly means midday).

### 3.2 Digital / numeric forms

- **With colons**: `HH:MM`, `H:MM` (e.g. `0:31`, `7:12`, `12:04`, `19:11`).
- **With full stops**: `HH.MM`, `H.MM` (e.g. `5.14am`, `6.33pm`, `12.28`, `7.35`).
- **With space before am/pm**: `12:04 P.M.`, `5:15 a.m.`, `6:30 p.m.`, `7:00 A.M.`, `1:08`, `12.04pm`, `1.37pm`, etc.
- **24-hour style**: `00:31`, `07:02`, `06:13`, `13:08`, `19:11`, `20:04`.
- **Military / timecode**: `0000h`, `0000h.`, `0005h`, `0627 hours`, `1320 hours`, `0 Hours, 12 Minutes`, `12:49 hours`.

Casing and spacing of “am”/“pm”/“a.m.”/“p.m.” and “AM”/“PM” may vary; all such variants are valid.

### 3.3 Word forms: hour only

- **On the hour**:  
  `one o'clock`, `one o’clock`, `seven o'clock`, `six o’clock`, `eight o'clock`, etc.  
  Also: `one`, `six`, `seven`, `eight`, `at six`, `at seven`, `At seven`, `six in the morning`, `one o'clock in the afternoon`, `one in the morning`, `struck one`, `clock strikes one`, `Seven o’clock`, `Six o’clock`, etc.

- **12-hour wording**:  
  `1 a.m.`, `1.00 am.`, `7 a.m.`, `7:00 A.M.`, `6:00 a.m.`, `six AM`, `six A.M.`, `1pm`, `1.00 p.m.`, `7.00 p.m.`, `8.00 p.m.`, etc.

### 3.4 Word forms: minutes past the hour

- **X minutes past [hour]**:  
  `a minute after midnight`, `one minute past midnight`, `two minutes past twelve`, `two minutes past midnight`, `five minutes after seven o'clock`, `six minutes past seven`, `ten minutes past one`, `twelve minutes past midnight`, `twenty-three minutes past midnight`, `thirty-two minutes past midnight`, `twenty-two minutes past twelve`, `seventeen minutes after twelve`, etc.

- **X past [hour]**:  
  `five past six`, `five past one`, `ten past six`, `eight minutes past seven`.

- **Quarter / half**:  
  `quarter past twelve`, `quarter-past seven`, `a quarter-past seven`, `fifteen minutes past seven`, `half-past twelve`, `half past midnight`, `half-past six`, `half past seven`, `half-past one`, etc.

- **Hyphenated or compound**:  
  `twelve-fifteen`, `six-twenty-five`, `five-twenty`, `seven-twenty`, `twelve-twenty`, `twelve-forty-three`, `six-seventeen`, `seven-nine`, etc.

### 3.5 Word forms: minutes to the next hour

- **X minutes to [hour]**:  
  `five minutes to one`, `six minutes to one`, `five minutes to six`, `ten minutes to eight`, `twenty to one`, `twenty to seven`, `twenty minutes to seven`, `quarter to seven`, `a quarter to one`, `quarter to eight`, `five to one`, `five to six`, `five to seven`, `five to eight`, `ten minutes to seven`, `eighteen minutes to one`, etc.

- **“To” phrasing**:  
  `twenty to one`, `twenty-five before six`, `twenty-five minutes to seven`, `twelve minutes to two`, `three minutes to two`, `two minutes to seven`, `four minutes to eight`, `a minute to eight`, etc.

### 3.6 Approximate or contextual phrases

- **Approximation**:  
  `about one o'clock`, `About one o’clock`, `nearly one o'clock`, `nearly six`, `almost at one in the morning`, `just before eight o' clock`, `a minute to eight`, `A minute to eight.`, `minute before seven-thirty`, `a minute short of six-thirty`, `around seven`, `about seven o'clock`, `a little after eight o'clock`, `around one-thirty`, `around quarter to one`, `around noon`, `around half past six`, etc.

- **Indirect reference**:  
  The quote may refer to the time via the clock (e.g. “the clock struck twelve”, “the hands of the clock pointed to…”, “the clock read 12.28”). The **timestring** is the exact fragment chosen to highlight (e.g. the numeral or the phrase that states the time). The full quote is used to interpret that the highlighted part denotes the given minute.

### 3.7 Train / schedule times

Times are often given as departure/arrival times: e.g. `the 7.39`, `the 12.26am`, `the six-fifty`, `the 12.14`, `the 6.25`, `the 19.45`. If such a phrase in the quote denotes the same minute as the first column, it is a valid timestring for that row.

---

## 4. Consistency and ambiguity

- **Same time, different phrasings**: Many rows share the same `HH:MM` but different quotes and different timestrings. Each row is one valid (time, highlight, quote) triple; the rules above summarise the range of allowed phrasings, not a single canonical form per minute.
- **AM/PM and 12h vs 24h**:  
  - 00:00 and 12:00 use the special names (midnight, noon) or “twelve” in context.  
  - Other hours can be written in 12h (with am/pm) or 24h; the timestring must still denote the same minute as the `HH:MM` in column 1.
- **Source of truth**: For any row, the **time** column is the minute of the day; the **timestring** is what appears in the **quote** and is highlighted. If in doubt, treat “the timestring is a substring of the quote and is the phrase chosen to denote that time” as the definition.

---

## 5. Summary for agents

1. Use **`quote to image/litclock_annotated_br2.csv`** (pipe-delimited). Skip rows where the first column is **`99:99`**.
2. **time** (column 1) = minute of day in 24h `HH:MM`.
3. **timestring** (column 2) = highlighted fragment; must appear in **quote** (column 3) and denote that minute.
4. Valid timestrings include: special names (midnight, noon); digital forms (with colons, dots, am/pm, 24h, military); word forms (o’clock, half-past, quarter past/to, X minutes past/to, hyphenated numbers); approximations (about, nearly, just before); and schedule-style times. Use the full quote when the link between time and highlight is indirect.
5. These rules are for matching and validating (time, highlight, quote) data and for generating or editing similar data (e.g. choosing or checking highlights for a given minute).
