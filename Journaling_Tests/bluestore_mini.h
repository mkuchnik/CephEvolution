#ifndef BLUESTORE_MINI_H
#define BLUESTORE_MINI_H

#include "objectstore.h"
#include "rocksdb/db.h"

#include <fstream>

class Bluestore_Mini : Objectstore {
  private:
    rocksdb::DB* db_;
    std::string db_path_;
    std::string block_dev_path_;
    size_t block_offset_;
    int fd_;
    void init_rocksdb();
  public:
    Bluestore_Mini(std::string db_path,
                   std::string block_dev_path);
    void put(std::string name, std::string data);
    std::string get(std::string name);
    ~Bluestore_Mini();
};

#endif
