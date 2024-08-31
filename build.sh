#!/bin/sh -ex
git clone --depth 1 --branch release/7.0 https://github.com/FFmpeg/FFmpeg.git /deps/ffmpeg
mkdir /deps/ffmpeg_build
cd /deps/ffmpeg_build
/deps/ffmpeg/configure --enable-shared --disable-static --disable-autodetect --disable-programs --disable-avdevice --disable-postproc --disable-avfilter --disable-swscale --disable-swresample --disable-doc --disable-muxers --disable-network --disable-encoders --disable-decoders --disable-bsfs --disable-protocols --enable-zlib --enable-bzlib --enable-decoder=aac --toolchain=hardened --enable-lto --extra-cflags=-fsanitize=undefined
make -j$(nproc)
make install
