1. traverse the file called "litclock_annotated_br2.csv"
2. the first column of the file corresponds to a minute of the day in a 24 hr format.
3. the third column is a literary quote that corresponds to the minute of the day in the first column.
4. the second column is a fragment of the text which is highlighted.
5. reverse engineer the rules to match the minute of the day in the first column with the highlighted text in the second column. Consider the full quote in the third column in case the relationship between the first and second column is not straightforward. 
6. Write the rules in a new file called "minute-highlight-quote-rules.md" placed as a child of the folder "agent-instructions".
7. ignore the quotes with minutes "99:99" in the first column because those are filler quotes.
8. These rules will later be used to instruct you, the coding agent, to do other tasks.