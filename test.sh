#!/bin/bash

set -x

sudo sh -c "echo 3 > /proc/sys/vm/drop_caches"; sleep 3

COMMAND="./build_release/build/bin/ucsb_bench -db rocksdb  -cfg ./bench/configs/rocksdb/100GB.cfg -wl ./bench/workloads/100GB.json -md ./db_main/rocksdb/100GB/ -sd $PWD/../data/rocksdb/100GB/ -res ./bench/results/cores_16/disks_1/rocksdb/100GB.json -th 16 -fl Read -ri 0 -rc 1"

#LD_PRELOAD=/users/gargsaab/ssd/fast_mongodb/shared_lib/lib_speedyio_bookkeeping.so $COMMAND

/usr/bin/time -v $COMMAND

#strace -f -tt -o o $PWD/strace.txt $COMMAND
