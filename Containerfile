FROM docker.io/debian:sid-slim

RUN export DEBIAN_FRONTEND="noninteractive"
RUN apt-get update && apt-get -y upgrade
RUN apt-get -y install golang-go npm meson build-essential git libass-dev nasm
COPY build.sh /
RUN /build.sh
