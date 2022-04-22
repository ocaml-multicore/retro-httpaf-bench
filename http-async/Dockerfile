FROM ocaml/opam:debian-11-ocaml-4.12
RUN sudo ln -f /usr/bin/opam-2.1 /usr/bin/opam
RUN opam install -y core core_unix http_async
WORKDIR /src
COPY --chown=opam . /src
RUN sudo chown opam .
RUN opam exec -- dune build --profile=release
RUN sudo mv /src/_build/default/main.exe /src/http-async.exe
