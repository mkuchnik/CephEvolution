# A helper script to sweep over script inputs

bench_dir="."
benchmark_script="${bench_dir}/benchmark_micro_all.sh"
bash "${benchmark_script}" "4KB"
bash "${benchmark_script}" "8KB"
bash "${benchmark_script}" "16KB"
bash "${benchmark_script}" "32KB"
bash "${benchmark_script}" "64KB"
bash "${benchmark_script}" "128KB"
bash "${benchmark_script}" "256KB"
bash "${benchmark_script}" "512KB"
bash "${benchmark_script}" "1MB"
bash "${benchmark_script}" "2MB"
bash "${benchmark_script}" "4MB"