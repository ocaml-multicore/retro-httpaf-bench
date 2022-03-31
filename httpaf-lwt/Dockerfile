FROM ocaml/opam:debian-11-ocaml-4.12 AS ocaml-412
RUN sudo ln -f /usr/bin/opam-2.1 /usr/bin/opam
RUN opam install -y conf-libev core lwt httpaf httpaf-lwt-unix
WORKDIR /src
COPY --chown=opam . /src
RUN sudo chown opam .
RUN opam exec -- dune build --profile=release
RUN sudo mv /src/_build/default/httpaf_lwt.exe /src/httpaf-lwt.exe
