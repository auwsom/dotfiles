#!/usr/bin/env bash

# make sure we're running as root
if (( $(/usr/bin/id -u) != 0 )); then { echo "Sorry, must be root. Exiting..."; exit 1; } fi

APPNAME=$(basename "$0" | sed "s/\\.sh$//")
DRY_RUN=false
EXPIRATION_STRATEGY="1:1 7:7 30:7 365:30" # Added
AUTO_EXPIRE="1"                      # Added (1 for enabled, 0 for disabled)
USE_OLD_PARSE_DATE=false             # Added
ONLY_PRUNE=false                     # Added
TEMP_DIR="/tmp/$APPNAME-temp"        # Added - used by fn_rm_dir
EPOCH=$(date +%s)                    # ADDED: Define EPOCH for date calculations
RSYNC_EXCLUDE_FLAGS="" 

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

# ADDED/MOVED: Centralized fn_run_cmd for consistent DRY_RUN handling
fn_run_cmd() {
    local cmd_to_run="$1"
    if [ "$DRY_RUN" == true ]; then
#         fn_log_info "DRY RUN: Would execute: $cmd_to_run"
        : # pass
    else
        if [ -n "$SSH_CMD" ]; then
            eval "$SSH_CMD '$cmd_to_run'"
        else
            eval "$cmd_to_run"
        fi
    fi
}

# fn_parse_date0: Laurent22's old, more comprehensive version
fn_parse_date0() {
    # Converts Ambassadors-MM-DD-HHMMSS to Ambassadors-MM-DD HH:MM:SS and then to Unix Epoch.
    case "$OSTYPE" in
        linux*|cygwin*|netbsd*)
            date -d "${1:0:10} ${1:11:2}:${1:13:2}:${1:15:2}" +%s ;;
        FreeBSD*) date -j -f "%Y-%m-%d-%H%M%S" "$1" "+%s" ;;
        darwin*)
            yy="${1:0:4}"
            mm=$((10#${1:5:2} - 1)) # Use 10# to force base-10 interpretation, important for months like '01', '09'
            dd="${1:8:2}"
            hh="${1:11:2}"
            mi="${1:13:2}"
            ss="${1:15:2}"
            perl -e 'use Time::Local; print timelocal('"$ss"','"$mi"','"$hh"','"$dd"','"$mm"','"$yy"'),"\n";' ;;
    esac
}

# fn_parse_date1: The original 'new' script's date parsing (case-based)
fn_parse_date1() {
    case "$OSTYPE" in
        linux*)    date -d "${1:0:10} ${1:11:2}:${1:13:2}:${1:15:2}" +%s ;;
        cygwin*)   date -d "${1:0:10} ${1:11:2}:${1:13:2}:${1:15:2}" +%s ;;
        darwin*)   date -j -f "%Y-%m-%d-%H%M%S" "$1" "+%s" ;;
    esac
}

# fn_parse_date: The wrapper function, using fn_parse_date1 by default or fn_parse_date0 if --use-old-parse-date is set
fn_parse_date() {
    if [ "$USE_OLD_PARSE_DATE" = true ]; then
        fn_parse_date0 "$1"
    else
        fn_parse_date1 "$1"
    fi
}

# Renamed/updated deletion functions for robustness - NOW USING fn_run_cmd CONSISTENTLY
fn_rm_dir() {
    # It has been shown that 'rm -rf' on large directories can be much slower
    # than 'rsync --delete'. For this reason, we prefer rsync.
    fn_run_cmd "mkdir -p \"$TEMP_DIR/emptydir\"" # Ensure emptydir exists via fn_run_cmd
    fn_run_cmd "rsync -a --delete \"$TEMP_DIR/emptydir/\" \"$1/\""
    fn_run_cmd "rmdir \"$1\"" # rmdir only works on empty dirs
}

# Removes a file or symlink - not for directories
fn_rm_file() {
    fn_run_cmd "rm -f -- '$1'"
}

fn_ln() {
    fn_run_cmd "ln -s '$1' '$2'"
}

fn_mkdir() {
    fn_run_cmd "mkdir -p '$1'"
}

fn_find_backups() {
    find "$DEST_FOLDER" -maxdepth 1 -mindepth 1 -name "????-??-??-??????" -type d | sort -r
}

fn_find_backup_marker() {
    find "$1" -maxdepth 1 -mindepth 1 -name "backup.marker" -type f
}

fn_find_exclusions() {
      fn_run_cmd "find \"$SRC_FOLDER\" -iname \".NOBACKUP\""
}

