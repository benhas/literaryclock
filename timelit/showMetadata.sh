#!/bin/sh
# Kindle Keyboard / Launchpad: wait for the metadata-toggle key combo, then run the toggler.
# On devices without waitforkey (many non-keyboard models), exit quietly — clock still works.
BASEDIR="/mnt/us/timelit"
[ -x /usr/bin/waitforkey ] || exit 0
/usr/bin/waitforkey 104 191 && sh "$BASEDIR/showMetadataOLD.sh" &
