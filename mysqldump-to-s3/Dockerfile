FROM alpine:latest
LABEL org.opencontainers.image.url https://github.com/someimportantcompany/Dockerfiles/tree/master/mysqldump-to-s3
LABEL org.opencontainers.image.source https://github.com/someimportantcompany/Dockerfiles

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
