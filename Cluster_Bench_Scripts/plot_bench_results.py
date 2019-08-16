"""
Parses the results of RADOS bench and plots the results
Outputs plots in both operations/second and bandwidth
"MA_30s_MBps" is a Moving Average over 30 seconds in MBps
"MA_60s_ops" is a Moving Average over 60 seconds in operations/second


Usage:
<script name> --paths <path-to-bench_results.txt>
"""

import re
import pandas as pd
import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
import numpy as np
import seaborn as sns
import argparse

def main():
    parser = argparse.ArgumentParser(
        description="Reads benchmark_results filenames from rados bench and" \
        " plots the results"
    )
    parser.add_argument("--paths",
                        nargs="+",
                        required=False,
                        default=["bench_results.txt"],
                        help="The path of a file(s)")
    args = parser.parse_args()
    paths = args.paths
    if len(paths) <= 1:
        plt = plot_bench_results(paths[0])
    else:
        dfs = []
        for path in paths:
            print("path", path)
            df = bench_results_to_df(path)
            df = add_rolling_results(df)
            df["filename"] = path
            dfs.append(df)
        master_df = pd.concatenate(dfs, axis=1)
        master_df.plot(x="sec", y="MA_30s_ops")


def bench_results_to_df(bench_results_filename):
    curr_record_id = 0
    processed_lines = []
    with open(bench_results_filename, "r") as f:
        lines = f.read().splitlines()
        for l in lines:
            filtered_l = re.sub("\s\s+", " ", l).lstrip()
            lsplit = filtered_l.split(" ")
            # Skip all invalid lines
            try:
                record_id = int(lsplit[0])
            except:
                continue
            if record_id != curr_record_id:
                continue
            # NAN values
            processed_lines.append(lsplit)
            curr_record_id += 1
    columns = ['sec', 'Cur_ops', 'started', 'finished', 'avg_MBps', 'cur_MBps',
                'last_lat(s)', 'avg_lat(s)']
    df = pd.DataFrame(processed_lines, columns=columns)
    df = df.replace("-", np.nan)
    print("df: {}".format(df))
    print("df types: {}".format(df.dtypes))
    df[columns[1:]] = df[columns[1:]].astype(float)
    df["diff_ops"] = df["finished"].rolling(window=2).apply(lambda x: x[1]-x[0])
    return df

def add_rolling_results(df):
    """ Add rolling averages to df """
    df["diff_ops"] = df["finished"].rolling(window=2).apply(
        lambda x: x[1]-x[0],
        raw=True,
    )
    df["MA_30s_MBps"] = df["cur_MBps"].rolling(window=30).mean()
    df["MA_30s_ops"] = df["diff_ops"].rolling(window=30).mean()
    df["MA_15s_ops"] = df["diff_ops"].rolling(window=15).mean()
    df["MA_5s_ops"] = df["diff_ops"].rolling(window=5).mean()
    df["MA_60s_MBps"] = df["cur_MBps"].rolling(window=60).mean()
    df["MA_60s_ops"] = df["diff_ops"].rolling(window=60).mean()
    return df


def plot_bench_results(bench_results_filename):
    df = bench_results_to_df(bench_results_filename)
    df = add_rolling_results(df)
    df.plot(x="sec", y="cur_MBps")
    plt.tight_layout()
    plt.savefig("bench_results_cur_mbps.pdf")
    plt.clf()
    df.plot(x="sec", y="avg_MBps")
    plt.tight_layout()
    plt.savefig("bench_results_avg_mbps.pdf")
    plt.clf()
    df.plot(x="sec", y="MA_60s_MBps")
    plt.tight_layout()
    plt.savefig("bench_results_MA60s_mbps.pdf")
    plt.clf()
    df.plot(x="sec", y="MA_30s_MBps")
    plt.tight_layout()
    plt.savefig("bench_results_MA30s_mbps.pdf")
    plt.clf()
    df.plot(x="sec", y="diff_ops")
    plt.tight_layout()
    plt.savefig("bench_results_diff_ops.pdf")
    plt.clf()
    df.plot(x="sec", y="MA_60s_ops")
    plt.tight_layout()
    plt.savefig("bench_results_MA60s_ops.pdf")
    plt.clf()
    df.plot(x="sec", y="MA_30s_ops")
    plt.tight_layout()
    plt.savefig("bench_results_MA30s_ops.pdf")
    plt.clf()
    df.plot(x="sec", y="MA_15s_ops")
    plt.tight_layout()
    plt.savefig("bench_results_MA15s_ops.pdf")
    plt.clf()
    df.plot(x="sec", y="MA_5s_ops")
    plt.tight_layout()
    plt.savefig("bench_results_MA5s_ops.pdf")
    plt.clf()
    return plt

if __name__ == "__main__":
    main()

