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
ARG BASE_PACKAGE="libc6 libgcc1 libgssapi-krb5-2 libstdc++6 zlib1g"
RUN if [ "${UBUNTU_VER}" = "latest" ] || [ "${UBUNTU_VER}" = "22.04" ]; then \
    DEP_PACKAGES="${BASE_PACKAGE} libgcc-s1 libicu70 liblttng-ust1 libssl3 libunwind8"; \
    elif [ "${UBUNTU_VER}" = "20.04" ]; then \
    DEP_PACKAGES="${BASE_PACKAGE} libicu66 libssl1.1"; fi; \
    apt-get install -y curl "${DEP_PACKAGES}"

# Specify latest Powershell version for both stable and LTS builds
FROM base as build-lts
ARG PWSH_VERSION="7.2.9"

FROM base as build-stable
ARG PWSH_VERSION="7.3.2"

FROM build-${PWSH_BUILD} as final
ARG BUILD_ARCH
ARG PWSH_VERSION

#CMD ["pwsh"]