#!/bin/bash

#set -x
set -e

if [ -z "$BASE" ]; then
        echo "SpeedyIO environment variables are undefined."
        echo "Did you setvars? goto Base directory (/path/to/speedyio_release) and $ source ./scripts/setvars.sh"
        exit 1
fi



declare -a trials=("1")
#declare -a thread_arr=("4" "8" "16" "32")
#declare -a thread_arr=("16")
declare -a thread_arr=("16")
declare -a config_arr=("vanilla")
#declare -a mem_budget_percent_arr=("100" "50" "40" "30" "20" "15" "10" "8") ## Available Memory left in the system = X% of current AvailableMem
declare -a mem_budget_percent_arr=("100") ## Available Memory left in the system = X% of current AvailableMem


DATA_FOLDER="$HOME/ssd/data/rocksdb/100GB"
#DATA_FOLDER="$HOME/slowssd/data/rocksdb/500GB"

UCSB="./build_release/build/bin/ucsb_bench"

#LOAD_COMMAND="./build_release/build/bin/ucsb_bench -db rocksdb  -cfg ./bench/configs/rocksdb/100GB.cfg -wl ./bench/workloads/100GB.json -md ./db_main/rocksdb/100GB/ -sd $DATA_FOLDER -res ./bench/results/cores_16/disks_1/rocksdb/100GB.json -th $THREADS -fl Init -ri 0 -rc 1"

#READ_COMMAND="./build_release/build/bin/ucsb_bench -db rocksdb  -cfg ./bench/configs/rocksdb/100GB.cfg -wl ./bench/workloads/100GB.json -md ./db_main/rocksdb/100GB/ -sd $DATA_FOLDER -res ./bench/results/cores_16/disks_1/rocksdb/100GB.json -th $THREADS -fl Read -ri 0 -rc 1"

FlushDisk()
{
        sudo sh -c "echo 3 > /proc/sys/vm/drop_caches"
        sudo sh -c "sync"
        sudo sh -c "echo 3 > /proc/sys/vm/drop_caches"
        sleep 3
}

RUN() {
        TRIAL=$1
        THREAD=$2
        MEM_BUDGET_PERCENT=$3
        MEM_BUDGET=$4
        CONFIG=$5

        mem_budget_gb=$(echo "($MEM_BUDGET/1024)/1" | bc)

        RESULT_FOLDER="./bench/results/cores_$THREAD/rocksdb_${MEM_BUDGET}_mb/100GB_${TRIAL}.json"
        #RESULT_FOLDER="./bench/results/cores_$THREAD/rocksdb_${mem_budget_gb}_gb/500GB_${TRIAL}.json"
        #READ_COMMAND="$UCSB -db rocksdb  -cfg ./bench/configs/rocksdb/100GB.cfg -wl ./bench/workloads/500GB.json -md ./db_main/rocksdb/500GB/ -sd $DATA_FOLDER -res $RESULT_FOLDER -th $THREAD -fl Read -ri 0 -rc 1"
        READ_COMMAND="$UCSB -db rocksdb  -cfg ./bench/configs/rocksdb/100GB.cfg -wl ./bench/workloads/100GB.json -md ./db_main/rocksdb/100GB/ -sd $DATA_FOLDER -res $RESULT_FOLDER -th $THREAD -fl Read -ri 0 -rc 1"

        FlushDisk

        ##################Memory shiz
        if [ "$MEM_BUDGET_PERCENT" -lt "100" ]; then
                $BASE/scripts/numa-memory-limiting/budget_memory.sh budget $MEM_BUDGET_PERCENT
        fi
        echo "DONE reducing mem"
        echo "$READ_COMMAND"

        if [ "$CONFIG" != "vanilla" ]; then
                CHECK_LDD $BASE/shared_lib/lib_speedyio_$CONFIG.so
                export LD_PRELOAD=$BASE/shared_lib/lib_speedyio_$CONFIG.so
        fi


        $READ_COMMAND

        export LD_PRELOAD=""

        $BASE/scripts/numa-memory-limiting/budget_memory.sh cleanup
}


for tr in "${trials[@]}"; do
        for th in "${thread_arr[@]}"; do
                for mb in "${mem_budget_percent_arr[@]}"; do
                        for cf in "${config_arr[@]}"; do

                                $BASE/scripts/numa-memory-limiting/budget_memory.sh cleanup
                                FlushDisk

                                mem_available_kb=$(grep MemAvailable /proc/meminfo | awk '{print $2}')
                                mem_block_kb=$(echo "($mem_available_kb * (100 - $mb) / 100)/1" | bc)
                                mem_block_mb=$(echo "($mem_block_kb / 1024)/1" | bc)
                                total_mem_mb=$(echo "($mem_available_kb / 1024)/1" | bc)
                                budget_mb=$(echo "($total_mem_mb - $mem_block_mb)" | bc)
                                echo "Memory to block $mem_block_mb MB,  Total memory:$total_mem_mb MB"

                                echo ""
                                echo "=============================================================="
                                echo "Running Threads:$th || Mem Budget:$mb% ($budget_mb MB) || Trial:$tr || Config:$cf"
                                echo "=============================================================="
                                RUN "$tr" "$th" "$mb" "$budget_mb" "$cf"

                                FlushDisk
                        done
                done
        done
done

$BASE/scripts/numa-memory-limiting/budget_memory.sh cleanup
