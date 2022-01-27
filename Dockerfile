FROM ocaml/opam:debian-11-ocaml-4.12-domains AS eio
WORKDIR /src
RUN opam depext -i ppx_cstruct dune fmt logs cstruct faraday mtime optint lwt-dllist psq luv
COPY --chown=opam httpaf-eio/vendor/eio/*.opam /src/httpaf-eio/vendor/eio/
RUN opam install --deps-only /src/httpaf-eio/vendor/eio/
COPY --chown=opam httpaf-eio /src
RUN sudo chown opam .
RUN opam exec -- dune build --profile=release

# Build cohttp_eio.exe
FROM ocaml/opam:debian-11-ocaml-4.12-domains AS cohttp-eio
RUN sudo ln -f /usr/bin/opam-2.1 /usr/bin/opam
RUN git -C ~/opam-repository pull origin master
RUN opam update && opam upgrade -y
WORKDIR /src
RUN opam install ppx_cstruct dune fmt logs cstruct faraday mtime optint lwt-dllist psq luv luv_unix uri ppx_sexp_conv
COPY --chown=opam cohttp-eio/vendor/eio/*.opam /src/cohttp-eio/vendor/eio/
COPY --chown=opam cohttp-eio/vendor/ocaml-cohttp/*.opam /src/cohttp-eio/vendor/ocaml-cohttp/
RUN opam pin --with-version dev /src/cohttp-eio/vendor/eio/
RUN opam pin --with-version dev /src/cohttp-eio/vendor/ocaml-cohttp/
COPY --chown=opam cohttp-eio /src
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
COPY --from=cohttp-eio /src/_build/default/cohttp_eio.exe ./build/cohttp_eio.exe
CMD ./run_benchmarks.sh
