FROM docker.io/debian:sid-slim

RUN export DEBIAN_FRONTEND="noninteractive"
RUN apt-get update && apt-get -y upgrade
RUN apt-get -y install ffmpeg golang-go npm meson build-essential git libass-dev nasm mold gcc-14-aarch64-linux-gnu g++-14-aarch64-linux-gnu debootstrap
COPY build.sh /
RUN /build.sh
