#!/bin/bash

#set -x
set -e


source ./general_funcs.sh
source ./workload_config.sh

declare -a trials=("1")
#declare -a thread_arr=("4" "8" "16" "32")
#declare -a thread_arr=("16")
declare -a thread_arr=("16")
#declare -a config_arr=("vanilla" "noet" "et_lru")
declare -a config_arr=("vanilla")
#declare -a config_arr=("vanilla" "et_pvt_lru")
declare -a mem_budget_percent_arr=("100" "80" "70" "60" "50" "40" "30" "20") ## Available Memory left in the system = X% of current AvailableMem
#declare -a mem_budget_percent_arr=("100") # Available Memory left in the system = X% of current AvailableMem


RUN() {
        TRIAL=$1
        THREAD=$2
        MEM_BUDGET_PERCENT=$3
        MEM_BUDGET=$4
        CONFIG=$5

        mem_budget_gb=$(echo "($MEM_BUDGET/1024)/1" | bc)

        RESULT_FOLDER="./bench/results/cores_$THREAD/rocksdb_${MEM_BUDGET}_mb/100GB_${TRIAL}.json"
        READ_COMMAND="$UCSB -db rocksdb  -cfg ./bench/configs/rocksdb/full.cfg -wl ./bench/workloads/${SIZE}.json -md $METADATA_FOLDER -sd $DATA_FOLDER -res $RESULT_FOLDER -th $THREAD -fl Read -ri 0 -rc 1"

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


check_ulimit

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
