#!/bin/bash

set -e

export OPAMROOT=`pwd`/_opam

# Build effects http server with multicore
opam switch 4.10.0+multicore
cd httpaf-effects && opam exec dune build
mv _build/default/wrk_effects_benchmark.exe ../httpaf_effects.exe

# Use trunk 4.10.0 for the lwt http server
opam switch 4.10.0
cd ../httpaf-lwt && opam exec dune build
mv _build/default/httpaf_lwt.exe ..

# Now we build the go one with 1.15
cd .. && go/bin/go build nethttp-go/httpserv.go
mv httpserv nethttp_go.exe
