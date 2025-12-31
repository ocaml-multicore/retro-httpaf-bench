# httpaf-eio
FROM ocaml/opam:debian-13-ocaml-5.2 AS eio

WORKDIR /src

RUN opam install ppx_cstruct dune fmt logs cstruct faraday mtime \
      optint lwt-dllist psq luv eio_main result eio.1.3 httpaf eio

COPY --chown=opam . /src

RUN sudo chown opam . \
  && opam exec -- dune build --profile=release \
  && sudo mv /src/_build/default/wrk_effects_benchmark.exe /src/httpaf-eio.exe
