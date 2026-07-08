FROM cgr.dev/chainguard/go:latest-dev

RUN apk add npm meson git nasm cmake
COPY build/ /build
RUN sh /build/build.sh
