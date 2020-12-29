FROM 0x01be/base as build

WORKDIR /gerbv

ENV REVISION=master
RUN apk add --no-cache --virtual gerbv-build-dependencies \
    git \
    build-base \
    gettext-dev \
    libtool \
    automake \
    pkgconfig \
    cairo-dev \
    gtk+2.0-dev \
    autoconf &&\
    git clone --depth 1 --branch ${REVISION} git://git.geda-project.org/gerbv /gerbv &&\
    ./autogen.sh &&\
    ./configure \
    --prefix=/opt/gerbv/ \
    --enable-unit-mm \
    --disable-update-desktop-database &&\
     make
RUN make install

FROM 0x01be/xpra

COPY --from=build /opt/gerbv/ /opt/gerbv/

RUN apk add --no-cache --virtual gerbv-runtime-dependencies \
    gtk+2.0

USER ${USER}
ENV PATH=${PATH}:/opt/gerbv/bin/ \
    COMMAND=gerbv

