#!/usr/bin/env bash
set -e
set -x

FFMPEG_VER="9.0"

if [ ! -d /deps/ffmpeg ]; then
    git clone --depth 1 --branch "release/${FFMPEG_VER}" https://github.com/FFmpeg/FFmpeg.git /deps/ffmpeg
fi

# ffmpeg (program) used by karaberus tests
ffmpeg_exe_args=(
    --enable-static
    --enable-pic
    --disable-shared
    --disable-doc
    --disable-decoders
    --disable-encoders
    --disable-demuxers
    --enable-zlib
    --enable-gpl
    --enable-version3
    --enable-libx264
    --enable-libopus
    --enable-encoder=libx264
    --enable-encoder=libopus
    --enable-decoder=wrapped_avframe
    --enable-decoder=pcm_s16le
    --enable-filter=aresample
    --enable-filter=scale
)
mkdir -p /deps/ffmpeg_exe_build
cd /deps/ffmpeg_exe_build
PKG_CONFIG_SYSROOT_DIR="" /deps/ffmpeg/configure "${ffmpeg_exe_args[@]}"
PKG_CONFIG_SYSROOT_DIR="" make -j$(nproc)
make install


# ffmpeg (libraries) used by karaberus
ffmpeg_decoders=(
    aac
    ac3
    adpcm_ima_wav
    adpcm_ms
    dts
    flac
    mp2
    mp3
    opus
    pcm_s16le
    pcm_u8
    vorbis
    wmav2
)

ffmpeg_filters=(
    loudnorm
    anullsink
)

ffmpeg_configure_args=(
    --enable-shared
    --enable-pic
    --disable-static
    --disable-autodetect
    --disable-programs
    --disable-avdevice
    --disable-filters
    --disable-swscale
    --disable-doc
    --disable-muxers
    --disable-network
    --disable-encoders
    --disable-decoders
    --disable-bsfs
    --disable-protocols
    --enable-filter=aresample
    --enable-zlib
    --enable-version3
)

for decoder in "${ffmpeg_decoders[@]}"; do
    ffmpeg_configure_args+=("--enable-decoder=${decoder}")
done

for filter in "${ffmpeg_filters[@]}"; do
    ffmpeg_configure_args+=("--enable-filter=${filter}")
done

mkdir -p /deps/ffmpeg_build
cd /deps/ffmpeg_build
/deps/ffmpeg/configure "${ffmpeg_configure_args[@]}"
make -j$(nproc)
make install
