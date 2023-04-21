FROM alpine:latest
LABEL org.opencontainers.image.url https://github.com/someimportantcompany/Dockerfiles/tree/master/rclone
LABEL org.opencontainers.image.source https://github.com/someimportantcompany/Dockerfiles

ADD install.sh install.sh
RUN sh install.sh && rm install.sh

CMD [ "rclone", "help" ]
