#!/usr/bin/env bash

# make sure we're running as root
if (( `/usr/bin/id -u` != 0 )); then { echo "Sorry, must be root.  Exiting..."; exit 1; } fi

APPNAME=$(basename $0 | sed "s/\.sh$//")
DRY_RUN=false

# -----------------------------------------------------------------------------
# Log functions
# -----------------------------------------------------------------------------

fn_log_info()  { echo "$APPNAME: $1"; }
fn_log_warn()  { echo "$APPNAME: [WARNING] $1" 1>&2; }
fn_log_error() { echo "$APPNAME: [ERROR] $1" 1>&2; }
fn_log_info_cmd()  {
    if [ -n "$SSH_CMD" ]; then
        echo "$APPNAME: $SSH_CMD '$1'";
    else
        echo "$APPNAME: $1";
    fi
}

# -----------------------------------------------------------------------------
# Make sure everything really stops when CTRL+C is pressed
# -----------------------------------------------------------------------------

fn_terminate_script() {
    fn_log_info "SIGINT caught."
    exit 1
}

trap 'fn_terminate_script' SIGINT

# -----------------------------------------------------------------------------
# Small utility functions for reducing code duplication
# -----------------------------------------------------------------------------
fn_display_usage() {
	echo "Usage: $(basename "$0") [OPTION]... <[USER@HOST:]SOURCE> <[USER@HOST:]DESTINATION> [exclude-pattern-file]"
	echo ""
	echo "Options"
	echo " -p, --port             SSH port."
	echo " -h, --help             Display this help message."
	echo " -i, --id_rsa           Specify the private ssh key to use."
	echo " --rsync-get-flags      Display the default rsync flags that are used for backup. If using remote"
	echo "                        drive over SSH, --compress will be added."
	echo " --rsync-set-flags      Set the rsync flags that are going to be used for backup."
	echo " --rsync-append-flags   Append the rsync flags that are going to be used for backup."
	echo " --log-dir              Set the log file directory. If this flag is set, generated files will"
	echo "                        not be managed by the script - in particular they will not be"
	echo "                        automatically deleted."
	echo "                        Default: $LOG_DIR"
	echo " --strategy             Set the expiration strategy. Default: \"1:1 30:7 365:30\" means after one"
	echo "                        day, keep one backup per day. After 30 days, keep one backup every 7 days."
	echo "                        After 365 days keep one backup every 30 days."
	echo " --no-auto-expire       Disable automatically deleting backups when out of space. Instead an error"
	echo "                        is logged, and the backup is aborted."
	echo ""
	echo "For more detailed help, please see the README file:"
	echo ""
	echo "https://github.com/laurent22/rsync-time-backup/blob/master/README.md"
}

fn_parse_date0() {
	# Converts YYYY-MM-DD-HHMMSS to YYYY-MM-DD HH:MM:SS and then to Unix Epoch.
	case "$OSTYPE" in
		linux*|cygwin*|netbsd*)
			date -d "${1:0:10} ${1:11:2}:${1:13:2}:${1:15:2}" +%s ;;
		FreeBSD*) date -j -f "%Y-%m-%d-%H%M%S" "$1" "+%s" ;;
		darwin*)
			# Under MacOS X Tiger
			# Or with GNU 'coreutils' installed (by homebrew)
			#   'date -j' doesn't work, so we do this:
			yy=$(expr ${1:0:4})
			mm=$(expr ${1:5:2} - 1)
			dd=$(expr ${1:8:2})
			hh=$(expr ${1:11:2})
			mi=$(expr ${1:13:2})
			ss=$(expr ${1:15:2})
			perl -e 'use Time::Local; print timelocal('$ss','$mi','$hh','$dd','$mm','$yy'),"\n";' ;;
	esac
}

