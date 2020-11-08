#!/bin/bash
set -e

wget -q https://github.com/microsoft/mimalloc/archive/master.zip
unzip -q master.zip
rm master.zip
cd mimalloc-master
mkdir -p out/release
cd out/release
cmake ../..
make
cp libmimalloc.so.1.6 ../../../libmimalloc.so
cd ../../../
rm -rf mimalloc-master
