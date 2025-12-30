FROM ocaml/opam:debian-13-ocaml-5.2 AS ocaml-52

WORKDIR /src

RUN sudo ln -f /usr/bin/opam-2.5 /usr/bin/opam \
  && opam install -y conf-libev core lwt httpaf httpaf-lwt-unix

COPY --chown=opam . /src

RUN sudo chown opam . \
  && opam exec -- dune build --profile=release \
  && sudo mv /src/_build/default/httpaf_lwt.exe /src/httpaf-lwt.exe