fn_parse_date1() {
    # Converts YYYY-MM-DD-HHMMSS to YYYY-MM-DD HH:MM:SS and then to Unix Epoch.
    case "$OSTYPE" in
        linux*) date -d "${1:0:10} ${1:11:2}:${1:13:2}:${1:15:2}" +%s ;;
        cygwin*) date -d "${1:0:10} ${1:11:2}:${1:13:2}:${1:15:2}" +%s ;;
        darwin*) date -j -f "%Y-%m-%d-%H%M%S" "$1" "+%s" ;;
    esac
}



fn_find_exclusions() {
      fn_run_cmd  "find "$SRC_FOLDER" -iname ".NOBACKUP""
}

fn_parse_date() {
  local d="$1"
  local date_part=${d:0:10}
  local time_str=${d:11}
  local time_part="${time_str:0:2}:${time_str:2:2}:${time_str:4:2}"
#   echo "DEBUG fn_parse_date input: $d -> $date_part $time_part" >&2
  date -d "$date_part $time_part" +%s 2>/dev/null
}


fn_find_backups() {
    fn_run_cmd "find "$DEST_FOLDER" -type d -name "????-??-??-??????" -prune | sort -r"
}

fn_expire_backup() {
    # Double-check that we're on a backup destination to be completely
    # sure we're deleting the right folder
    if [ -z "$(fn_find_backup_marker "$(dirname -- "$1")")" ]; then
        fn_log_error "$1 is not on a backup destination - aborting."
        exit 1
    fi

    fn_log_info "Expiring $1"
    fn_rmdir "$1"
}

fn_expire_backups() {
	echo "Running fn_expire_backups"
	local current_timestamp=$EPOCH
	local last_kept_timestamp=9999999999

	
	# we will keep requested backup 
	backup_to_keep="$1"
	# we will also keep the oldest backup
	oldest_backup_to_keep="$(fn_find_backups | sort | sed -n '1p')"

	# Process each backup dir from the oldest to the most recent
	for backup_dir in $(fn_find_backups | sort); do

		local backup_date=$(basename "$backup_dir")
		local backup_timestamp=$(fn_parse_date "$backup_date")

		# Skip if failed to parse date...
		if [ -z "$backup_timestamp" ]; then
			fn_log_warn "Could not parse date: $backup_dir"
			continue
		fi

		if [ "$backup_dir" == "$backup_to_keep" ]; then
			# this is the latest backup requsted to be kept. We can finish pruning
			break
		fi

		if [ "$backup_dir" == "$oldest_backup_to_keep" ]; then
			# We dont't want to delete the oldest backup. It becomes first "last kept" backup
			last_kept_timestamp=$backup_timestamp
			# As we keep it we can skip processing it and go to the next oldest one in the loop
			continue
		fi

		# Find which strategy token applies to this particular backup
# 		for strategy_token in $(echo $EXPIRATION_STRATEGY | tr " " "\n" | sort -r -n); do
		for strategy_token in $(echo "$EXPIRATION_STRATEGY" | tr " " "\n" | sort -t: -k1,1nr); do

			IFS=':' read -r -a t <<< "$strategy_token"

			# After which date (relative to today) this token applies (X) - we use seconds to get exact cut off time
			local cut_off_timestamp=$((current_timestamp - ${t[0]} * 86400))

			# Every how many days should a backup be kept past the cut off date (Y) - we use days (not seconds)
			local cut_off_interval_days=$((${t[1]}))

			# If we've found the strategy token that applies to this backup
			if [ "$backup_timestamp" -le "$cut_off_timestamp" ]; then

				# Special case: if Y is "0" we delete every time
				if [ $cut_off_interval_days -eq "0" ]; then
					fn_expire_backup "$backup_dir"
					break
				fi

				# we calculate days number since last kept backup
				local last_kept_timestamp_days=$((last_kept_timestamp / 86400))
				local backup_timestamp_days=$((backup_timestamp / 86400))
				local interval_since_last_kept_days=$((backup_timestamp_days - last_kept_timestamp_days))

				# Check if the current backup is in the interval between
				# the last backup that was kept and Y
				# to determine what to keep/delete we use days difference
				if [ "$interval_since_last_kept_days" -lt "$cut_off_interval_days" ]; then

					# Yes: Delete that one
					echo "WOULD PRUNE: $backup_dir"
					#fn_expire_backup "$backup_dir"
					# backup deleted no point to check shorter timespan strategies - go to the next backup
					break

				else

					# No: Keep it.
					# this is now the last kept backup
					last_kept_timestamp=$backup_timestamp
					# and go to the next backup
					break
				fi
			fi
		done
	done
}

