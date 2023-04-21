#!/bin/sh
# @author: James D <james@jdrydn.com> (https://jdrydn.com)
# @license: MIT
# @link: https://github.com/jdrydn/Dockerfiles/tree/master/mysqldump-to-s3
# @link: https://github.com/schickling/dockerfiles/blob/master/mysql-backup-s3/install.sh
set -e

apk update

# mysqldump
apk add mysql-client
# aws-cli
apk add python3 py3-pip
pip install awscli
apk del py3-pip

# Cleanup
rm -rf /var/cache/apk/*
