#!/usr/bin/env bash
#
# Modified rsync time machine backup script with fixed retention logic
# Reverse-prunes from newest to oldest to correctly maintain fixed window

set -o errexit
set -o nounset
set -o pipefail
IFS=$'\n\t'

# ----------------------------------------------------------------------------------------------------------------------
# Initialize script
# ----------------------------------------------------------------------------------------------------------------------

readonly APPNAME="rsync-time-backup"
readonly VERSION=3
echo "$APPNAME: Version $VERSION"

# Redirect all subsequent stdout and stderr to log file
case "${1:-""}" in
  --no-stdout-redirect) ;;
  *) 
    if [ -z "${REDIRECTED:-}" ]; then
    # Redirect all output to log file
    exec > >(while IFS='' read -r line; do echo "$(date '+%Y-%m-%d %H:%M:%S'): $line" >> "/tmp/$APPNAME-$$.log"; done)
    exec 2>&1
    export REDIRECTED=true
    fi
esac

# ----------------------------------------------------------------------------------------------------------------------
# Functions
# ----------------------------------------------------------------------------------------------------------------------

# Log functions
fn_log_info()  { echo "$APPNAME: $1"; }
fn_log_warn()  { echo "$APPNAME: [WARNING] $1" 1>&2; }
fn_log_error() { echo "$APPNAME: [ERROR] $1" 1>&2; }

# Error handling
fn_terminate_script() { fn_log_info "SIGINT caught."; exit 1; }
trap fn_terminate_script SIGINT

# Directory/file operations
fn_rm_dir()  { if [ -d "$1" ]; then rm -rf "$1"; fi; }
fn_mkdir()   { if [ ! -d "$1" ]; then mkdir -p "$1"; fi; }
fn_rm_file() { if [ -f "$1" ]; then rm -f "$1"; fi; }
fn_ln()      { ln -sfn "$1" "$2"; }

# ssh command wrapper
SSH_CMD=""
fn_run_cmd() {
    if [ -n "$SSH_CMD" ]; then
        $SSH_CMD "$1" 2>/dev/null
    else
        eval "$1" 2>/dev/null
    fi
}

# Find backup marker
fn_find_backup_marker() {
    find "$1" -maxdepth 2 -name "backup.marker" -o -name "backup.marker.tmp" | head -1
}

# Find backups (sorted NEWEST first, critical for correct retention)
fn_find_backups() {
    local backup_dest="$1"
    if [ -z "${backup_dest:-}" ]; then
        backup_dest="$DEST_FOLDER"
    fi
    
    find "$backup_dest" -maxdepth 1 -type d -name "????-??-??-??????" | sort
}

# Parse date (with fallback)
fn_parse_date() {
    local date_str="$1"
    local timestamp=""
    
    if [[ "$date_str" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}-[0-9]{6}$ ]]; then
        timestamp=$(date -d "${date_str:0:10} ${date_str:11:2}:${date_str:13:2}:${date_str:15:2}" +%s 2>/dev/null || echo "")
    fi
    
    if [ -n "$timestamp" ]; then
        echo "$timestamp"
    elif [ -n "${date_str:-}" ]; then
        date -d "$date_str" +%s 2>/dev/null || echo ""
    else
        echo ""
    fi
}

# ----------------------------------------------------------------------------------------------------------------------
# Main pruning function (FIXED: Reverse timeline logic)
# ----------------------------------------------------------------------------------------------------------------------
fn_rm_dir_safely() {
    local path="$1"
    if [ -d "$path" ]; then
        fn_log_info "Deleting: $(basename "$path")"
        fn_rm_dir "$path"
    fi
}

