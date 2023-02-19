ARG BUILD_ARCH="arm64"
ARG BUILD_VER="v8"
ARG UBUNTU_VER=latest
ARG PWSH_BUILD

FROM --platform=linux/${BUILD_ARCH}/${BUILD_VER} ubuntu:${UBUNTU_VER} as base
ARG UBUNTU_VER
ARG BUILD_ARCH

# Install tzdata package first due to interactivity in dependencies installation
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y tzdata

# Install dependencies based on Ubuntu version
ARG BASE_PACKAGE="sudo curl libc6 libgcc1 libgssapi-krb5-2 libstdc++6 zlib1g"
RUN if [ "${UBUNTU_VER}" = "latest" ] || [ "${UBUNTU_VER}" = "22.04" ]; then \
    DEP_PACKAGES="${BASE_PACKAGE} libgcc-s1 libicu70 liblttng-ust1 libssl3 libunwind8"; \
    elif [ "${UBUNTU_VER}" = "20.04" ]; then \
    DEP_PACKAGES="${BASE_PACKAGE} libicu66 libssl1.1"; fi; \
    apt-get install -y ${DEP_PACKAGES}

# Specify latest Powershell version for both stable and LTS builds
FROM base as build-lts
ARG PWSH_VERSION="7.2.9"

FROM base as build-stable
ARG PWSH_VERSION="7.3.2"

# Determine the variation based on the input argument
FROM build-${PWSH_BUILD} as final
ARG BUILD_ARCH
ARG PWSH_VERSION

# Install and setup powershell environment
RUN [ "${BUILD_ARCH}" = "arm" ] && BUILD_ARCH="arm32"; \
    curl -L -o /tmp/powershell.tar.gz https://github.com/PowerShell/PowerShell/releases/download/v${PWSH_VERSION}/powershell-${PWSH_VERSION}-linux-${BUILD_ARCH}.tar.gz; \
    mkdir -p /opt/microsoft/powershell/7; \
    tar zxf /tmp/powershell.tar.gz -C /opt/microsoft/powershell/7; \
    chmod +x /opt/microsoft/powershell/7/pwsh; \
    ln -s /opt/microsoft/powershell/7/pwsh /usr/bin/pwsh; \
    rm -f /tmp/powershell.tar.gz

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