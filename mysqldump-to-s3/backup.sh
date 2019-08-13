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

if [ "${S3_FILENAME}" == "" ]; then
  S3_FILENAME="%Y%m%dT%H%M%SZ"
fi

MYSQL_OPTS="-h ${MYSQL_HOST} -P ${MYSQL_PORT} -u${MYSQL_USER}"
if [ "${MYSQL_PASSWORD}" != "" ]; then
  MYSQL_OPTS="${MYSQL_OPTS} -p${MYSQL_PASSWORD}"
fi

if [ "${MYSQL_DATABASE}" == "" ]; then
  MYSQL_DATABASE=`mysql $MYSQL_OPTS -e "SHOW DATABASES;" | grep -Ev "(Database|information_schema|performance_schema|mysql|sys|innodb)"`
  throw_err "$?" "Failed to list databases"
else
  mysql $MYSQL_OPTS $MYSQL_DATABASE -e "SHOW TABLES;" >> /dev/null
  throw_err "$?" "Failed to connect to ${MYSQL_DATABASE}"
  DATABASES="${MYSQL_DATABASE}"
fi

S3_FILENAME=$(date +"${S3_FILENAME}")

for DB in $MYSQL_DATABASE; do
  S3_URL="s3://${S3_BUCKET}/${S3_PREFIX}${S3_FILENAME}.${DB}.sql.gz"
  echo "ACTION: Creating individual dump of ${DB} from ${MYSQL_HOST} to ${S3_URL}"
  mysqldump $MYSQL_OPTS $MYSQLDUMP_OPTIONS --databases $DB | gzip | aws s3 cp - $S3_URL
  throw_err "$?" "mysqldump/s3cmd failed - check the output for more"
done

echo "SUCCESS!"
