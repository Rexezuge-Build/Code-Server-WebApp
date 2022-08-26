FROM debian:11-slim

RUN apt update \
 && apt upgrade -y \
 && apt install -y curl \
 && curl -fOL https://github.com/coder/code-server/releases/download/v3.12.0/code-server_3.12.0_amd64.deb \
 && dpkg -i code-server_3.12.0_amd64.deb \
 && apt autoremove --purge -y curl \
 && rm code-server_3.12.0_amd64.deb

EXPOSE 8080/tcp

ADD config.yaml /root/.config/code-server/config.yaml

ENTRYPOINT code-server
