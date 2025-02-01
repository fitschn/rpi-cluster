#!/bin/bash

# Exit on error
set -o errexit

CMD="$1" # start / stop

RESTIC_REPOSITORY=$(cat "$CREDENTIALS_DIRECTORY/restic_repo")
RESTIC_PASSWORD=$(cat "$CREDENTIALS_DIRECTORY/restic_pass")
AWS_ACCESS_KEY_ID=$(cat "$CREDENTIALS_DIRECTORY/aws_access_key")
AWS_SECRET_ACCESS_KEY=$(cat "$CREDENTIALS_DIRECTORY/aws_secret_key")

export RESTIC_REPOSITORY
export RESTIC_PASSWORD
export AWS_ACCESS_KEY_ID
export AWS_SECRET_ACCESS_KEY

# start / stop light
case $CMD in
  backup)
    /opt/restic/restic backup --files-from /etc/restic/backup_files_list
    /opt/restic/restic forget --keep-daily 5 --keep-weekly 1 --keep-monthly 1 --keep-yearly 1 --prune
    /opt/restic/restic check
    exit 0
  ;;

  *)
    echo "Unknown parameter. Only backup is allowed"
    exit 1
  ;;
esac
