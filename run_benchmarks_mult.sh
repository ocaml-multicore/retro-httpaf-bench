#!/bin/bash
set -xe

run_duration="${RUN_DURATION:-60}"

export GOMAXPROCS=24
export COHTTP_DOMAINS=24
export HTTPAF_EIO_DOMAINS=24
export RUST_CORES=24
export SIMPLE_HTTPD_CORES=24

rm -rf output/*
mkdir -p output

for cmd in "simple_httpd.exe" "cohttp_eio.exe" "httpaf_eio.exe" "rust_hyper.exe" "nethttp_go.exe" ; do
  for rps in 150000 300000 400000 800000 1500000; do
      ./build/$cmd &
      running_pid=$!
      sleep 2;
      ./build/wrk2 -t 24 -d${run_duration}s -L -s ./build/json.lua -R $rps -c 1000 http://localhost:8080 > output/run-$cmd-$rps-1000.txt;
      kill ${running_pid};
      sleep 1;
  done
done

source build/pyenv/bin/activate
mv build/parse_output.ipynb .
jupyter nbconvert --to html --execute parse_output.ipynb
mv parse_output* output/
