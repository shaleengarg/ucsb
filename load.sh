#!/bin/bash

THREADS=16
DATA_FOLDER="$HOME/slowssd/data/rocksdb/500GB"

./build_release/build/bin/ucsb_bench -db rocksdb  -cfg ./bench/configs/rocksdb/100GB.cfg -wl ./bench/workloads/500GB.json -md ./db_main/rocksdb/500GB/ -sd $DATA_FOLDER -res ./bench/results/cores_16/disks_1/rocksdb/500GB.json -th $THREADS -fl Init -ri 0 -rc 1
