FROM rclone/rclone:latest
MAINTAINER jdrydn <james@jdrydn.com> (https://jdrydn.com)

ENV GITHUB_TOKEN **MISSING**
ENV S3_BUCKET **MISSING**
ENV S3_PREFIX ""
ENV S3_FILENAME ""

ADD backup.sh backup.sh
ENTRYPOINT [ "sh", "backup.sh" ]
