FROM ocaml/opam:debian-13-ocaml-5.2 AS httpaf-effects

WORKDIR /src

RUN sudo ln -f /usr/bin/opam-2.5 /usr/bin/opam \
  && opam install conf-libev httpaf lwt dune eio_main.1.3

COPY --chown=opam . /src

RUN sudo chown opam . \
  && opam exec -- dune build --profile=release \
  && sudo mv /src/_build/default/wrk_effects_benchmark.exe /src/httpaf-effects.exe
