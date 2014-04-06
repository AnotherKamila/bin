#!/bin/bash

# toggles a symlink in /sbin/fsck.btrfs between /usr/bin/btrfsck and /bin/true (noop)

DEST=/sbin/fsck.btrfs
BTRFSCK=/usr/bin/btrfsck
NOOP=/bin/true

UPDATE_INITRAMFS_CMD="mkinitcpio -p linux"

if diff -q $DEST $NOOP >/dev/null; then
    echo 'Enabling btrfsck on boot'
    rm -f $DEST
    ln -sv $BTRFSCK $DEST
else
    echo 'Disabling btrfsck on boot'
    rm -f $DEST
    ln -sv $NOOP $DEST
fi
echo 'Updating initramfs...'
$UPDATE_INITRAMFS_CMD
