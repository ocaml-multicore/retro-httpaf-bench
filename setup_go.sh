#!/bin/bash
set -e

wget -q https://golang.org/dl/go1.25.linux-amd64.tar.gz
tar -C ./ -xzf go1.25.linux-amd64.tar.gz
rm go1.25.linux-amd64.tar.gz
