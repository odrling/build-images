#!/bin/sh
set -e
GCC_VER=14
if [ -z "${TARGET}" ]; then
    cross_args="--native-file /build/native.ini"
    apt-get -y install gcc-${GCC_VER} g++-${GCC_VER}
else
    arch=$(echo ${TARGET} | cut -d- -f1)
    cmake_args="-DCMAKE_TOOLCHAIN_FILE=/build/${TARGET}.cmake -DCMAKE_INSTALL_PREFIX=/usr/${TARGET}"
    ffmpeg_args="--cross-prefix=${TARGET}- --pkg-config=pkg-config --cc=${TARGET}-gcc-${GCC_VER} --prefix=/usr/${TARGET} --arch=${arch} --target-os=linux"
    cross_args="--cross-file /build/${TARGET}.ini"
    apt-get -y install gcc-${GCC_VER}-${TARGET} g++-${GCC_VER}-${TARGET} qemu-user-static
    export PKG_CONFIG_SYSROOT_DIR="/usr/${TARGET}"
fi

if [ ! -d /deps/zlib ]; then
    git clone --depth 1 -b master https://github.com/madler/zlib.git /deps/zlib
fi
mkdir -p /deps/zlib_build
cd /deps/zlib_build
cmake ${cmake_args} /deps/zlib
make -j$(ncproc)
make install

if [ ! -d /deps/libass ]; then
    git clone --depth 1 https://github.com/libass/libass.git /deps/libass
    ln -s /build/subprojects /deps/libass
fi

meson setup /deps/libass_build /deps/libass --reconfigure --buildtype release -Db_lto=true -Db_lto_mode=thin -Db_pie=true -Db_sanitize=undefined --auto-features=disabled -Ddefault_library=shared -Dasm=enabled -Dfontconfig=enabled -Dzlib:default_library=shared -Dfribidi:bin=false $cross_args
meson install -C /deps/libass_build

if [ ! -d /deps/ffmpeg ]; then
    git clone --depth 1 --branch release/7.0 https://github.com/FFmpeg/FFmpeg.git /deps/ffmpeg
fi

apt-get -y install libopus-dev libx264-dev zlib1g-dev

mkdir -p /deps/ffmpeg_exe_build
cd /deps/ffmpeg_exe_build
PKG_CONFIG_SYSROOT_DIR="" /deps/ffmpeg/configure --enable-static --disable-shared --disable-doc --toolchain=hardened --enable-lto=auto --disable-decoders --disable-encoders --disable-swscale --disable-swresample --disable-postproc --disable-demuxers --enable-zlib --enable-gpl --enable-version3 --enable-libx264 --enable-libopus --enable-encoder=libx264 --enable-encoder=libopus --enable-decoder=wrapped_avframe
PKG_CONFIG_SYSROOT_DIR="" make -j$(nproc)
make install

mkdir -p /deps/ffmpeg_build
cd /deps/ffmpeg_build
/deps/ffmpeg/configure --enable-shared --disable-static --disable-autodetect --disable-programs --disable-avdevice --disable-postproc --disable-avfilter --disable-swscale --disable-swresample --disable-doc --disable-muxers --disable-network --disable-encoders --disable-decoders --disable-bsfs --disable-protocols --enable-zlib --enable-decoder=aac --toolchain=hardened --enable-lto=auto --enable-version3 ${ffmpeg_args}
make -j$(nproc)
make install

rm -rf /deps /build
apt-get clean
rm -rf /var/lib/apt/lists/*
