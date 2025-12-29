# Build cohttp_eio.exe
FROM ocaml/opam:debian-13-ocaml-5.2 AS cohttp-eio
WORKDIR /src

RUN sudo apt update \
  && sudo apt install -qq -y pkg-config file \
  && opam switch reinstall \
  && opam install dune eio_main.0.9 mdx uri fmt

COPY --chown=opam . /src
RUN sudo chown opam .
RUN opam exec -- dune build --profile=release
RUN sudo mv /src/_build/default/cohttp_eio.exe /src/cohttp-eio.exe
