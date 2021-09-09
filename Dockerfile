FROM ocaml/opam:debian-10-ocaml-4.12-domains-effects AS eio
WORKDIR /src
RUN opam pin -n ocaml-migrate-parsetree 2.1.0+effect-syntax && \
    opam pin -n ppxlib 0.22.0+effect-syntax
RUN opam depext -i ppx_cstruct dune fmt logs bheap cstruct faraday mtime ocplib-endian optint lwt-dllist psq luv
COPY --chown=opam httpaf-eio /src
RUN sudo chown opam .
RUN opam exec -- dune build --profile=release

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
COPY ./httpaf-shuttle-async ./httpaf-shuttle-async
COPY ./nethttp-go ./nethttp-go
COPY ./rust-hyper ./rust-hyper
COPY ./build_benchmarks.sh .
RUN ./build_benchmarks.sh
RUN rm -rf ./build/_opam

COPY ./build_wrk2.sh .
COPY ./wrk2-support/json.lua ./wrk2-support/json.lua
RUN ./build_wrk2.sh

COPY ./build_jupyter.sh .
COPY ./notebook/parse_output.ipynb .
RUN ./build_jupyter.sh

WORKDIR /

COPY ./run_benchmarks.sh .
COPY --from=eio /src/_build/default/wrk_effects_benchmark.exe ./build/httpaf_eio.exe
CMD ./run_benchmarks.sh
