#!/bin/bash

# makes a btrfs snapshot of the given subvolume named by date

SNAPSHOT_PREFIX="_snapshots/"

SUBVOLUMES="$@"

for sv in $SUBVOLUMES; do
    btrfs subvolume snapshot "$sv" "$SNAPSHOT_PREFIX$sv-`date +%Y%m%d%H%M`"
done
