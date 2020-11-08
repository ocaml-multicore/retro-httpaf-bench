#!/bin/bash
set -e

export OPAMROOT=`pwd`/_opam

opam init --disable-sandboxing
opam update
opam switch create 4.10.0+multicore --packages=ocaml-variants.4.10.0+multicore,ocaml-secondary-compiler --repositories=multicore=git+https://github.com/ocamllabs/multicore-opam.git,default
opam pin -n aeio git+https://github.com/kayceesrk/ocaml-aeio.git
opam install -y conf-libev httpaf lwt dune aeio

opam switch create 4.10.0
opam install -y conf-libev lwt core httpaf httpaf-lwt-unix
