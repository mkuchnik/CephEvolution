#!/bin/bash
# Performs a RADOS bench on the cluster with a write and both read workloads

set -e

bash benchmark_micro_write.sh "${1}"
cp bench_results.txt "bench_results_micro_write_${1}.txt"
bash benchmark_micro_read_rand.sh "${1}"
cp bench_results.txt "bench_results_micro_read_rand_${1}.txt"
bash benchmark_micro_read_seq.sh "${1}"
cp bench_results.txt "bench_results_micro_read_seq_${1}.txt"