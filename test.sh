#!/bin/bash

sudo sh -c "echo 3 > /proc/sys/vm/drop_caches"

sleep 3

#LD_PRELOAD=/users/gargsaab/ssd/fast_mongodb/shared_lib/lib_speedyio_bookkeeping.so ./build_release/build/bin/ucsb_bench -db rocksdb  -cfg "./bench/configs/rocksdb/default.cfg" -wl "./bench/workloads/100GB.json" -md "./db_main/rocksdb/100GB/" -sd "/users/gargsaab/ssd/SHALEEN/ucsb/../data/rocksdb/100GB/" -res "./bench/results/cores_16/disks_1/rocksdb/100GB.json" -th 16 -fl Read -ri 0 -rc 1


strace -f -tt -o /users/gargsaab/ssd/SHALEEN/ucsb/strace_ucsb/strace_long_slow_zipfian_read.txt ./build_release/build/bin/ucsb_bench -db rocksdb  -cfg "./bench/configs/rocksdb/default.cfg" -wl "./bench/workloads/100GB.json" -md "./db_main/rocksdb/100GB/" -sd "/users/gargsaab/ssd/SHALEEN/ucsb/../data/rocksdb/100GB/" -res "./bench/results/cores_16/disks_1/rocksdb/100GB.json" -th 16 -fl Read -ri 0 -rc 1
