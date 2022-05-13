FROM ocaml/opam:debian-11-ocaml-4.12 AS ocaml-412
RUN sudo ln -f /usr/bin/opam-2.1 /usr/bin/opam
RUN opam install -y conf-libev
RUN opam pin --with-version dev git+https://github.com/mirage/ocaml-cohttp.git -yn
RUN opam install cohttp-lwt-unix dune
WORKDIR /src
COPY --chown=opam . /src
RUN sudo chown opam .
RUN opam exec -- dune build --profile=release
RUN sudo mv /src/_build/default/cohttp_lwt_unix.exe /src/cohttp-lwt-unix.exe
