#ifndef FILESTORE_MINI_H
#define FILESTORE_MINI_H

#include <cstddef>

#include "objectstore.h"
#include "rocksdb/db.h"

class Filestore_Mini : Objectstore {
  private:
    rocksdb::DB* db_;
    std::string db_path_;
    std::string root_filesystem_;
    void init_rocksdb();
  public:
    Filestore_Mini(std::string db_path, std::string root_filesystem);
    void put(std::string name, std::string data);
    std::string get(std::string name);
    ~Filestore_Mini();
};

#endif
