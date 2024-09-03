FROM docker.io/debian:sid-slim

ARG TARGET=""

RUN export DEBIAN_FRONTEND="noninteractive"
RUN apt-get update && apt-get -y upgrade
RUN apt-get -y install ffmpeg golang-go npm meson git nasm mold
COPY build/ /build
RUN TARGET=${TARGET} sh /build/build.sh
