#!/bin/bash

set -e
set -x

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

        echo "export PATH=/usr/local/bin:\$PATH" >> ~/.bashrc
        echo "export LD_LIBRARY_PATH=/usr/local/lib:\$LD_LIBRARY_PATH" >> ~/.bashrc
}


COMPILE_PYTHON39(){
        sudo yum install -y libffi-devel
        wget https://www.python.org/ftp/python/3.9.9/Python-3.9.9.tgz
        tar -xf Python-3.9.9.tgz

        pushd Python-3.9.9

        make clean -j

        CFLAGS="-fPIC" ./configure --enable-shared --prefix=/usr/local --enable-optimizations
        make -j$(nproc)

        sudo make install -j$(nproc)

        popd
}


gcc_version=$(gcc -dumpversion | cut -f1 -d.)

# Check if the version is greater than 7
if [ "$gcc_version" -ge 11 ]; then
        echo "GCC version is >= 11 (version $gcc_version)."
else
        echo "GCC version is < 11 (version $gcc_version). scl enable devtoolset-11 bash"
fi


mkdir -p ./pkgs_compiled

pushd pkgs_compiled

COMPILE_SWIG
source ~/.bashrc
COMPILE_PYTHON39

popd
