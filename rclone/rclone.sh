#!/bin/sh
# @author: James D <james@jdrydn.com> (https://jdrydn.com)
# @license: MIT
# @link: https://github.com/jdrydn/Dockerfiles/tree/master/rclone
if [ "${S3_CONFIG}" != "" ]; then
  aws s3 cp $S3_CONFIG ./rclone.conf
  if [ "$?" -ne "0" ]; then
    echo "ERROR: Failed to download S3_CONFIG from ${S3_CONFIG}"
    exit 1
  fi
fi

exec rclone $@
