# Build cohttp_eio.exe
FROM ocaml/opam:debian-11-ocaml-4.12-domains AS cohttp-eio
RUN sudo ln -f /usr/bin/opam-2.1 /usr/bin/opam
RUN git -C ~/opam-repository pull origin master
RUN opam update && opam upgrade -y
WORKDIR /src
RUN opam install ppx_cstruct dune fmt logs cstruct faraday mtime optint lwt-dllist psq luv luv_unix uri ppx_sexp_conv eio eio_main eio_linux eio_luv base64 re sexplib0 ppx_sexp_conv stringext fmt uri-sexp
COPY --chown=opam . /src
RUN sudo chown opam .
RUN opam exec -- dune build --profile=release
RUN sudo mv /src/_build/default/cohttp_eio.exe /src/cohttp-eio.exe
