FROM ocaml/opam:debian-11-ocaml-4.12
RUN sudo ln -f /usr/bin/opam-2.1 /usr/bin/opam
RUN (cd opam-repository && git pull origin 06c9f5470403fb40e7b3e8561ec60ac088817c7b && opam update)
RUN opam install -y core core_unix http_async.0.1.0
WORKDIR /src
COPY --chown=opam . /src
RUN sudo chown opam .
RUN opam exec -- dune build --profile=release
RUN sudo mv /src/_build/default/main.exe /src/http-async.exe
