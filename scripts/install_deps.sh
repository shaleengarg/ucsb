#!/bin/bash

sudo yum install -y gflags gflags-devel snappy snappy-devel zlib zlib-devel bzip2 bzip2-devel lz4 lz4-devel libzstd libzstd-devel jq


##Check python version

sudo python3 -m pip install pexpect termcolor scikit-build setuptools wheel conan cmake