fn_expire_backups() {
	echo "Running fn_expire_backups"
	local current_timestamp=$EPOCH

	backup_to_keep="$1"
	oldest_backup_to_keep="$(fn_find_backups | sort | sed -n '1p')"

	# Set last_kept_timestamp to oldest backup timestamp to avoid negative intervals
	local last_kept_timestamp=$(fn_parse_date "$(basename "$oldest_backup_to_keep")")

	for backup_dir in $(fn_find_backups | sort); do
		local backup_date=$(basename "$backup_dir")
		local backup_timestamp=$(fn_parse_date "$backup_date")

		if [ -z "$backup_timestamp" ]; then
			fn_log_warn "Could not parse date: $backup_dir"
			continue
		fi

		if [ "$backup_dir" == "$backup_to_keep" ]; then
			break
		fi

		if [ "$backup_dir" == "$oldest_backup_to_keep" ]; then
			last_kept_timestamp=$backup_timestamp
			continue
		fi

		local keep_backup=false

		# Check all strategy tokens for this backup
		for strategy_token in $(echo "$EXPIRATION_STRATEGY" | tr " " "\n" | sort -t: -k1,1nr); do
			IFS=':' read -r -a t <<< "$strategy_token"
			local cut_off_timestamp=$((current_timestamp - ${t[0]} * 86400))
			local cut_off_interval_days=${t[1]}

			if [ "$backup_timestamp" -le "$cut_off_timestamp" ]; then
				if [ "$cut_off_interval_days" -eq 0 ]; then
					# Delete always
					keep_backup=false
					break
				fi

				local last_kept_days=$((last_kept_timestamp / 86400))
				local backup_days=$((backup_timestamp / 86400))
				local interval_days=$((backup_days - last_kept_days))

				if [ "$interval_days" -ge "$cut_off_interval_days" ]; then
					keep_backup=true
					break
				else
					keep_backup=false
					break
				fi
			fi
		done

		if $keep_backup; then
			echo "KEEP: $backup_dir"
			last_kept_timestamp=$backup_timestamp
		else
			echo "PRUNE: $backup_dir"
			fn_expire_backup "$backup_dir"
		fi
	done
}





fn_parse_ssh() {
    if [[ "$DEST_FOLDER" =~ ^[A-Za-z0-9\._%\+\-]+@[A-Za-z0-9.\-]+\:.+$ ]]
    then
        SSH_USER=$(echo "$DEST_FOLDER" | sed -E  's/^([A-Za-z0-9\._%\+\-]+)@([A-Za-z0-9.\-]+)\:(.+)$/\1/')
        SSH_HOST=$(echo "$DEST_FOLDER" | sed -E  's/^([A-Za-z0-9\._%\+\-]+)@([A-Za-z0-9.\-]+)\:(.+)$/\2/')
        SSH_DEST_FOLDER=$(echo "$DEST_FOLDER" | sed -E  's/^([A-Za-z0-9\._%\+\-]+)@([A-Za-z0-9.\-]+)\:(.+)$/\3/')
        SSH_CMD="ssh ${SSH_USER}@${SSH_HOST}"
        SSH_FOLDER_PREFIX="${SSH_USER}@${SSH_HOST}:"
    fi
}

fn_run_cmd() {
    if [ -n "$SSH_CMD" ]
    then
        eval "$SSH_CMD '$1'"
    else
        eval $1
    fi
}

fn_find() {
    fn_run_cmd "find $1"  2>/dev/null
}

fn_get_absolute_path() {
    fn_run_cmd "cd $1;pwd"
}

fn_mkdir() {
    fn_run_cmd "mkdir -p -- $1"
}

