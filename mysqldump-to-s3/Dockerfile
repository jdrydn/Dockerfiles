# @author: James D <james@jdrydn.com> (https://jdrydn.com)
# @license: MIT
# @link: https://github.com/jdrydn/Dockerfiles/tree/master/mysqldump-to-s3
# @link: https://github.com/schickling/dockerfiles/blob/master/mysql-backup-s3/Dockerfile
FROM alpine:latest

ADD install.sh install.sh
RUN sh install.sh && rm install.sh

ENV MYSQLDUMP_OPTIONS --single-transaction --compress --compact
ENV MYSQL_HOST localhost
ENV MYSQL_PORT 3306
ENV MYSQL_USER mysql
ENV MYSQL_PASSWORD ""
ENV MYSQL_DATABASE ""
ENV S3_BUCKET **MISSING**
ENV S3_PREFIX ""
ENV S3_FILENAME ""

ADD backup.sh backup.sh
CMD [ "sh", "backup.sh" ]
