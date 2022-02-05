# httpaf-eio
FROM ocaml/opam:debian-11-ocaml-4.12-domains AS eio
WORKDIR /src
RUN opam depext -i ppx_cstruct dune fmt logs cstruct faraday mtime optint lwt-dllist psq luv
COPY --chown=opam vendor/eio/*.opam /src/httpaf-eio/vendor/eio/
RUN opam install --deps-only /src/httpaf-eio/vendor/eio/
COPY --chown=opam . /src
RUN sudo chown opam .
RUN opam exec -- dune build --profile=release
RUN sudo mv /src/_build/default/wrk_effects_benchmark.exe /src/httpaf-eio.exe