fn_rmdir() {
        # NOTES: using RM to delete a directory and a large amount of
        # files is slow and sometimes impossible so I propose the use
        # of rsync to delete the files and use RM to do the last bit
        # of cleanup -i.e. deleting the empty directories.
    fn_run_cmd "mkdir emptydir"
    fn_run_cmd "rsync -a --delete emptydir/ $1/"
    fn_run_cmd "rm -rf -- emptydir"
    fn_run_cmd "rm -rf -- $1"
}

fn_rm() {
    fn_run_cmd "rm -rf -- $1"
}

fn_touch() {
    fn_run_cmd "touch -- $1"
}

fn_ln() {
    fn_run_cmd "ln -vs -- $1 $2"
}

fn_show_help() {
    echo "Usage: '$APPNAME -s <SOURCE> -d <DESTINATION> -e <EXCLUSION>'"
    echo ""
    echo "ARGUMENTS:"
    echo "      -s              :       Source folder"
    echo "      --source"
    echo "      -d              :       Destination folder"
    echo "      --destination"
    echo "      -e              :       Exclusion or exclustion list"
    echo "      --exclusion"
    echo ""
    echo " NOTES:"
    echo "      o  It is permitted to pass arguments in any order."
    echo "      o  It is permitted to use short or long versions of flags."
    echo "      o  It is permitted to use an '=' seperating flag and path."
    echo "         EX: --source=~\\my-backup-source\\"
}


# -----------------------------------------------------------------------------
# Source and destination information
# -----------------------------------------------------------------------------
SSH_USER=""
SSH_HOST=""
SSH_DEST_FOLDER=""
SSH_CMD=""
SSH_FOLDER_PREFIX=""

while :; do
    case $1 in
        -h|-\?|--help)          # Call a "show_help" function to display a synopsis, then exit.
            fn_show_help
            exit
            ;;
        -s|--source)            # Takes an option argument, ensuring it has been specified.
            if [ -n "$2" ]; then
                SRC_FOLDER=$2
                shift
            else
                echo "ERROR: '--source' requires a non-empty option argument."
                exit 1
            fi
            ;;
        --source=?*)
            SRC_FOLDER=${1#*=}  # Delete everything up to "=" and assign the remainder.
            ;;
        --source=)              # Handle the case of an empty --source=
            echo "ERROR: '--source' requires a non-empty option argument."
            exit 1
            ;;
        -d|--destination)       # Takes an option argument, ensuring it has been specified.
            if [ -n "$2" ]; then
                DEST_FOLDER=$2
                shift
            else
                echo "ERROR: '--destination' requires a non-empty option argument."
                exit 1
            fi
            ;;
        --destination=?*)
            DEST_FOLDER=${1#*=} # Delete everything up to "=" and assign the remainder.
            ;;
        --destination=)         # Handle the case of an empty --destination=
            echo "ERROR: '--destination' requires a non-empty option argument."
            exit 1
            ;;
        -e|--exclusion)
            EXCLUSION_FILE="$2";
            ;;
        --exclusion=?*)
            DEST_FOLDER=${1#*=} # Delete everything up to "=" and assign the remainder.
            ;;
        --exclusion=)           # Handle the case of an empty --exclusion= 
            echo "ERROR: '--exclusion' requires a non-empty option argument."
            exit 1
            ;;
        -x|--dry-run)
            echo "DRY-RUN option set."
            DRY_RUN=true
            ;;
        --)                     # End of all options.
            shift
            break
            ;;
        -?*)
            echo "WARN: Unknown option (ignored): '$1'"
            ;;
        *)                      # Default case: If no more options then break out of the loop.
            if [ "$SRC_FOLDER" == "" ]; then
                echo "ERROR: Required argument missing; '--source' requires a non-empty option argument."
                echo "For help, issue the following: '$APPNAME' -h'"
                exit 1;
            fi
            if [ "$DEST_FOLDER" == "" ]; then
                echo "ERROR: Required argument missing; '--destination' requires a non-empty option argument."
                echo "HELP: For help, issue the following: '$APPNAME' -h'"
                exit 1;
            fi
            break
    esac
    shift