fn_expire_backups() {
    local current_timestamp="${EPOCH:-$(date +%s)}"
    local backup_dest="${1:-$DEST_FOLDER}"
    
    # Get backups sorted NEWEST first
    local backups=($(fn_find_backups "$backup_dest" | sort -r))
    
    if [ ${#backups[@]} -eq 0 ]; then
        fn_log_info "No backups found to prune"
        return 0
    fi
    
    # Set the anchor to "Today" (or NOW) instead of the oldest backup
    local last_kept_timestamp="$current_timestamp"
    local kept_count=0
    
    fn_log_info "Starting reverse-prune with ${#backups[@]} backups..."
    
    for backup_dir in "${backups[@]}"; do
        local backup_name=$(basename "$backup_dir")
        local backup_timestamp=$(fn_parse_date "$backup_name")
        
        if [ -z "$backup_timestamp" ]; then
            fn_log_warn "Could not parse date for: $backup_name"
            continue
        fi
        
        local backup_is_latest=false
        [ "$backup_dir" == "${backups[0]}" ] && backup_is_latest=true
        
        # Always keep the newest backup
        if [ "$backup_is_latest" = true ]; then
            fn_log_info "KEEP [LATEST]: $backup_name"
            last_kept_timestamp=$backup_timestamp
            ((kept_count++))
            continue
        fi
        
        # Process strategy tokens IN ORDER from oldest to newest
        local backup_age_days=$(( (current_timestamp - backup_timestamp) / 86400 ))
        local token_matched=false
        
        # Convert strategy to array for proper parsing
        IFS=' ' read -ra tokens <<< "$EXPIRATION_STRATEGY"
        
        for token in "${tokens[@]}"; do
            IFS=':' read -r range_days interval_days <<< "$token"
            
            if [ "$backup_age_days" -le "$range_days" ]; then
                token_matched=true
                local days_since_last_kept=$(( (last_kept_timestamp - backup_timestamp) / 86400 ))
                
                if [ "$backup_age_days" -eq 0 ]; then
                    # Today - keep everything from today
                    fn_log_info "KEEP [TODAY]: $backup_name"
                    last_kept_timestamp=$backup_timestamp
                    ((kept_count++))
                elif [ "$interval_days" -eq 0 ]; then
                    # Delete all in this range (except latest which we already kept)
                    fn_rm_dir_safely "$backup_dir"
                elif [ "$days_since_last_kept" -ge "$interval_days" ]; then
                    # Keep this backup and set it as new anchor
                    fn_log_info "KEEP [$token]: $backup_name ($days_since_last_kept days since last kept)"
                    last_kept_timestamp=$backup_timestamp
                    ((kept_count++))
                else
                    # Not enough time passed - delete
                    fn_rm_dir_safely "$backup_dir"
                fi
                
                break  # Only one strategy token applies
            fi
        done
        
        # If no token matched, it's older than any strategy - use default keep logic
        if [ "$token_matched" = false ] && [ "$backup_is_latest" = false ]; then
            if [ "$kept_count" -lt 3 ]; then
                fn_log_info "KEEP [OLD DEFAULT]: $backup_name (keeping minimum of 3 backups)"
                ((kept_count++))
            else
                fn_rm_dir_safely "$backup_dir"
            fi
        fi
    done
    
    fn_log_info "Reverse-prune complete: $kept_count backups retained"
}

# ----------------------------------------------------------------------------------------------------------------------
# Backup execution
# ----------------------------------------------------------------------------------------------------------------------

# Parse arguments
SRC_FOLDER=""
DEST_FOLDER=""
EXPIRATION_STRATEGY="1:1 7:7 30:7 365:30"
AUTO_EXPIRE=1
DRY_RUN=false
ONLY_PRUNE=false
PRUNE_THEN_BACKUP=false
RSYNC_FLAGS="-aAXx --quiet --delete --numeric-ids"
RSYNC_APPEND_FLAGS=""
LOG_DIR=""
SSH_PORT="22"
DEFAULT_LOG_DIR="$HOME/.rsync-time-backup"

while [ $# -gt 0 ]; do
    case "$1" in
        -s|--source)
            SRC_FOLDER="$2"
            shift 2
            ;;
        -d|--destination)
            DEST_FOLDER="$2"
            shift 2
            ;;
        --strategy)
            EXPIRATION_STRATEGY="$2"
            shift 2
            ;;
        --prune-then-backup)
            PRUNE_THEN_BACKUP=true
            shift
            ;;
        --no-auto-expire)
            AUTO_EXPIRE=0
            shift
            ;;
        --dry-run|-x)
            DRY_RUN=true
            shift
            ;;
        --only-prune)
            ONLY_PRUNE=true
            shift
            ;;
        --rsync-append-flags)
            RSYNC_APPEND_FLAGS="$2"
            shift 2
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done

