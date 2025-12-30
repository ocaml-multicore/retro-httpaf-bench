FROM ocaml/opam:debian-13-ocaml-5.2 AS ocaml-52
WORKDIR /src

RUN sudo apt update \
  && sudo ln -f /usr/bin/opam-2.5 /usr/bin/opam \
  && opam install -y conf-libev \
  && opam pin --with-version dev git+https://github.com/mirage/ocaml-cohttp.git -yn \
  && opam install cohttp-lwt-unix dune

COPY --chown=opam . /src

RUN sudo chown opam . \
  && opam exec -- dune build --profile=release \
  && sudo mv /src/_build/default/cohttp_lwt_unix.exe /src/cohttp-lwt-unix.exe