done

if [ -z "$EXCLUSION_FILE" ]; then
    # A directory under each source entitled '.sync' could contain an
    # 'IgnoreList', which could allow for tighter control over what
    # gets excluded from each sync, instead of limiting the use of one
    # master exclusion_list or calling the use of an exclusion_list
    # each time. -i.e. possible small feature add.
    # EX:
    #           SRC_FOLDER
    #               |
    #               + .sync
    #               |    |
    #               |    + Ignorelist
    #               + file
    #               |
    #               + file...
    if [ -f "$SRC_FOLDER/.sync/IgnoreList" ]; then
        # if both the #3 parameter (exclusion_file) and the
        # 'ignorelist' file exists, prompt the end user and set the
        # variable.
        fn_run_cmd "echo $APPNAME: EXCLUSION_FILE parameter missing. Assuming $SRC_FOLDER/.sync/IgnoreList usage."
        EXCLUSION_FILE="$SRC_FOLDER/.sync/IgnoreList"
    fi
    # ...else leave variable blank.
fi

fn_parse_ssh

if [ -n "$SSH_DEST_FOLDER" ]; then
    DEST_FOLDER="$SSH_DEST_FOLDER"
fi

for ARG in "$SRC_FOLDER" "$DEST_FOLDER" "$EXCLUSION_FILE"; do
if [[ "$ARG" == *"'"* ]]; then
        fn_log_error 'Arguments may not have any single quote characters.'
        exit 1
    fi
done

# -----------------------------------------------------------------------------
# Check that the destination drive is a backup drive
# -----------------------------------------------------------------------------

# TODO: check that the destination supports hard links

fn_backup_marker_path() { echo "$1/backup.marker"; }
fn_find_backup_marker() { fn_find "$(fn_backup_marker_path "$1")" 2>/dev/null; }

if [ -z "$(fn_find_backup_marker "$DEST_FOLDER")" ]; then
    fn_log_info "Safety check failed - the destination does not appear to be a backup folder or drive (marker file not found)."
    fn_log_info "If it is indeed a backup folder, you may add the marker file by running the following command:"
    fn_log_info ""
    fn_log_info_cmd "mkdir -p -- \"$DEST_FOLDER\" ; touch \"$(fn_backup_marker_path "$DEST_FOLDER")\""
    fn_log_info ""
    exit 1
fi

# -----------------------------------------------------------------------------
# Setup additional variables
# -----------------------------------------------------------------------------

# Date logic
NOW=$(date +"%Y-%m-%d-%H%M%S")
EPOCH=$(date "+%s")
KEEP_ALL_DATE=$((EPOCH - 86400))       # 1 day ago
KEEP_DAILIES_DATE=$((EPOCH - 2678400)) # 31 days ago

export IFS=$'\n' # Better for handling spaces in filenames.
PROFILE_FOLDER="$HOME/.$APPNAME"
DEST="$DEST_FOLDER/$NOW"
PREVIOUS_DEST="$(fn_find_backups | head -n 1)"
INPROGRESS_FILE="$DEST_FOLDER/backup.inprogress"
MYPID="$$"

# -----------------------------------------------------------------------------
# Create profile folder if it doesn't exist
# -----------------------------------------------------------------------------

if [ ! -d "$PROFILE_FOLDER" ]; then
    fn_log_info "Creating profile folder in '$PROFILE_FOLDER'..."
    mkdir -- "$PROFILE_FOLDER"
fi

# -----------------------------------------------------------------------------
# Handle case where a previous backup failed or was interrupted.
# -----------------------------------------------------------------------------

