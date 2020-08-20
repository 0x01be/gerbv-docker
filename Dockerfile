FROM alpine as builder

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

FROM 0x01be/xpra

COPY --from=builder /opt/gerbv/ /opt/gerbv/

RUN apk add --no-cache --virtual gerbv-runtime-dependencies \
    gtk+2.0 \
    ttf-freefont

COPY --from=builder /opt/gerbv/ /opt/gerbv/

ENV PATH $PATH:/opt/gerbv/bin/

VOLUME /workspace
WORKDIR /workspace

ENV COMMAND "gerbv"