# New function for expiring individual backups (used by fn_expire_backups)
fn_expire_backup() {
    # Double-check that we're on a backup destination to be completely
    # sure we're deleting the right folder
    if [ -z "$(fn_find_backup_marker "$(dirname -- "$1")")" ]; then
        fn_log_error "$1 is not on a backup destination - aborting."
        exit 1
    fi
    # Removed fn_log_info "Expiring $1" - logging is handled by fn_expire_backups caller
    fn_rm_dir "$1"
}


# fn_expire_backups: The core expiration logic - ADDED KEEP/PRUNE LOGGING
fn_expire_backups() {
    local current_timestamp=$EPOCH
    local last_kept_timestamp=9999999999 # Initialize to a very large number for the first 'kept' backup

    # we will keep requested backup (the one currently being created/linked from, or specifically passed in)
    backup_to_keep="$1" # This can be empty if ONLY_PRUNE is true

    # we will also keep the oldest backup if it exists and is not the same as backup_to_keep
    local all_backups_sorted=$(fn_find_backups | sort)
    local oldest_backup_to_keep=$(echo "$all_backups_sorted" | sed -n '1p')

    # Process each backup dir from the oldest to the most recent
    for backup_dir in $all_backups_sorted; do

        local backup_date=$(basename "$backup_dir")
        local backup_timestamp=$(fn_parse_date "$backup_date") # Calls the wrapper fn_parse_date

        # Skip if failed to parse date...
        if [ -z "$backup_timestamp" ]; then
            fn_log_warn "Could not parse date: $backup_dir"
            continue
        fi

        # First, handle the explicitly kept backups
        if [ -n "$backup_to_keep" ] && [ "$backup_dir" == "$backup_to_keep" ]; then
            fn_log_info "KEEP: $backup_dir (explicitly requested)"
            last_kept_timestamp=$backup_timestamp # Set this as the last kept to properly calculate intervals
            break # This is the latest backup requested to be kept. We can finish pruning.
        fi

        if [ "$backup_dir" == "$oldest_backup_to_keep" ]; then
            fn_log_info "KEEP: $backup_dir (oldest backup)"
            last_kept_timestamp=$backup_timestamp # This becomes the first "last kept" backup
            continue # Go to the next oldest one in the loop
        fi

        # Find which strategy token applies to this particular backup
        for strategy_token in $(echo "$EXPIRATION_STRATEGY" | tr " " "\n" | sort -r -n); do
            IFS=':' read -r -a t <<< "$strategy_token"

            # After which date (relative to today) this token applies (X) - we use seconds to get exact cut off time
            local cut_off_timestamp=$((current_timestamp - ${t[0]} * 86400))

            # Every how many days should a backup be kept past the cut off date (Y) - we use days (not seconds)
            local cut_off_interval_days=$((${t[1]}))

            # If we've found the strategy token that applies to this backup
            if [ "$backup_timestamp" -le "$cut_off_timestamp" ]; then

                # Special case: if Y is "0" we delete every time in this range
                if [ "$cut_off_interval_days" -eq "0" ]; then
                    fn_log_info "PRUNE: $backup_dir (strategy: delete all in this range)"
                    fn_expire_backup "$backup_dir"
                    break # backup deleted, no point to check shorter timespan strategies - go to the next backup
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
                    fn_log_info "PRUNE: $backup_dir (strategy: interval too short since last kept)"
                    fn_expire_backup "$backup_dir"
                    break # backup deleted, no point to check shorter timespan strategies - go to the next backup
                else
                    # No: Keep it.
                    fn_log_info "KEEP: $backup_dir (strategy: interval sufficiently long)"
                    # this is now the last kept backup
                    last_kept_timestamp=$backup_timestamp
                    break # and go to the next backup
                fi
            fi
        done
    done
}


# -----------------------------------------------------------------------------
# Parse arguments
# -----------------------------------------------------------------------------

