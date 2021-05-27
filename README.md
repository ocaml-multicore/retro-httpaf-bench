# retro-httpaf-bench

[![CI](https://github.com/sadiqj/retro-httpaf-bench/actions/workflows/build_image.yml/badge.svg)](https://github.com/sadiqj/retro-httpaf-bench/actions/workflows/build_image.yml)
This project uses submodules, so make sure you use `--recursive` when cloning:
```sh
git clone --recursive https://github.com/ocaml-multicore/retro-httpaf-bench.git
```

Set of scripts for building and running some http server benchmarks. More details to come.

The Dockerfile can be used to build a container that will run everything but care has been taken so you should be able to run the scripts individually themselves in the following order:

1. `setup_opams.sh`
1. `setup_go.sh`
1. `build_benchmarks.sh`
1. `build_wrk2.sh`
1. `build_jupyter.sh`
1. `run_benchmarks.sh`
