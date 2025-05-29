FROM --platform=linux/amd64 mcr.microsoft.com/devcontainers/base:ubuntu-24.04

RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
    && apt-get -y install --no-install-recommends git build-essential flex bison libssl-dev bc cpio file pipx gcc-arm-none-eabi libnewlib-arm-none-eabi

RUN PIPX_HOME=/opt/pipx PIPX_BIN_DIR=/usr/local/bin pipx install git+https://github.com/TuxSH/firmtool.git
