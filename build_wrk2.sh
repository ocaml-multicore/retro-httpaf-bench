#!/bin/bash
set -e
wrk_dir="wrk-master/wrk-4.2.0/"
echo "Currently in directory: `pwd`"

if [ ! -d "$wrk_dir" ];
  then
    echo "$wrk_dir needs to be created and the wrk executable built."
    wget -q https://github.com/wg/wrk/archive/refs/tags/4.2.0.zip -O master.zip
    unzip -qq master.zip -d wrk-master
    echo "The content for wrk2 is now at $wrk_dir"
    rm master.zip
    cd $wrk_dir
    make
    echo "cd'ing from directory: `pwd`"
    cd ./../../
    echo "The current/root directory is: `pwd`"
    cp $wrk_dir/wrk /build/.
    cp wrk2-support/json.lua /build/.
  else
    echo "$wrk_dir already exists."
    echo "Checking if the wrk executable is already built."
    cd $wrk_dir
    if command -v wrk >/dev/null 2>&1
      then
          echo "The wrk executable has already been built."
      else
          echo "The wrk executable should exist but nevermind ..."
          echo "Building a fresh instance of wrk."
          make
          echo "cd'ing from directory: `pwd`"
          cd ./../../
          echo "The current/root directory is: `pwd`"
          cp $wrk_dir/wrk /build/.
          cp wrk2-support/json.lua /build/.
   fi
fi


