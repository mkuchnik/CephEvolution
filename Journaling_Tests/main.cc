/**
 * This emulates using a raw block device vs. using a filesystem with journaling
 * enabled. The Ceph system uses raw block devices with the BlueStore backend.
 * The Filestore backend uses a local filesystem.
 */
#include <cstdio>
#include <string>
#include <iostream>
#include <sstream>
#include <chrono>

#include "filestore_mini.h"
#include "bluestore_mini.h"

enum TestType {
  NONE = 0,
  FILESYSTEM = 1, // A test using the filesystem for object store
  RAW_BLOCK = 2 // A test using the block device for object store
};

const int kDataSize = 512 * 1024;

int journal_test_filesystem(int n_objects, std::string DBPath,
    std::string FilestorePath) {
  /**
   * Runs a test where 4MiB objects are written to a filestore and corresponding
   * metadata is written to a RocksDB database.
   * @param n_objects The number of objects to write
   * @param DBPath The path to write database files to
   * @param FilestorePath The path to write object to
   * @return 0 if success
   */
  Filestore_Mini object_store(DBPath, FilestorePath);
  std::vector<size_t> time_spans;
  const size_t expected_seconds = 40 * 60; // 40 minutes
  time_spans.reserve(expected_seconds);
  int count = 0;
  int sec = 0;
  std::chrono::high_resolution_clock::time_point t1 = std::chrono::high_resolution_clock::now();
  for (size_t i = 0; i < n_objects; i++) {
    std::string name = std::to_string(i);
    object_store.put(name, std::string(kDataSize, 'a'));
    ++count;
    std::chrono::high_resolution_clock::time_point t2 = std::chrono::high_resolution_clock::now();
    auto time_span = std::chrono::duration_cast<std::chrono::seconds>(t2 - t1).count();
    if (time_span >= 1) {
      ++sec;
      fprintf(stdout, "%d %d\n", sec, count);
      count = 0;
      t1 = t2;
    }
  }
  std::cout << "Time to write each 100 objects" << std::endl;
  for (auto t: time_spans) {
    std::cout << t << ",";
  }
  std::cout << std::endl;
  return 0;
}

int journal_test_raw_block(int n_objects, std::string DBPath,
    std::string BlockPath) {
  /**
   * Runs a test where 4MiB objects are written to a raw block device
   * and corresponding metadata is written to a RocksDB database.
   * @param n_objects The number of objects to write
   * @param DBPath The path to write database files to
   * @param BlockPath The path to write object to. This should be a block
   * device.
   * @return 0 if success
   */
  Bluestore_Mini object_store(DBPath, BlockPath);
  std::vector<size_t> time_spans;
  const size_t expected_seconds = 40 * 60; // 40 minutes
  time_spans.reserve(expected_seconds);
  int count = 0;
  int sec = 0;
  std::chrono::high_resolution_clock::time_point t1 = std::chrono::high_resolution_clock::now();
  for (size_t i = 0; i < n_objects; i++) {
    std::string name = std::to_string(i);
    object_store.put(name, std::string(kDataSize, 'a'));
    ++count;
    std::chrono::high_resolution_clock::time_point t2 = std::chrono::high_resolution_clock::now();
    auto time_span = std::chrono::duration_cast<std::chrono::seconds>(t2 - t1).count();
    if (time_span >= 1) {
      ++sec;
      fprintf(stdout, "%d %d\n", sec, count);
      count = 0;
      t1 = t2;
    }
  }
  std::cout << "Time to write each 100 objects" << std::endl;
  for (auto t: time_spans) {
    std::cout << t << ",";
  }
  std::cout << std::endl;
  return 0;
}

/**
 * Emulate an OSD workload.
 * Creates a 4 MB object, calls fsync, and then inserts Key-Value pair to RocksDB
 * synchonously.
 * It does this N times.
 *
 * There are two modes
 *
 * params:
 * N (int): the number of objects to write
 * mode (enum): Filesystem vs. Raw Block with RocksDB
 */
int journal_test(int n_objects, TestType test_type,
    std::string DBPath, std::string FileOrBlockPath) {
  int ret = -1;
  switch(test_type) {
    case TestType::FILESYSTEM:
      ret = journal_test_filesystem(n_objects, DBPath, FileOrBlockPath);
      break;
    case TestType::RAW_BLOCK:
      ret = journal_test_raw_block(n_objects, DBPath, FileOrBlockPath);
      break;
    default:
      throw std::runtime_error("The test_type is not supported");
      break;
  };
  return ret;
}

int main(int argc, char** argv) {
  std::vector<std::string> args;
  for (int i = 0; i < argc; i++){
    std::string argi(argv[i]);
    args.push_back(argi);
  }
  std::cout << std::string(80, '*') << std::endl;
  std::cout << "Args:" << std::endl;
  for (auto const& v: args) {
    std::cout << v << std::endl;
  }

  std::cout << std::string(80, '*') << std::endl;
  if (args.size() != 5) {
    throw std::runtime_error("Usage " + args.at(0) + " <nobjects> <test_type>");
  }
  std::string arg1 = args.at(1);
  std::stringstream ss(arg1);
  int n_objects = -1;
  ss >> n_objects;
  assert(n_objects >= 0);

  const std::string test_type_str = args.at(2);
  TestType test_type = TestType::NONE;
  if (test_type_str == "filesystem") {
    test_type = TestType::FILESYSTEM;
  }
  else if (test_type_str == "raw_block") {
    test_type = TestType::RAW_BLOCK;
  }
  else {
    throw std::runtime_error("The test_type is not supported. "
        "Supported types are 'filesystem' and 'raw_block'"
    );
  }
  std::string DBPath = args.at(3);
  std::string FileOrBlockPath = args.at(4);

  std::cout << "Running test with " << n_objects << " objects and test type "
    << test_type_str << std::endl;
  int ret = journal_test(n_objects, test_type, DBPath, FileOrBlockPath);
  std::cout << "Test returned " << ret << std::endl;
}
