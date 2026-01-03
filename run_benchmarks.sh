#!/bin/bash
set -xe

run_duration="${RUN_DURATION:-60}"

export GOMAXPROCS=1
export COHTTP_DOMAINS=1
export HTTPAF_EIO_DOMAINS=1
export RUST_CORES=1

rm -rf output/*
mkdir -p output

declare -a prog_arr=("cohttp_eio.exe" "cohttp_lwt_unix.exe"
                     "http_async.exe" "httpaf_effects.exe"
                     "httpaf_lwt.exe" "rust_hyper.exe" "nethttp_go.exe")

declare -a rps_arr=(1000 50000 75000 150000 300000 400000)

wrk_exec="/usr/local/bin/wrk"

for cmd in ${prog_arr[@]} ; do
  for rps in ${rps_arr[@]} ; do
      ./$cmd &
      running_pid=$!
      sleep 2;
      ${wrk_exec} -t 24 -d ${run_duration}s -L -s /build/json.lua -R $rps -c 1000 http://localhost:8080  > /build/output/run-$cmd-$rps-1000.txt;
      kill ${running_pid};
      sleep 1;
  done
done

NOTEBOOK_FILE="/build/notebook/parse_output.ipynb"
jupyter nbconvert --to html --output-dir="/build/output" ${NOTEBOOK_FILE}
