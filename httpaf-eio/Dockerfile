# httpaf-eio
FROM ocaml/opam:debian-11-ocaml-4.12-domains AS eio
RUN (cd opam-repository && git pull origin 75f69f2010f203d29adb423858f93bf4406c7869 && opam update)
WORKDIR /src
RUN opam depext -i ppx_cstruct dune fmt logs cstruct faraday mtime optint lwt-dllist psq luv eio_main
COPY --chown=opam . /src
RUN sudo chown opam .
RUN opam exec -- dune build --profile=release
RUN sudo mv /src/_build/default/wrk_effects_benchmark.exe /src/httpaf-eio.exe