if [ -n "$(fn_find "$INPROGRESS_FILE")" ]; then
	if [ "$OSTYPE" == "cygwin" ]; then
		# TODO: Cygwin reports the name of currently running Bash scripts as just "/usr/bin/bash"
		# TODO: so the pgrep solution below won't work. Need to use "procps -wwFAH", grep
		# TODO: the script name, and extract the process ID from it.
		fn_log_warn "Cygwin only: Previous backup task has either been interrupted or it might still be active, but there is currently no check for this. Assuming that the task was simply interrupted."
	else
	    RUNNINGPID="$(fn_run_cmd "cat $INPROGRESS_FILE")"
	    if [ "$RUNNINGPID" = "$(pgrep "$APPNAME")" ]; then
	        fn_log_error "Previous backup task is still active - aborting."
	        exit 1
	    fi
	fi

    if [ -n "$PREVIOUS_DEST" ]; then
        # - Last backup is moved to current backup folder so that it can be resumed.
        # - 2nd to last backup becomes last backup.
        fn_log_info "$SSH_FOLDER_PREFIX$INPROGRESS_FILE already exists - the previous backup failed or was interrupted. Backup will resume from there."
        fn_run_cmd "mv -- $PREVIOUS_DEST $DEST"
        if [ "$(fn_find_backups | wc -l)" -gt 1 ]; then
            PREVIOUS_DEST="$(fn_find_backups | sed -n '2p')"
        else
            PREVIOUS_DEST=""
        fi
        # update PID to current process to avoid multiple concurrent resumes
        fn_run_cmd "echo $MYPID > $INPROGRESS_FILE"
    fi
fi

