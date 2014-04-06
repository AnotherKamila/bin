#!/bin/bash

# helper script that calls its argument handling mounting and unmounting /btrroot

BTRROOT="/btrroot"

UNMOUNT_BTRROOT_AFTERWARDS=1

if [[ -n `mount | grep "$BTRROOT"` ]]; then
    echo "$BTRROOT already mounted"
    UNMOUNT_BTRROOT_AFTERWARDS=0  # don't unmount it if it has been manually mounted before
else
    echo "mounting $BTRROOT"
    mount "$BTRROOT"
fi

cd "$BTRROOT"
$@
cd /

if [[ $UNMOUNT_BTRROOT_AFTERWARDS != 0 ]]; then
    echo "unmounting $BTRROOT"
    sleep 1 && umount "$BTRROOT"
else
    echo "not unmounting $BTRROOT as it was already mounted before"
fi
