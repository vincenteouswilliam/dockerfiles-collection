FROM ubuntu:latest
LABEL org.opencontainers.image.source=https://github.com/NTT-AP-ID/nttid-others-container-registry-test

RUN apt update && apt -y upgrade

RUN groupadd -g 1000 nttit \
    && useradd -u 1000 -g 1000 -m -d /home/nttit -s /bin/bash -c "New user for container" nttit \
    && chown -R nttit:nttit /home/nttit

WORKDIR /home/nttit
USER nttit
CMD [ "bash" ]
