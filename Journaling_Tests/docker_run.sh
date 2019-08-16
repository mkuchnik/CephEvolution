#!/bin/bash
docker run -it --rm -p 8888:8888 \
  -v $(pwd):/code \
  mkuchnik/ceph_evolution \
  "/bin/bash"