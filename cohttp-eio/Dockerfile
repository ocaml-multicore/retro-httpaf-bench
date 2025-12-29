# Build cohttp_eio.exe
FROM ocaml/opam:debian-13-ocaml-5.2 AS cohttp-eio
WORKDIR /src

RUN sudo apt update \
  && sudo apt install -qq -y pkg-config file \
  && sudo apt install -y libgmp-dev \
  && opam switch reinstall \
  && opam install dune eio_main.1.3 mdx uri fmt ptime ipaddr http logs uri \
     cohttp-lwt-unix cohttp-async

COPY --chown=opam . /src

RUN sudo chown opam . \
  && eval "$(opam env)" \
  && opam exec -- dune build --profile=release \
  && sudo mv /src/_build/default/cohttp_eio.exe /src/cohttp-eio.exe
