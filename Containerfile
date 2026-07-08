FROM cgr.dev/chainguard/go:latest-dev

RUN apk add npm meson git nasm cmake libass-dev libopus-dev x264-dev zlib-dev
COPY build/ /build
RUN sh /build/build.sh
