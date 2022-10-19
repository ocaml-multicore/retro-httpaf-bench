# Build cohttp_eio.exe
FROM ocaml/opam:debian-11-ocaml-5.0 AS cohttp-eio
WORKDIR /src
RUN sudo apt-get install -qq -yy pkg-config file
RUN opam depext -i dune eio_main.0.6 mdx uri fmt odoc
COPY --chown=opam . /src
RUN sudo chown opam .
RUN opam exec -- dune build --profile=release
RUN sudo mv /src/_build/default/cohttp_eio.exe /src/cohttp-eio.exe
