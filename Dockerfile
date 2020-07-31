FROM alpine:3.12.0 as builder

RUN apk add --no-cache --virtual build-dependencies \
    --repository http://dl-cdn.alpinelinux.org/alpine/edge/main \
    --repository http://dl-cdn.alpinelinux.org/alpine/edge/community \
    --repository http://dl-cdn.alpinelinux.org/alpine/edge/testing \
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
    --prefix=/opt/gerbv/ \
    --enable-unit-mm \
    --disable-update-desktop-database
RUN make
RUN make install

FROM 0x01be/xpra

RUN apk add --no-cache --virtual gerbv-runtime-dependencies \
    --repository http://dl-cdn.alpinelinux.org/alpine/edge/main \
    --repository http://dl-cdn.alpinelinux.org/alpine/edge/community \
    gtk+2.0 \
    ttf-freefont

COPY --from=builder /opt/gerbv/ /opt/gerbv/

ENV PATH $PATH:/opt/gerbv/bin/

CMD /usr/bin/xpra start --bind-tcp=0.0.0.0:10000 --html=on --start-child=gerbv --exit-with-children --daemon=no --xvfb="/usr/bin/Xvfb +extension  Composite -screen 0 1920x1080x24+32 -nolisten tcp -noreset" --pulseaudio=no --notifications=no --bell=no --mdns=no

