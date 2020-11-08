#!/bin/bash

set -e

virtualenv -p python3 pyenv
source `pwd`/pyenv/bin/activate
pip3 install jupyter pandas matplotlib numpy
