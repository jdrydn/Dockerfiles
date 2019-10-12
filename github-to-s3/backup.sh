#!/bin/sh
# @author: James D <james@jdrydn.com> (https://jdrydn.com)
# @license: MIT
# @link: https://github.com/jdrydn/Dockerfiles/tree/master/mysqldump-to-s3
# @link: https://github.com/schickling/dockerfiles/blob/master/mysql-backup-s3/backup.sh
set -o pipefail

function throw_err() {
  if [ "$1" -ne "0" ]; then
    echo "ERROR: $2"
    exit "$1"
  fi
}

if [ "${S3_BUCKET}" == "**MISSING**" ]; then
  throw_err 1 "You need to set the S3_BUCKET environment variable"
fi
if [ "${GITHUB_TOKEN}" == "**MISSING**" ]; then
  throw_err 1 "You need to set the GITHUB_TOKEN environment variable"
fi

export RCLONE_CONFIG_S3_TYPE=${RCLONE_CONFIG_S3_TYPE:-'s3'}
export RCLONE_CONFIG_S3_PROVIDER=${RCLONE_CONFIG_S3_PROVIDER:-'AWS'}
export RCLONE_CONFIG_S3_ENV_AUTH=${RCLONE_CONFIG_S3_ENV_AUTH:-'true'}
export RCLONE_CONFIG_S3_ACL=${RCLONE_CONFIG_S3_ACL:-'private'}
export S3_FILENAME=$(date +"${S3_FILENAME:-'%Y%m%dT%H%M%SZ'}")

for REPO in $@; do
  GITHUB_URL="https://${GITHUB_TOKEN}@api.github.com/repos/$REPO/tarball"
  ESCAPED_REPO="$(echo $(echo $REPO | tr '/' '-') | sed -e 's/[]\/$*.^[]/\\\\&/g')"
  S3_URL="s3:${S3_BUCKET}/${S3_PREFIX}${S3_FILENAME}-${ESCAPED_REPO}.tar.gz"
  echo "ACTION: Downloading ${REPO} to ${S3_URL}"
  ./rclone copyurl $GITHUB_URL $S3_URL
  throw_err "$?" "rclone failed - check the output for more"
done

echo "SUCCESS!"
