FROM ubuntu:18.04

LABEL maintainer="Michael Kuchnik <michaelkuchnik@gmail.com>"

RUN mkdir $HOME/code
WORKDIR $HOME/code
RUN apt-get update && apt-get install -y \
  libgflags-dev \
  libsnappy-dev \
  zlib1g-dev \
  libbz2-dev \
  liblz4-dev \
  libzstd-dev \
  git \
  xfsprogs \
  build-essential \
&& rm -rf /var/lib/apt/lists/*