# Validation
if [ -z "$SRC_FOLDER" ] || [ -z "$DEST_FOLDER" ]; then
    fn_log_error "Usage: $0 -s SOURCE -d DESTINATION [OPTIONS]"
    fn_log_error "  -s, --source       The source location"
    fn_log_error "  -d, --destination  The destination location"
    fn_log_error "  --strategy         Retention strategy (e.g., '1:1 7:7 30:7 365:30')"
    fn_log_error "  --prune-then-backup  Prune old backups before creating new one"
    fn_log_error "  --no-auto-expire   Prevent automatic pruning"
    fn_log_error "  --dry-run          Show what would be done without changes"
    exit 1
fi

# Set default log directory if not provided
if [ -z "$LOG_DIR" ]; then
    LOG_DIR="$DEFAULT_LOG_DIR"
fi

fn_mkdir "$LOG_DIR"
fn_mkdir "$DEST_FOLDER"

if [ ! -f "$DEST_FOLDER/backup.marker" ]; then
    touch "$DEST_FOLDER/backup.marker"
fi

EPOCH=$(date +%s)
log_file="$LOG_DIR/$(basename "$0" | cut -d. -f1)-$(date +%Y%m%d-%H%M%S).log"

# Redirect stdout/stderr to log file and console
tail -F "$log_file" 2>/dev/null &
TAIL_PID=$!
exec > >(tee -a "$log_file" >&1)
exec 2>&1

fn_log_info "Starting backup from '$SRC_FOLDER' to '$DEST_FOLDER/'"
fn_log_info "Strategy: $EXPIRATION_STRATEGY"

# Only prune
if [ "$ONLY_PRUNE" = true ]; then
    fn_log_info "Running in prune-only mode"
    fn_expire_backups ""
    fn_log_info "Prune-only mode completed"
    exit 0
fi

# Prune then backup
if [ "$PRUNE_THEN_BACKUP" = true ]; then
    fn_log_info "Pruning old backups before starting backup (strategy: $EXPIRATION_STRATEGY)"
    fn_expire_backups ""
    fn_log_info "Pre-backup pruning completed"
fi

# Main backup loop
INPROGRESS_FILE="$DEST_FOLDER/in_progress"
while : ; do
    DATE_DIR=$(date +%Y-%m-%d-%H%M%S)
    DEST="$DEST_FOLDER/$DATE_DIR"
    
    # Check if backup is in progress
    if [ -f "$INPROGRESS_FILE" ]; then
        LAST_PID=$(cat "$INPROGRESS_FILE")
        if kill -0 "$LAST_PID" 2>/dev/null; then
            fn_log_error "Backup already in progress (PID $LAST_PID)"
            exit 1
        else
            fn_log_warn "Previous backup crashed, resuming"
            fn_rm_file "$INPROGRESS_FILE"
        fi
    fi
    
    fn_mkdir "$DEST"
    fn_mkdir "$DEST/tmp"
    echo $$ > "$INPROGRESS_FILE"
    
    # Run rsync
    full_rsync_flags="$RSYNC_FLAGS $RSYNC_APPEND_FLAGS"
    fn_log_info "Executing: rsync $full_rsync_flags '$SRC_FOLDER' '$DEST'"
    
    if [ "$DRY_RUN" != true ]; then
        rsync $full_rsync_flags "$SRC_FOLDER" "$DEST" > "$LOG_DIR/last-rsync.log" 2>&1
        RSYNC_EXIT=$?
        
        if [ $RSYNC_EXIT -eq 0 ]; then
            fn_log_info "Rsync completed successfully"
        else
            fn_log_error "Rsync failed with exit code $RSYNC_EXIT"
            fn_rm_file "$INPROGRESS_FILE"
            exit 1
        fi
    else
        fn_log_info "DRY RUN: Would have executed rsync"
    fi
    
    if [ "$DRY_RUN" != true ]; then
        fn_rm_file "$DEST_FOLDER/latest"
        fn_ln "$(basename -- "$DEST")" "$DEST_FOLDER/latest"
    fi
    
    fn_rm_file "$INPROGRESS_FILE"
    fn_log_info "Backup completed: $DEST"
    
    # Post-backup pruning (keeps latest)
    fn_log_info "Post-backup pruning (keeps latest)"
    fn_expire_backups "$DEST"
    
    break
done

fn_log_info "Backup process completed successfully"
kill $TAIL_PID 2>/dev/null || true
exit 0
