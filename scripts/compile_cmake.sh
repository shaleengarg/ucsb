#!/bin/bash

set -e

mkdir -p ./pkgs_compiled

pushd pkgs_compiled

if [ -f cmake-3.28.4.tar.gz ]; then
        rm -rf cmake-3.28.4.tar.gz
fi

wget https://cmake.org/files/v3.28/cmake-3.28.4.tar.gz

tar --overwrite -xf cmake-3.28.4.tar.gz

pushd cmake-3.28.4

./bootstrap

make -j$(nproc)

sudo make install


echo "installed cmake-3.28.4 in /usr/local/bin"

popd
popd
