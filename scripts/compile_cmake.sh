#!/bin/bash

set -e

mkdir ./pkgs_compiled

pushd pkgs_compiled
wget https://cmake.org/files/v3.28/cmake-3.28.4.tar.gz

tar -xf cmake-3.28.4.tar.gz

pushd cmake-3.28.4

./bootstrap

make -j$(nproc)

sudo make install


echo "installed cmake-3.28.4 in /usr/local/bin"

popd
popd
