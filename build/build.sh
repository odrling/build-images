#!/usr/bin/env bash
set -e
set -x

GCL_VER=v2.11.2
ZLIB_VER="v1.3.2"
LIBASS_VER="0.17.5"
FFMPEG_VER="9.0"

if [ ! -d /deps/zlib ]; then
    git clone --depth 1 -b "${ZLIB_VER}" https://github.com/madler/zlib.git /deps/zlib
fi
mkdir -p /deps/zlib_build
cd /deps/zlib_build
cmake ${cmake_args} -G Ninja /deps/zlib
ninja
ninja install

if [ ! -d /deps/libass ]; then
    git clone --depth 1 --branch "${LIBASS_VER}" https://github.com/libass/libass.git /deps/libass
    ln -s /build/subprojects /deps/libass
fi

libass_meson_args=(
    --reconfigure
    --buildtype release
    -Db_lto=true
    -Db_lto_mode=thin
    -Db_pie=true
    -Dc_args=-fhardened
    -Dcpp_args=-fhardened
    -Db_sanitize=undefined
    --auto-features=disabled
    -Ddefault_library=shared
    -Dasm=enabled
    -Dfontconfig=enabled
    -Dzlib:default_library=shared
    -Dfribidi:bin=false
)
meson setup /deps/libass_build /deps/libass "${libass_meson_args[@]}"
meson install -C /deps/libass_build

if [ ! -d /deps/ffmpeg ]; then
    git clone --depth 1 --branch "release/${FFMPEG_VER}" https://github.com/FFmpeg/FFmpeg.git /deps/ffmpeg
fi

# ffmpeg (program) used by karaberus tests
ffmpeg_exe_args=(
    --enable-static
    --enable-pic
    --disable-shared
    --disable-doc
    --extra-cflags=-fhardened
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
    --enable-zlib
    --extra-cflags=-fhardened
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

go install "github.com/golangci/golangci-lint/v2/cmd/golangci-lint@${GCL_VER}"
ln -s $(go env GOPATH)/bin/golangci-lint /usr/bin/

go clean -cache -modcache
rm -rf /deps /build
