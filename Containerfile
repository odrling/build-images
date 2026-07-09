FROM cgr.dev/chainguard/go:latest-dev

RUN apk add --no-cache npm meson python3 git nasm cmake libass-dev opus-dev x264-dev zlib-dev
COPY build/ /build
RUN sh /build/build.sh
