# Figure 3
## Dependencies
To install the required dependencies to run the experiment (including
RocksDB -- though we include it in this repo), run
```bash
./install_deps.sh
```

## Building
To build the binary for running the tests, run
```bash
make
```

## Running
There are two scripts corresponding to the hard drive tests (HDD) or the solid
state drives (SSD).

### HDD Tests
To run the HDD tests, run:
```bash
./run_test_hdd.sh
```

### SSD Tests
To run the SSD tests, run:
```bash
./run_test_ssd.sh
```

## Plotting
The results of the tests were written to files describing the experiment.
The non-data items can be removed with a convenience script as follows.

```bash
process_results_for_plot.sh filestore_test_hdd_xfs_50000.txt > processed_filestore_hdd.dat
```

```bash
process_results_for_plot.sh filestore_test_ssd_xfs_50000.txt > processed_filestore_ssd.dat
```

```bash
process_results_for_plot.sh bluestore_test_hdd_xfs_50000.txt > processed_bluestore_hdd.dat
```

```bash
process_results_for_plot.sh bluestore_test_ssd_xfs_50000.txt > processed_bluestore_ssd.dat
```

These processed files can then be plotted with tools such as GNUPlot.
The files are space seperate and contain (x,y) pairs corresponding to time and
object writes completed.
