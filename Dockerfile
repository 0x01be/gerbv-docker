FROM 0x01be/base:arm32v6 as build

RUN apk add --no-cache --virtual gerbv-build-dependencies \
    git \
    build-base \
    gettext-dev \
    libtool \
    automake \
    pkgconfig \
    cairo-dev \
    gtk+2.0-dev \
    autoconf

RUN git clone --depth 1 git://git.geda-project.org/gerbv gerbv

WORKDIR /gerbv

RUN ./autogen.sh
RUN ./configure \
    --prefix=/opt/gerbv/ \
    --enable-unit-mm \
    --disable-update-desktop-database
RUN make
RUN make install

FROM 0x01be/xpra:arm32v6

RUN apk add --no-cache --virtual gerbv-runtime-dependencies \
    gtk+2.0

COPY --from=build /opt/gerbv/ /opt/gerbv/

USER xpra
ENV PATH $PATH:/opt/gerbv/bin/
ENV COMMAND gerbv

