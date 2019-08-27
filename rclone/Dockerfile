FROM alpine:latest
MAINTAINER jdrydn <james@jdrydn.com> (https://jdrydn.com)

ADD install.sh install.sh
RUN sh install.sh && rm install.sh

CMD [ "rclone", "help" ]
