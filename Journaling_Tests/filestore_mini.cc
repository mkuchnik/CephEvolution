#include "filestore_mini.h"

#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <unistd.h>

#include "rocksdb/db.h"
#include "rocksdb/slice.h"
#include "rocksdb/options.h"

const size_t metadata_key_size = 100; // Configurable
const size_t metadata_value_size = 400; // Configurable

Filestore_Mini::Filestore_Mini(std::string db_path,
                               std::string root_filesystem)
    : db_(nullptr),
      db_path_(db_path),
      root_filesystem_(root_filesystem) {
  init_rocksdb();
}

void Filestore_Mini::put(std::string name, std::string data) {
  std::string filename = root_filesystem_ + name;
  int fd = open(filename.c_str(), O_RDWR | O_CREAT);
  assert(fd != -1);
  ssize_t nwrite = write(fd, data.c_str(), data.size());
  assert(nwrite == data.size());
  fdatasync(fd);
  close(fd);

  rocksdb::WriteOptions write_options;
  write_options.sync = true;
  const std::string metadata_name = name + std::string(metadata_key_size - name.size(), 'b');
  const std::string metadata_value(metadata_value_size, 'c');
  rocksdb::Status s = db_->Put(write_options, metadata_name, metadata_value);
  assert(s.ok());
}

std::string Filestore_Mini::get(std::string name) {
  return std::string("");
}

void Filestore_Mini::init_rocksdb() {
  rocksdb::Options options;
  // Optimize RocksDB. This is the easiest way to get RocksDB to perform well
  options.IncreaseParallelism();
  options.OptimizeLevelStyleCompaction();
  // create the DB if it's not already present
  options.create_if_missing = true;
  options.info_log_level = rocksdb::InfoLogLevel::INFO_LEVEL;
  options.write_buffer_size = 2 * 1024 * 1024;

  // open DB
  rocksdb::Status s = rocksdb::DB::Open(options, db_path_, &db_);
  assert(s.ok());
}

Filestore_Mini::~Filestore_Mini() {
  delete db_;
}
