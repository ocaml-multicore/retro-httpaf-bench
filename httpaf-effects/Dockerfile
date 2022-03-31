FROM ocaml/opam:debian-11-ocaml-4.12-domains-effects AS httpaf-effects
RUN sudo ln -f /usr/bin/opam-2.1 /usr/bin/opam
RUN opam pin -n aeio git+https://github.com/kayceesrk/ocaml-aeio.git
RUN opam install -y conf-libev httpaf lwt dune aeio
WORKDIR /src
COPY --chown=opam . /src
RUN sudo chown opam .
RUN opam exec -- dune build --profile=release
RUN sudo mv /src/_build/default/wrk_effects_benchmark.exe /src/httpaf-effects.exe
