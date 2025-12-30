FROM ocaml/opam:debian-13-ocaml-5.2

WORKDIR /src

RUN sudo ln -f /usr/bin/opam-2.5 /usr/bin/opam \
  && opam update \
  && opam install -y core core_unix http_async.0.1.0

COPY --chown=opam . /src

RUN sudo chown opam . \
  && eval $(opam env) \
  && opam option jobs=79 --global \
  && opam exec -- dune build --profile=release \
  && sudo mv /src/_build/default/main.exe /src/http-async.exe
