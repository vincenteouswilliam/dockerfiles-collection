ARG UBUNTU_VER=latest
ARG PWSH_OPT

FROM --platform=linux/amd64 ubuntu:${UBUNTU_VER} AS base
WORKDIR /root

# Install tzdata package first due to interactivity in dependencies installation
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y tzdata

# Set Powershell latest build package as variation 1
FROM base AS variation-1
ARG PWSH_PKG="powershell"

# Set Powershell LTS build package as variation 2
FROM base as variation-2
ARG PWSH_PKG="powershell-lts"

# Determine the variation based on input argument
FROM variation-${PWSH_OPT} as final

# Install Sudo and Powershell package
RUN apt-get install -y sudo wget apt-transport-https software-properties-common && \
    wget -q "https://packages.microsoft.com/config/ubuntu/$(lsb_release -rs)/packages-microsoft-prod.deb" && \
    dpkg -i packages-microsoft-prod.deb && \
    apt-get update && \
    apt-get install -y ${PWSH_PKG} && \
    rm -f packages-microsoft-prod.deb

# Create base non-root group and user and add sudoers
RUN groupadd -g 1000 apps && \
    useradd -u 1000 -g 1000 -m -d /home/apps -s /usr/bin/pwsh -c "Base user" apps && \
    chown -R apps:apps /home/apps && \
    echo "apps     ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/user-apps && \
    chmod 600 /etc/sudoers.d/user-apps

# Change default user & work directory
USER apps
WORKDIR /home/apps

# Execute shell
CMD ["pwsh"]
