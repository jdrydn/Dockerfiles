#!/bin/sh
# @author: James D <james@jdrydn.com> (https://jdrydn.com)
# @license: MIT
# @link: https://github.com/jdrydn/Dockerfiles/tree/master/rclone
set -e

apk update

# aws-cli
apk add python3 py3-pip
pip install awscli
apk del py3-pip

# install rclone
apk add --no-cache wget
wget -q https://downloads.rclone.org/rclone-current-linux-amd64.zip -O /tmp/rclone.zip
unzip -d /tmp/ /tmp/rclone.zip
mv /tmp/rclone-*/rclone /usr/bin
rm -r /tmp/rclone*
apk del wget

# Cleanup
rm -rf /var/cache/apk/*
