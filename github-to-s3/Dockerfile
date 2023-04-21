FROM rclone/rclone:latest
LABEL org.opencontainers.image.url https://github.com/someimportantcompany/Dockerfiles/tree/master/github-to-s3
LABEL org.opencontainers.image.source https://github.com/someimportantcompany/Dockerfiles

ENV GITHUB_TOKEN **MISSING**
ENV S3_BUCKET **MISSING**
ENV S3_PREFIX ""
ENV S3_FILENAME ""

ADD backup.sh backup.sh
ENTRYPOINT [ "sh", "backup.sh" ]
