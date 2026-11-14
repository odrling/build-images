FROM docker.io/gentoo/portage:latest as portage
FROM docker.io/gentoo/stage3:nomultilib-20261109

COPY --from=portage /var/db/repos/gentoo /var/db/repos/gentoo

RUN echo '=dev-lang/go-1.27.4 ~*' > /etc/portage/package.accept_keywords/go
RUN emerge --noreplace -g dev-lang/go net-libs/nodejs meson python dev-vcs/git nasm cmake libass opus x264 sys-libs/zlib bash
COPY build/ /build
RUN /build/build.sh
