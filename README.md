# retro-httpaf-bench

[![CI](https://github.com/sadiqj/retro-httpaf-bench/actions/workflows/build_image.yml/badge.svg)](https://github.com/sadiqj/retro-httpaf-bench/actions/workflows/build_image.yml)
This project uses submodules, so make sure you use `--recursive` when cloning:
```sh
git clone --recursive https://github.com/ocaml-multicore/retro-httpaf-bench.git
```

Set of scripts for building and running some http server benchmarks. More details to come.

The Dockerfile can be used to build a container that will run everything.
Running `make` will build the image and run the tests.
Afterwards, the results are available as `output/parse_output.html`.

Note that running `make` deletes any existing files in `output/`.
