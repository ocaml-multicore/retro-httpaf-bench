#!/bin/bash
set -e

export OPAMYES=1
export OPAMROOT=`pwd`/_opam

opam init --disable-sandboxing
opam update
opam switch create 4.12.0+domains+effects --packages=ocaml-variants.4.12.0+domains+effects --repositories=multicore=git+https://github.com/ocaml-multicore/multicore-opam.git,default
opam pin -n aeio git+https://github.com/kayceesrk/ocaml-aeio.git
opam install -y conf-libev httpaf lwt dune aeio

opam switch create 4.12.0
opam install -y conf-libev lwt core httpaf httpaf-lwt-unix cohttp-lwt-unix shuttle.0.3.1 httpaf async
