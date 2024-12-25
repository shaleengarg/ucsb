#!/bin/bash

set -x

SIZE="120GB"

THREADS=16
DATA_FOLDER="$HOME/ssd/data/rocksdb/${SIZE}"
METADATA_FOLDER="./db_main/rocksdb/${SIZE}"

rm -rf $DATA_FOLDER  $METADATA_FOLDER

./build_release/build/bin/ucsb_bench -db rocksdb  -cfg ./bench/configs/rocksdb/full.cfg -wl ./bench/workloads/${SIZE}.json -md $METADATA_FOLDER -sd $DATA_FOLDER -res ./bench/results/cores_16/disks_1/rocksdb/${SIZE}.json -th $THREADS -fl Init -ri 0 -rc 1
