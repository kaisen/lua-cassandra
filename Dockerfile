FROM ubuntu:xenial

ENV DEBIAN noninteractive

RUN apt-get update && apt-get install -yq \
    build-essential \
    curl \
    git \
    libreadline-dev \
    libncurses5-dev \
    libpcre3-dev \
    libssl-dev \
    lua5.1 \
    openjdk-8-jdk \
    sudo \
    python-dev \
    python-pip \
    unzip

RUN pip install -U pip wheel

RUN mkdir /work
RUN mkdir -p /work/t/servroot
WORKDIR /work

RUN useradd -m test -G root
RUN chown -R test:root /work
USER test
ENV HOME /home/test

ENV LUAROCKS 2.4.1
ENV OPENRESTY 1.11.2.1
ENV DOWNLOAD_CACHE $HOME/download-cache
ENV INSTALL_CACHE $HOME/install-cache
ENV PERL_DIR $HOME/perl5
ENV OPENRESTY_INSTALL $INSTALL_CACHE/openresty-$OPENRESTY
ENV LUAROCKS_INSTALL $INSTALL_CACHE/luarocks-$LUAROCKS
ENV PATH $PATH:$OPENRESTY_INSTALL/nginx/sbin:$OPENRESTY_INSTALL/bin:$LUAROCKS_INSTALL/bin:$LUA_DIR/bin

ENV OPENRESTY_TESTS true

COPY .ci/setup_env.sh /work/.ci/setup_env.sh
RUN bash .ci/setup_env.sh
ENV PATH $PATH:$HOME/.local/bin

RUN ccm create lua_cassandra_prove -v binary:3.9 -n 3

COPY . /work/

RUN bash -c "make install"
CMD eval $(perl -I ~/perl5/lib/perl5/ -Mlocal::lib) && eval $(luarocks path) && CASSANDRA=3.9 .ci/run_tests.sh
