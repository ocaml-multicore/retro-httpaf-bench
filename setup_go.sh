#!/bin/bash
set -e

wget -q https://golang.org/dl/go1.15.4.linux-amd64.tar.gz
tar -C ./ -xzf go1.15.4.linux-amd64.tar.gz
rm go1.15.4.linux-amd64.tar.gz