# fn_display_usage (replaces fn_show_help for more detail)
fn_display_usage() {
    # Changed usage line to reflect no positional arguments
    echo "Usage: $(basename "$0") [OPTION]..."
    echo ""
    echo "Options"
    echo " -s, --source              The source location." # Added for source
    echo " -d, --destination         The destination location." # Added for destination
    echo " -p, --port                SSH port."
    echo " -h, --help                Display this help message."
    echo " -i, --id_rsa              Specify the private ssh key to use."
    echo " -x, --dry-run             Do a dry run (nothing will be changed)."
    echo " -ex, --exclude            Specify a file containing exclusion patterns."
    echo " --rsync-get-flags         Display the default rsync flags that are used for backup. If using remote"
    echo "                           drive over SSH, --compress will be added."
    echo " --rsync-set-flags         Set the rsync flags that are going to be used for backup."
    echo " --rsync-append-flags      Append the rsync flags that are going to be used for backup."
    echo " --log-dir                 Set the log file directory. If this flag is set, generated files will"
    echo "                           not be managed by the script - in particular they will not be"
    echo "                           automatically deleted."
    echo "                           Default: $LOG_DIR"
    echo " --log-to-destination      Set the log file directory to the destination directory. If this flag"
    echo "                           is set, generated files will not be managed by the script - in particular"
    echo "                           they will not be automatically deleted."
    echo " --strategy                Set the expiration strategy. Default: \"1:1 30:7 365:30\" means after one"
    echo "                           day, keep one backup per day. After 30 days, keep one backup every 7 days."
    echo "                           After 365 days keep one backup every 30 days."
    echo " --no-auto-expire          Disable automatically deleting backups when out of space. Instead an error"
    echo "                           is logged, and the backup is aborted."
    echo " --prune                   Prune backups according to the strategy, without performing a backup."
    echo " --use-old-parse-date      Use the fn_parse_date0 (Laurent22's old version) for date parsing."
    echo ""
    echo "For more detailed help, please see the README file:"
    echo ""
    echo "https://github.com/laurent22/rsync-time-backup/blob/master/README.md"
}

# Reset in case getopts has been used previously in the shell.
OPTIND=1

while :; do
    case $1 in
        -h|-\?|--help)
            fn_display_usage
            exit
            ;;
        -s|--source) # Added for source folder
            if [ "$2" ]; then
                SRC_FOLDER="$2"
                shift
            fi
            ;;
        -d|--destination) # Added for destination folder
            if [ "$2" ]; then
                DEST_FOLDER="$2"
                shift
            fi
            ;;
        --prune)
            ONLY_PRUNE=true
            ;;
        --port)
            if [ "$2" ]; then
                SSH_PORT="$2"
                shift
            fi
            ;;
        -i|--id_rsa)
            if [ "$2" ]; then
                SSH_ID_RSA="$2"
                shift
            fi
            ;;
        -x|--dry-run)
            DRY_RUN=true
            ;;
            
#         -ex|--exclude)
#             if [ "$2" ]; then
#                 EXCLUDE_FILE="$2"
#                 shift
#             fi
#             ;;
            
        -ex|--exclude)
            # Check if the next argument is a directory
            if [ -d "$2" ]; then
                RSYNC_EXCLUDE_FLAGS+=" --exclude=$2/" # Exclude the directory and its contents
                fn_log_info "Excluding directory: $2"
            # Check if the next argument is a file
            elif [ -f "$2" ]; then
                RSYNC_EXCLUDE_FLAGS+=" --exclude-from=$2" # Use it as an exclusion file
                fn_log_info "Excluding patterns from file: $2"
            else
                fn_log_warn "Warning: -ex argument '$2' is neither a directory nor a file. Treating as a direct pattern."
                RSYNC_EXCLUDE_FLAGS+=" --exclude=$2" # Treat as a direct pattern if neither
            fi
            shift 2 # Consume the -ex option and its argument
            ;;
        
        --rsync-get-flags)
            RSYNC_GET_FLAGS=true
            ;;
        --rsync-set-flags)
            if [ "$2" ]; then
                RSYNC_FLAGS_INPUT="$2"
                shift
            fi
            ;;
        --rsync-append-flags)
            if [ "$2" ]; then
                RSYNC_APPEND_FLAGS_INPUT="$2"
                shift
            fi
            ;;
        --log-dir)
            if [ "$2" ]; then
                LOG_DIR="$2"
                shift
            fi
            ;;
        --log-to-destination)
            LOG_TO_DESTINATION=true
            ;;
        --strategy)
            shift
            EXPIRATION_STRATEGY="$1"
            ;;
        --no-auto-expire)
            AUTO_EXPIRE="0"
            ;;
        --use-old-parse-date)
            USE_OLD_PARSE_DATE=true
            ;;
        --) # End of all options.
            shift
            break
            ;;
        -?*)
            fn_log_warn "Unknown option (ignored): $1\n"
            ;;
        *) # Default case: No more options, so break out of the loop.
            break
    esac

    shift
done


# -----------------------------------------------------------------------------
# Validates arguments
# -----------------------------------------------------------------------------

