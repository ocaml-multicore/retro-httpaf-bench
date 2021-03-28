#!/bin/bash
set -e

wget -q https://github.com/microsoft/mimalloc/archive/refs/tags/v1.6.7.zip
unzip -nq v1.6.7.zip
rm v1.6.7.zip
cd mimalloc-1.6.7
mkdir -p out/release
cd out/release
cmake ../..
make
cp libmimalloc.so.1.6 ../../../libmimalloc.so
cd ../../../
rm -rf mimalloc-1.6.7
