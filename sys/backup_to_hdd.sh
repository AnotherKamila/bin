#!/bin/bash

# for each subvolume creates a snapshot and rsync's it to my HDD
# note: no, it doesn't like whitespace in root paths

DEST="/run/media/kamila/backup/snapshots"
KEEP=5  # how many latest backups should be kept
DELETE_LOCAL=1  # should we remove the local snapshots after backup is finished?
NICENESS=10
LOGFILE="$DEST/.lastbackup.log"
RSYNC_OPTS="-rlth"

SNAPSHOT_PREFIX="_snapshots/"

SUBVOLUMES="$@"


backup_subvol() {
	SUBVOL="$1"
	NOW=`date +%Y-%m-%d-%H-%M`
	SNAPSHOT="$SNAPSHOT_PREFIX$SUBVOL-$NOW"

	echo "backing up $SUBVOL..."

	btrfs subvolume snapshot "$SUBVOL" "$SNAPSHOT"

	rm -f "$DEST/$SUBVOL-current"

	NEWEST="`ls -d -1 $DEST/$SUBVOL-* 2>/dev/null | sort -n | tail -n1`"
	if [[ -n "$NEWEST" ]]; then
		# remove oldest backup if necessary
		CNTNOW=`ls -d -1 $DEST/$SUBVOL-* | wc -l`
		if [[ $CNTNOW > $KEEP ]]; then
			XCNT=$((CNTNOW-KEEP))
			echo " - removing old stuff ($XCNT stale backups)..."
			rm -rf `ls -d -1 $DEST/$SUBVOL-* | sort -n | head -n$XCNT`
		fi

		echo " - will link against $NEWEST"
		RSYNC_OPTS="$RSYNC_OPTS -H --link-dest=$NEWEST"
	fi

	CURRENT="$DEST/$SUBVOL-$NOW"
	nice -n $NICENESS rsync $RSYNC_OPTS --delete --numeric-ids "$SNAPSHOT/" "$CURRENT" 2> "$LOGFILE"

	if [ -s $LOGFILE ]; then
		echo "Backup of $SOURCE did not finish successfully. Review the log file (${LOGFILE}) to see what went wrong." >&2
		echo "Deleting this partial backup in 5 seconds... Press Ctrl-C to abort." >&2
		for i in `seq 5 -1 1`; do echo -n "$i " >&2; sleep 1; done; echo >&2
		rm -rf $CURRENT
		exit 127
	else
		ln -s $CURRENT $DEST/$SUBVOL-current  # symlink to the newest backup
		[[ -n $DELETE_LOCAL ]] && btrfs subvolume delete "$SNAPSHOT"
		echo ":)"
	fi
}


if [[ -d "$DEST" ]]; then
	for sv in $SUBVOLUMES; do backup_subvol "$sv"; done
else
	echo "$DEST not found :("
	exit 1
fi
