#!/bin/bash

set -e

COMPILE_SWIG(){
        sudo yum install -y pcre2-devel
        wget https://github.com/swig/swig/archive/refs/tags/v4.1.1.tar.gz -O swig.tar.gz
        
        tar -xf swig.tar.gz
        pushd ./swig-4.1.1
        ./autogen.sh
        ./configure
        make -j$(nproc)
        sudo make install
        popd

        echo "add /usr/local/bin to \$PATH and /usr/local/lib to \$LD_LIBRARY_PATH in bashrc and source it"
        echo "check swig installation using swig -version"
}


COMPILE_PYTHON39(){
        sudo yum install -y libffi-devel
        wget https://www.python.org/ftp/python/3.9.9/Python-3.9.9.tgz
        tar -xf Python-3.9.9.tgz

        pushd PYTHON-3.9.9

        CFLAGS="-fPIC" ./configure --enable-shared --prefix=/usr/local --enable-optimizations
        make -j$(nproc)

        sudo make install -j$(nproc)

        popd
}


##CHECK GCC version 

mkdir ./pkgs_compiled

pushd pkgs_compiled

COMPILE_SWIG

popd
