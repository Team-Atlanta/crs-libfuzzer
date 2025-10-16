#!/bin/sh

set -eu

NCPU=$(echo "$CPUSET_CPUS" | awk -F',' '{print NF}')
taskset -c $CPUSET_CPUS run_fuzzer $@ --fork=$NCPU
