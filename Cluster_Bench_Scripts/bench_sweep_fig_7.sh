# A helper script to sweep over script inputs
# This is customized for Figure 7

set -e

bench_dir="."
benchmark_script="${bench_dir}/benchmark_micro_write_unlimited.sh"
bash "${benchmark_script}" "64KB"
mv bench_results.txt "bench_results_micro_write_64KB.txt"
bash "${benchmark_script}" "128KB"
mv bench_results.txt "bench_results_micro_write_128KB.txt"
bash "${benchmark_script}" "256KB"
mv bench_results.txt "bench_results_micro_write_256KB.txt"
bash "${benchmark_script}" "512KB"
mv bench_results.txt "bench_results_micro_write_512KB.txt"
bash "${benchmark_script}" "1MB"
mv bench_results.txt "bench_results_micro_write_1MB.txt"
bash "${benchmark_script}" "2MB"
mv bench_results.txt "bench_results_micro_write_2MB.txt"
bash "${benchmark_script}" "4MB"
mv bench_results.txt "bench_results_micro_write_4MB.txt"