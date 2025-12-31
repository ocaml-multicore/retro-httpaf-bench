FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

RUN ln -fs /usr/share/zoneinfo/Europe/London /etc/localtime

RUN apt update \
  && apt install -y libgmp-dev libev4 libev-dev pkg-config \
     build-essential libssl-dev libz-dev cmake python3-virtualenv \
     python3-pip wget unzip \
     && dpkg-reconfigure --frontend noninteractive tzdata

RUN mkdir ./build
WORKDIR ./build

COPY ./build_wrk2.sh .
COPY ./wrk2-support/json.lua ./wrk2-support/json.lua
RUN ./build_wrk2.sh

COPY ./build_jupyter.sh .
COPY ./notebook/parse_output.ipynb .
RUN ./build_jupyter.sh

WORKDIR /
CMD ./run_benchmarks.sh