if [ "$RSYNC_GET_FLAGS" = true ]; then
    echo "$RSYNC_FLAGS"
    exit 0
fi

# Validate source and destination folders
if [ -z "$SRC_FOLDER" ] || [ -z "$DEST_FOLDER" ]; then
    fn_log_error "Source and/or destination not specified."
    fn_display_usage # Changed from fn_show_help
    exit 1
fi

# Determine the full path for the exclusion file if it's a relative path
EXCLUDE_FILE_FOR_RSYNC="" # Initialize to empty
if [ -n "$EXCLUDE_FILE" ]; then
    # Check if EXCLUDE_FILE is a relative path (doesn't start with / or ~)
    if [[ "$EXCLUDE_FILE" != /* ]] && [[ "$EXCLUDE_FILE" != ~* ]]; then
        # If it's a relative path, assume it's relative to SRC_FOLDER
        EXCLUDE_FILE_FOR_RSYNC="$SRC_FOLDER/$EXCLUDE_FILE"
        fn_log_info "Interpreting exclusion file '$EXCLUDE_FILE' relative to source: '$EXCLUDE_FILE_FOR_RSYNC'"
    else
        # If it's an absolute path or starts with ~, use it as is
        EXCLUDE_FILE_FOR_RSYNC="$EXCLUDE_FILE"
    fi
fi

# -----------------------------------------------------------------------------
# Derived variables
# -----------------------------------------------------------------------------

# SSH connection details
SRC_SSH_HOST=$(echo "$SRC_FOLDER" | grep '@' | cut -d'@' -f2 | cut -d':' -f1)
SRC_SSH_USER=$(echo "$SRC_FOLDER" | grep '@' | cut -d'@' -f1)
SRC_PATH=$(echo "$SRC_FOLDER" | cut -d':' -f2-)
DEST_SSH_HOST=$(echo "$DEST_FOLDER" | grep '@' | cut -d'@' -f2 | cut -d':' -f1)
DEST_SSH_USER=$(echo "$DEST_FOLDER" | grep '@' | cut -d'@' -f1)
DEST_PATH=$(echo "$DEST_FOLDER" | cut -d':' -f2-)

# RSYNC options
RSYNC_FLAGS="-avx --delete --delete-excluded --backup --backup-dir='$(date "+%Y-%m-%d-%H%M%S")' --link-dest='$DEST_FOLDER/latest'"

if [ -n "$SRC_SSH_HOST" ] || [ -n "$DEST_SSH_HOST" ]; then
    # Add --compress flag if doing an SSH backup
    RSYNC_FLAGS="$RSYNC_FLAGS --compress"
    if [ -n "$SSH_PORT" ]; then
        RSYNC_FLAGS="$RSYNC_FLAGS -e 'ssh -p $SSH_PORT'"
    fi
    if [ -n "$SSH_ID_RSA" ]; then
        RSYNC_FLAGS="$RSYNC_FLAGS -e 'ssh -i $SSH_ID_RSA'"
    fi
    if [ -n "$SRC_SSH_HOST" ] && [ -n "$DEST_SSH_HOST" ]; then
        fn_log_error "Cannot backup from remote to remote, rsync does not support it."
        exit 1
    fi
fi

if [ -n "$RSYNC_FLAGS_INPUT" ]; then
    # Completely replaces the default flags with custom ones
    RSYNC_FLAGS="$RSYNC_FLAGS_INPUT"
elif [ -n "$RSYNC_APPEND_FLAGS_INPUT" ]; then
    # Appends custom flags to the default ones
    RSYNC_FLAGS="$RSYNC_FLAGS $RSYNC_APPEND_FLAGS_INPUT"
fi

# Appends any exclusion flags generated by -ex/--exclude
if [ -n "$RSYNC_EXCLUDE_FLAGS" ]; then
    RSYNC_FLAGS="$RSYNC_FLAGS $RSYNC_EXCLUDE_FLAGS"
fi

if [ -n "$EXCLUDE_FILE_FOR_RSYNC" ]; then
    RSYNC_FLAGS="$RSYNC_FLAGS --exclude-from=\"$EXCLUDE_FILE_FOR_RSYNC\"";
fi

# -----------------------------------------------------------------------------
# Log Directory Setup
# -----------------------------------------------------------------------------

# Log Directory default path
DEFAULT_LOG_DIR="$HOME/.rsync-time-backup"

# If --log-dir is not set, use default or destination
if [ -z "$LOG_DIR" ]; then
    if [ "$LOG_TO_DESTINATION" = true ]; then
        # Set log directory to destination
        LOG_DIR="$DEST_FOLDER/.rsync-time-backup-log"
        AUTO_DELETE_LOG=0 # Don't auto-delete if log is in destination
    else
        # Use default log directory
        LOG_DIR="$DEFAULT_LOG_DIR"
    fi
else
    # If --log-dir is set, don't auto-delete
    AUTO_DELETE_LOG=0
fi

# Ensure log directory exists
fn_mkdir "$LOG_DIR"

# -----------------------------------------------------------------------------
# Main backup logic
# -----------------------------------------------------------------------------

# -----------------------------------------------------------------------------
# Handle --prune option (New Block)
# -----------------------------------------------------------------------------
if [ "$ONLY_PRUNE" = true ]; then
    fn_log_info "Performing pruning based on strategy: $EXPIRATION_STRATEGY"
    # When only pruning, we don't have a new backup. Apply strategy to all existing backups.
    fn_expire_backups ""
    fn_log_info "Pruning completed."
    exit 0
fi

# REMOVED DUPLICATE fn_run_cmd DEFINITION HERE

# Loop indefinitely, doing backups
while : ; do
    DATE_DIR=$(date "+%Y-%m-%d-%H%M%S")
    DEST="$DEST_FOLDER/$DATE_DIR"
    LOG_FILE="$LOG_DIR/$DATE_DIR.log"
    INPROGRESS_FILE="$DEST_FOLDER/in_progress"

    # -----------------------------------------------------------------------------
    # Check if a backup is already in progress
    # -----------------------------------------------------------------------------
    if [ -f "$INPROGRESS_FILE" ]; then
        LAST_INPROGRESS_PID=$(cat "$INPROGRESS_FILE")
        if kill -0 "$LAST_INPROGRESS_PID" 2>/dev/null; then
            fn_log_error "A backup is already in progress (PID $LAST_INPROGRESS_PID). Aborting."
            exit 1
        else
            fn_log_warn "A previous backup seems to have crashed. Resuming."
            fn_rm_file "$INPROGRESS_FILE"
        fi
    fi

    # -----------------------------------------------------------------------------
    # Create the backup destination folder
    # -----------------------------------------------------------------------------
    fn_mkdir "$DEST"
    fn_mkdir "$DEST/tmp"
    echo $$ > "$INPROGRESS_FILE"

    # -----------------------------------------------------------------------------
    # Purge certain old backups before beginning new backup. (Updated Block)
    # -----------------------------------------------------------------------------
    if [ -n "$PREVIOUS_DEST" ]; then
        # regardless of expiry strategy keep backup used for --link-dest
        fn_expire_backups "$PREVIOUS_DEST"
    else
        # keep latest backup (if no previous dest, this is the current one we are about to create)
        fn_expire_backups "$DEST"
    fi

    # -----------------------------------------------------------------------------
    # Perform the backup
    # -----------------------------------------------------------------------------

    fn_log_info "Starting backup from '$SRC_FOLDER' to '$DEST_FOLDER/'"
    fn_log_info_cmd "rsync $RSYNC_FLAGS '$SRC_FOLDER' '$DEST'"

    if [ "$DRY_RUN" != true ]; then
        rsync $RSYNC_FLAGS "$SRC_FOLDER" "$DEST" > "$LOG_FILE" 2>&1
    fi

    # -----------------------------------------------------------------------------
    # Check for disk space (Updated Block)
    # -----------------------------------------------------------------------------
    DISKSPACE=`df -H "$DEST_FOLDER" | sed '1d' | awk '{print $5}' | cut -d'%' -f1`

    if (( ${DISKSPACE} > 90 )); then
        if [ "$AUTO_EXPIRE" = "1" ]; then
            fn_log_warn "No space left on device - removing oldest backup and resuming."

            if [[ "$(fn_find_backups | wc -l)" -lt "2" ]]; then
                fn_log_error "No space left on device, and no old backup to delete."
                exit 1
            fi

            fn_expire_backup "$(fn_find_backups | tail -n 1)"

            # Resume backup
            continue
        else
            fn_log_error "No space left on device, and automatic purging of old backups is disabled (--no-auto-expire). Aborting backup."
            exit 1
        fi
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
        fn_rm_file "$DEST_FOLDER/latest"
        fn_ln "$(basename -- "$DEST")" "$DEST_FOLDER/latest"
    fi

    fn_rm_file "$INPROGRESS_FILE"
    rm -f -- "$LOG_FILE"
    break
done
