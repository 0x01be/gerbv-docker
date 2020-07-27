FROM alpine:3.12.0 as builder

RUN apk add --no-cache --virtual build-dependencies \
    git \
    build-base \
    gettext-dev \
    libtool \
    automake \
    pkgconfig \
    cairo-dev \
    gtk+2.0-dev \
    autoconf

RUN git clone --depth=1 git://git.geda-project.org/gerbv gerbv

WORKDIR /gerbv

RUN ./autogen.sh
RUN ./configure \
    --enable-unit-mm \
    --disable-update-desktop-database
RUN make
RUN make install
