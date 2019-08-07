#include "bluestore_mini.h"

#include "rocksdb/db.h"
#include "rocksdb/slice.h"
#include "rocksdb/options.h"
#include "rocksdb/env.h"

#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <unistd.h>

const size_t metadata_key_size = 100; // Configurable
const size_t metadata_value_size = 400; // Configurable

Bluestore_Mini::Bluestore_Mini(std::string db_path,
                               std::string block_dev_path)
    : db_(nullptr),
      db_path_(db_path),
      block_dev_path_(block_dev_path),
      block_offset_(0) {
  fd_ = open(block_dev_path.c_str(), O_RDWR);
  assert(fd_ != -1);
  init_rocksdb();
}

void Bluestore_Mini::put(std::string name, std::string data) {
  ssize_t nwrite = pwrite(fd_, data.c_str(), data.size(), block_offset_);
  assert(nwrite == data.size());
  fdatasync(fd_);
  block_offset_ += data.size();

  rocksdb::WriteOptions write_options;
  write_options.sync = true;
  const std::string metadata_name = name + std::string(metadata_key_size - name.size(), 'b');
  const std::string metadata_value(metadata_value_size, 'c');
  rocksdb::Status s = db_->Put(write_options, metadata_name, metadata_value);
  assert(s.ok());
}

std::string Bluestore_Mini::get(std::string name) {
  return std::string("");
}

void Bluestore_Mini::init_rocksdb() {
  rocksdb::Options options;
  // Optimize RocksDB. This is the easiest way to get RocksDB to perform well
  options.IncreaseParallelism();
  options.OptimizeLevelStyleCompaction();
  // create the DB if it's not already present
  options.create_if_missing = true;
  options.info_log_level = rocksdb::InfoLogLevel::INFO_LEVEL;
  options.write_buffer_size = 2 * 1024 * 1024;
  options.recycle_log_file_num = 2;

  // open DB
  rocksdb::Status s = rocksdb::DB::Open(options, db_path_, &db_);
  assert(s.ok());
}

Bluestore_Mini::~Bluestore_Mini() {
  delete db_;
}
