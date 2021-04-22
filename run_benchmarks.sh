#!/bin/bash
set -xe

export GOMAXPROCS=1
export LD_PRELOAD=`pwd`/build/libmimalloc.so

mkdir -p output

for cmd in "cohttp_lwt_unix.exe" "httpaf_lwt.exe" "httpaf_effects.exe" "nethttp_go.exe"; do
  for rps in 2500 5000 10000 15000 20000 25000 30000 35000 40000 45000 50000 55000 60000; do
    for cons in 1000; do
      ./build/$cmd &
      running_pid=$!
      sleep 2;
      ./build/wrk2 -t 24 -d60s -L -s ./build/json.lua -R $rps -c $cons http://localhost:8080 > output/run-$cmd-$rps-$cons.txt;
      kill ${running_pid};
      sleep 1;
    done
  done
done

source build/pyenv/bin/activate
mv build/parse_output.ipynb .
jupyter nbconvert --to html --execute parse_output.ipynb
