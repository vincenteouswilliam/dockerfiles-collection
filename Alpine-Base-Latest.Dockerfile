ARG ALP_VERSION=latest

FROM alpine:${ALP_VERSION}

# Update and install sudo package
RUN apk update && apk add sudo

# Create base non-root user and add sudoers
RUN adduser -h /home/apps -s /bin/ash -D apps; \
    chmod 755 /home/apps; \
    echo "apps     ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/user-apps; \
    chmod 600 /etc/sudoers.d/user-apps

# Change default user & work directory
USER apps
WORKDIR /home/apps

# Execute shell
CMD ["ash"]