# Run in a loop to handle the "No space left on device" logic.
while : ; do

    # -----------------------------------------------------------------------------
    # Check if we are doing an incremental backup (if previous backup exists).
    # -----------------------------------------------------------------------------

    LINK_DEST_OPTION=""
    if [ -z "$PREVIOUS_DEST" ]; then
        fn_log_info "No previous backup - creating new one."
    else
        # If the path is relative, it needs to be relative to the destination. To keep
        # it simple, just use an absolute path. See http://serverfault.com/a/210058/118679
        PREVIOUS_DEST="$(fn_get_absolute_path "$PREVIOUS_DEST")"
        fn_log_info "Previous backup found - doing incremental backup from $SSH_FOLDER_PREFIX$PREVIOUS_DEST"
        LINK_DEST_OPTION="--link-dest='$PREVIOUS_DEST'"
    fi

    # -----------------------------------------------------------------------------
    # Create destination folder if it doesn't already exists
    # -----------------------------------------------------------------------------

    if [ $DRY_RUN != true ]; then
        if [ -z "$(fn_find "$DEST -type d" 2>/dev/null)" ]; then
            fn_log_info "Creating destination $SSH_FOLDER_PREFIX$DEST"
            fn_mkdir "$DEST"
        fi
    fi

    # -----------------------------------------------------------------------------
    # Purge certain old backups before beginning new backup.
    # -----------------------------------------------------------------------------

    # Default value for $PREV ensures that the most recent backup is
    # never deleted.
    if [ $DRY_RUN != true ]; then
        PREV="0000-00-00-000000"
        for FILENAME in $(fn_find_backups | sort -r); do
            BACKUP_DATE=$(basename "$FILENAME")
            TIMESTAMP=$(fn_parse_date $BACKUP_DATE)

            # Skip if failed to parse date...
            if [ -z "$TIMESTAMP" ]; then
                fn_log_warn "Could not parse date: $FILENAME"
                continue
            fi

            if   [ $TIMESTAMP -ge $KEEP_ALL_DATE ]; then
                true
            elif [ $TIMESTAMP -ge $KEEP_DAILIES_DATE ]; then
                # Delete all but the most recent of each day.
                [ "${BACKUP_DATE:0:10}" == "${PREV:0:10}" ] && fn_expire_backup "$FILENAME"
            else
                # Delete all but the most recent of each month.
                [ "${BACKUP_DATE:0:7}" == "${PREV:0:7}" ] && fn_expire_backup "$FILENAME"
            fi

            PREV=$BACKUP_DATE
        done
    fi

    # -----------------------------------------------------------------------------
    # Start backup
    # -----------------------------------------------------------------------------

    IGNORE_DIRS="$(fn_find_exclusions)"
    IGNORE_DIRS="${IGNORE_DIRS%/*}"

    if [ !$DRY_RUN != true ]; then
        LOG_FILE="$PROFILE_FOLDER/$(date +"%Y-%m-%d-%H%M%S").log"

        fn_log_info "Starting backup..."
        fn_log_info "From: $SRC_FOLDER"
        fn_log_info "To:   $SSH_FOLDER_PREFIX$DEST"
        fn_log_info "Ignoring: $IGNORE_DIRS"
    fi

    CMD="rsync"
    if [ -n "$SSH_CMD" ]; then
        CMD="$CMD  -e 'ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null'"
    fi
    if [ $DRY_RUN == true ]; then
        CMD="$CMD --dry-run"
    fi
    CMD="$CMD --compress"
    CMD="$CMD --numeric-ids"
    if [ $DRY_RUN != true ]; then
        CMD="$CMD --links"
        CMD="$CMD --hard-links"
    fi
    CMD="$CMD --one-file-system"
    CMD="$CMD --archive"
    CMD="$CMD --itemize-changes"
    CMD="$CMD --verbose"
    CMD="$CMD --log-file '$LOG_FILE'"
    if [ -n "$EXCLUSION_FILE" ]; then
        # We've already checked that $EXCLUSION_FILE doesn't contain a
        # single quote
        #
        # If $EXCLUSION_FILE is a file that exists, pass it as a file.
        # If not, use it as a string exclude.
        if [ -f "$EXCLUSION_FILE" ]; then
            CMD="$CMD --exclude-from '$EXCLUSION_FILE'"
        else
            for EXCPATT in $(echo $EXCLUSION_FILE | tr " " "\n")
            do
                CMD="$CMD --exclude '$EXCPATT'"
            done
        fi
    fi

    if [ -n "$IGNORE_DIRS" ]; then
        CMD="$CMD --exclude $IGNORE_DIRS"
    fi

    CMD="$CMD $LINK_DEST_OPTION"
    CMD="$CMD -- '$SRC_FOLDER/' '$SSH_FOLDER_PREFIX$DEST/'"
    CMD="$CMD | grep -E '^deleting|[^/]$'"

    fn_log_info "Running command:"
    fn_log_info "$CMD"

    fn_run_cmd "echo $MYPID > $INPROGRESS_FILE"

    eval $CMD

    # -----------------------------------------------------------------------------
    # Check if we ran out of space
    # -----------------------------------------------------------------------------

    DISKSPACE=`df -H $DEST_FOLDER | sed '1d' | awk '{print $5}' | cut -d'%' -f1`

    if (( ${DISKSPACE} > 90 )); then
        fn_log_warn "No space left on device - removing oldest backup and resuming."

        if [[ "$(fn_find_backups | wc -l)" -lt "2" ]]; then
            fn_log_error "No space left on device, and no old backup to delete."
            exit 1
        fi

        fn_expire_backup "$(fn_find_backups | tail -n 1)"

        # Resume backup
        continue
    fi

    # -----------------------------------------------------------------------------
    # Check whether rsync reported any errors
    # -----------------------------------------------------------------------------
    if [ -n "$(grep "rsync:" "$LOG_FILE")" ]; then
        fn_log_warn "Rsync reported a warning, please check '$LOG_FILE' for more details."
    fi
    if [ -n "$(grep "rsync error:" "$LOG_FILE")" ]; then
        fn_log_error "Rsync reported an error, please check '$LOG_FILE' for more details."
        exit 1
    fi

    # -----------------------------------------------------------------------------
    # Add symlink to last successful backup
    # -----------------------------------------------------------------------------


    if [ $DRY_RUN != true ]; then
        fn_rm "$DEST_FOLDER/latest"
        fn_ln "$(basename -- "$DEST")" "$DEST_FOLDER/latest"
    fi

    fn_rm "$INPROGRESS_FILE"
    rm -f -- "$LOG_FILE"

    fn_log_info "Backup completed without errors."

    exit 0
done
