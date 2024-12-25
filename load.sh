#!/bin/bash

SIZE="250GB"

THREADS=16
DATA_FOLDER="$HOME/slowssd/data/rocksdb/${SIZE}"

./build_release/build/bin/ucsb_bench -db rocksdb  -cfg ./bench/configs/rocksdb/100GB.cfg -wl ./bench/workloads/${SIZE}.json -md ./db_main/rocksdb/${SIZE}/ -sd $DATA_FOLDER -res ./bench/results/cores_16/disks_1/rocksdb/${SIZE}.json -th $THREADS -fl Init -ri 0 -rc 1
