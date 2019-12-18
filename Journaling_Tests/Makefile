$(shell (export ROCKSDB_ROOT="$(CURDIR)/rocksdb"; export PORTABLE="$(PORTABLE)"; cd rocksdb; "$(CURDIR)/rocksdb/build_tools/build_detect_platform" "$(CURDIR)/rocksdb/make_config.mk"))

include rocksdb/make_config.mk

ifndef DISABLE_JEMALLOC
	ifdef JEMALLOC
		PLATFORM_CXXFLAGS += -DROCKSDB_JEMALLOC -DJEMALLOC_NO_DEMANGLE
	endif
	EXEC_LDFLAGS := $(JEMALLOC_LIB) $(EXEC_LDFLAGS) -lpthread
	PLATFORM_CXXFLAGS += $(JEMALLOC_INCLUDE)
endif

ifneq ($(USE_RTTI), 1)
	CXXFLAGS += -fno-rtti
endif

.PHONY: clean librocksdb

all: main

main: librocksdb main.cc bluestore_mini.o filestore_mini.o
	$(CXX) $(CXXFLAGS) main.cc bluestore_mini.o filestore_mini.o -o$@ rocksdb/librocksdb.a -Irocksdb/include -O2 -std=c++11 $(PLATFORM_LDFLAGS) $(PLATFORM_CXXFLAGS) $(EXEC_LDFLAGS)
filestore_mini.o: filestore_mini.h filestore_mini.cc objectstore.h
	$(CXX) $(CXXFLAGS) -c filestore_mini.cc -Irocksdb/include --std=c++11
bluestore_mini.o: bluestore_mini.h bluestore_mini.cc objectstore.h
	$(CXX) $(CXXFLAGS) -c bluestore_mini.cc -Irocksdb/include --std=c++11
.c.o:
	$(CC) $(CFLAGS) -c $< -o $@ -Irocksdb/include
librocksdb:
	cd rocksdb && $(MAKE) static_lib
clean:
	rm -rf ./main *.o
