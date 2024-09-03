#!/bin/sh -ex
if [ -z "${TARGET}" ]; then
    cross_args="--native-file /build/native.ini"
    apt-get -y install gcc-14 g++-14
else
    cross_args="--cross-file /build/${TARGET}.ini"
    apt-get -y install gcc-14-aarch64-linux-gnu g++-14-aarch64-linux-gnu qemu-user-static
fi

if [ ! -d /deps/ffmpeg ]; then
    git clone --depth 1 --branch meson-7.0 https://gitlab.freedesktop.org/gstreamer/meson-ports/ffmpeg.git /deps/ffmpeg
fi

meson setup /deps/ffmpeg_build /deps/ffmpeg --reconfigure --buildtype release -Db_lto=true -Db_lto_mode=thin -Db_pie=true -Db_sanitize=undefined --auto-features=disabled -Ddefault_library=shared -Dtests=disabled -Dprograms=disabled -Dencoders=disabled -Dmuxers=disabled -Davfilter=disabled -Davdevice=disabled -Dpostproc=disabled -Dswresample=disabled -Dswscale=disabled -Daac_decoder=enabled -Dversion3=enabled $cross_args
meson install -C /deps/ffmpeg_build

if [ ! -d /deps/libass ]; then
    git clone --depth 1 https://github.com/libass/libass.git /deps/libass
fi

cd /deps/libass
cp -r /build/subprojects .
meson setup /deps/libass_build /deps/libass --reconfigure --buildtype release -Db_lto=true -Db_lto_mode=thin -Db_pie=true -Db_sanitize=undefined --auto-features=disabled -Ddefault_library=shared -Dasm=enabled -Dfontconfig=enabled $cross_args
meson install -C /deps/libass_build

rm -rf /deps /build
