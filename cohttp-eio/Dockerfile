# Build cohttp_eio.exe
FROM ocaml/opam:debian-11-ocaml-4.12-domains AS cohttp-eio
RUN sudo ln -f /usr/bin/opam-2.1 /usr/bin/opam
RUN git -C ~/opam-repository pull origin master
RUN opam update && opam upgrade -y
WORKDIR /src
RUN opam install ppx_cstruct dune fmt logs cstruct faraday mtime optint lwt-dllist psq luv luv_unix uri ppx_sexp_conv
COPY --chown=opam vendor/eio/*.opam /src/cohttp-eio/vendor/eio/
COPY --chown=opam vendor/ocaml-cohttp/*.opam /src/cohttp-eio/vendor/ocaml-cohttp/
RUN opam pin --with-version dev /src/cohttp-eio/vendor/eio/
RUN opam pin --with-version dev /src/cohttp-eio/vendor/ocaml-cohttp/
COPY --chown=opam . /src
RUN sudo chown opam .
RUN opam exec -- dune build --profile=release
RUN sudo mv /src/_build/default/cohttp_eio.exe /src/cohttp-eio.exe
