FROM ubuntu:20.04
ENV DEBIAN_FRONTEND=noninteractive
RUN ln -fs /usr/share/zoneinfo/Europe/London /etc/localtime
RUN apt update && apt install -y libgmp-dev libev4 libev-dev opam pkg-config build-essential libssl-dev libz-dev cmake python3-virtualenv python3-pip cargo && dpkg-reconfigure --frontend noninteractive tzdata
RUN mkdir ./build
WORKDIR ./build

COPY ./setup_opams.sh .
RUN ./setup_opams.sh

COPY ./setup_go.sh .
RUN ./setup_go.sh

COPY ./cohttp-lwt-unix ./cohttp-lwt-unix
COPY ./httpaf-effects ./httpaf-effects
COPY ./httpaf-lwt ./httpaf-lwt
COPY ./nethttp-go ./nethttp-go
COPY ./rust-hyper ./rust-hyper
COPY ./build_benchmarks.sh .
RUN ./build_benchmarks.sh
RUN rm -rf ./build/_opam

COPY ./build_wrk2.sh .
COPY ./wrk2-support/json.lua ./wrk2-support/json.lua
RUN ./build_wrk2.sh

COPY ./build_mimalloc.sh .
RUN ./build_mimalloc.sh

COPY ./build_jupyter.sh .
COPY ./notebook/parse_output.ipynb .
RUN ./build_jupyter.sh

WORKDIR /

COPY ./run_benchmarks.sh .
CMD ./run_benchmarks.sh && tail -f /dev/null
