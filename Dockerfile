FROM arm32v6/alpine as build

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

RUN git clone --depth=1 git://git.geda-project.org/gerbv /gerbv

WORKDIR /gerbv

RUN ./autogen.sh
RUN ./configure \
    --prefix=/opt/gerbv/ \
    --enable-unit-mm \
    --disable-update-desktop-database
RUN make
RUN make install

FROM arm32v6/alpine

RUN apk add --no-cache --virtual gerbv-runtime-dependencies \
    gtk+2.0

COPY --from=build /opt/gerbv/ /opt/gerbv/

ENV USER gerbv
ENV UID 1000
ENV WORKSPACE /workspace

RUN adduser -D -u ${UID} ${USER}

WORKDIR ${WORKSPACE}

RUN chown -R ${USER}:${USER} ${WORKSPACE}

USER ${USER}

ENV PATH $PATH:/opt/gerbv/bin/

ENV FORMAT svg

CMD  ls | xargs -t -I {} /opt/gerbv/bin/gerbv --export=$FORMAT --output={}.$FORMAT {}

