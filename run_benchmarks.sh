#!/bin/bash
set -xe

run_duration="${RUN_DURATION:-60}"

export GOMAXPROCS=1
export COHTTP_DOMAINS=1
export HTTPAF_EIO_DOMAINS=1
export RUST_CORES=1

rm -rf output/*
mkdir -p output

for cmd in "cohttp_eio.exe" "httpaf_eio.exe" "http_async.exe" "rust_hyper.exe" "nethttp_go.exe"; do
  for rps in 1000 50000 75000 150000 300000 400000; do
      ./build/$cmd &
      running_pid=$!
      sleep 2;
      ./build/wrk -t 24 -d${run_duration}s -L -s ./build/json.lua -c 1000 http://localhost:8080 > output/run-$cmd-$rps-1000.txt;
      kill ${running_pid};
      sleep 1;
  done
done

jupyter nbconvert ./build/parse_output.ipynb --to html
mv ./build/parse_output.html ./output/.
