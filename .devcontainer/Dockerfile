FROM --platform=linux/amd64 mcr.microsoft.com/devcontainers/base:ubuntu-24.04

RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
    && apt-get -y install --no-install-recommends git build-essential flex bison libssl-dev bc cpio file pipx gcc-arm-none-eabi

RUN pipx install git+https://github.com/TuxSH/firmtool.git
