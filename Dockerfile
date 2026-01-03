FROM ubuntu:24.04

RUN ln -fs /usr/share/zoneinfo/Europe/London /etc/localtime

# Install libraries
RUN apt update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y \
    build-essential \
    libreadline-dev \
    curl \
    unzip \
    git \
    libssl-dev \
    zlib1g \
    zlib1g-dev \
    wget \
    libgmp-dev  \
    libev4 \
    libev-dev \
    pkg-config \
    libz-dev \
    python3-virtualenv \
    python3-pip jupyter \
    && dpkg-reconfigure --frontend noninteractive tzdata

# Install Lua 5.3
RUN wget https://www.lua.org/ftp/lua-5.3.5.tar.gz && \
    tar -zxf lua-5.3.5.tar.gz && \
    cd lua-5.3.5 && \
    make linux test && \
    make install

# Install LuaRocks
RUN curl -R -O https://luarocks.github.io/luarocks/releases/luarocks-3.5.0.tar.gz && \
    tar -xzvf luarocks-3.5.0.tar.gz && \
    cd luarocks-3.5.0 && \
    ./configure && \
    make bootstrap

# Clone and build wrk2 (ARM64 compatible fork)
RUN git clone https://github.com/AmpereTravis/wrk2-aarch64.git wrk2 && \
    cd wrk2 && \
    make && \
    cp wrk /usr/local/bin/

RUN apt install -qq -y python3-pandas python3-numpy python3-regex

RUN mkdir /build
WORKDIR /build

# Make sure build_wrk and json.lua are in the build directory
COPY ./wrk2-support/json.lua .

# Make sure directory is /build
WORKDIR /build
COPY ./build_jupyter.sh .
COPY ./notebook/parse_output.ipynb /build/notebook/.
RUN /build/build_jupyter.sh

COPY ./run_benchmarks.sh /build/.
CMD /build/run_benchmarks.sh
