#ifndef OBJECTSTORE_H
#define OBJECTSTORE_H

#include <string>

class Objectstore {
  protected:
    Objectstore() { };
  public:
    void put(std::string name, std::string data) { return; };
    std::string get(std::string name) { return std::string(""); };
}; 

#endif
