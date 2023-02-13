FROM ubuntu:latest

# Update and install sudo package
RUN apt-get update && apt-get install -y sudo

# Create base non-root group and user and add sudoers
RUN groupadd -g 1000 apps && \
    useradd -u 1000 -g 1000 -m -d /home/apps -s /bin/bash -c "Base user" apps && \
    chown -R apps:apps /home/apps && \
    echo "apps     ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/user-apps && \
    chmod 600 /etc/sudoers.d/user-apps

# Change default user & work directory
USER apps
WORKDIR /home/apps

# Execute shell
CMD ["bash"]
