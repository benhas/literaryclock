1. Read the file called "minute-highlight-quote-rules.md"
2. Traverse the csv file called "litclock_annotated_br2.csv"
3. The first column indicates the minute of the day in a 24 hr format.
4. For each missing minute, search for a literary quote so it can be populated in the same format as the file: minute, quote highlight, quote, book or text title, author, and "unknown" (I don't know what the last column is for).
5. Finding multiple quotes per minute is acceptable to add to the file.
6. Write the results in a file called "missing-minutes-log.json" indicating the status of the search, the minute found, the quote, or the reason why a found quote was not added.