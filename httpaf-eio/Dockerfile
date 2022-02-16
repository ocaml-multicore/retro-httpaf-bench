# httpaf-eio
FROM ocaml/opam:debian-11-ocaml-4.12-domains AS eio
RUN (cd opam-repository && git pull origin d67b377bdb96094b5daeb37a72f9a7a9fcc8fd55 && opam update)
WORKDIR /src
RUN opam depext -i ppx_cstruct dune fmt logs cstruct faraday mtime optint lwt-dllist psq luv eio_main
COPY --chown=opam . /src
RUN sudo chown opam .
RUN opam exec -- dune build --profile=release
RUN sudo mv /src/_build/default/wrk_effects_benchmark.exe /src/httpaf-eio.exe
