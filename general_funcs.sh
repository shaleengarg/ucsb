#!/bin/bash

if [ -z "$BASE" ]; then
        echo "SpeedyIO environment variables are undefined."
        echo "Did you setvars? goto Base directory (/path/to/speedyio_release) and $ source ./scripts/setvars.sh"
        exit 1
fi

check_ulimit() {
        current_limit=$(ulimit -n)

        # Check if the current limit is less than 10000
        if [ "$current_limit" -lt 10000 ]; then
                echo "The current ulimit is less than 10000: $current_limit"
                echo "Rocksdb makes a lot of files; experiment might not run to completion"
                echo "Please edit ulimt -n before rerunning this script"
                exit 1
        else
                echo "The current ulimit is $current_limit, which is sufficient."
        fi
}


human_readable_number() {
        num=$1
        if (( num < 1000 )); then
                echo "${num}"
        elif (( num < 1000000 )); then
                echo "$((num / 1000))K"
        elif (( num < 1000000000 )); then
                echo "$((num / 1000000))M"
        else
                echo "$((num / 1000000000))B"
        fi
}

FlushDisk()
{
        echo ""
        echo "sync and drop cache for unpolluted memory. Might require sudo password"
        sudo sh -c "echo 3 > /proc/sys/vm/drop_caches"
        sudo sh -c "sync"
        sudo sh -c "echo 3 > /proc/sys/vm/drop_caches"
        sleep 3
}

CHECK_ULIMIT() {
        current_limit=$(ulimit -n)
        if [ "$current_limit" -lt 10000 ]; then
                echo "Warning: ulimit -n is set to $current_limit; dbbench might not finish to completion"
        fi
}

CHECK_LDD() {
        speedyio_file=$1

        echo "Starting dependency check for $speedyio_file"

        if [ ! -f "$speedyio_file" ]; then
                echo "${FUNCNAME[0]} could not find $speedyio_file"
        fi

        # Capture missing libraries
        missing_libs=`ldd "$speedyio_file" 2>&1 | grep "not found" || true`

        # Print missing libraries if any, or a success message if none are missing
        if [ -n "$missing_libs" ]; then
                echo "The following libraries are missing for $speedyio_file:"
                echo "$missing_libs" | awk '{print $1}'
                echo "If you don't know how to fix this, contact us."
                exit 1
        else
                echo "All required libraries are found for $speedyio_file."
        fi
}

