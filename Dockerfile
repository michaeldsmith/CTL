FROM ubuntu:focal

RUN apt-get update

# disable interactive install 
ENV DEBIAN_FRONTEND noninteractive

# install developement tools
RUN apt-get -y install cmake
RUN apt-get -y install g++
RUN apt-get -y install valgrind

# install CTL dependencies
RUN apt-get -y install libilmbase-dev
RUN apt-get -y install libopenexr-dev
RUN apt-get -y install libtiff-dev

# install utilities for convenience, not needed for CTL
RUN apt-get -y install nano

# build CTL
WORKDIR /usr/src/CTL
COPY . .
WORKDIR /usr/src/CTL/build
RUN cmake ..
RUN make
RUN make install

# finalize docker environment
WORKDIR /usr/src/CTL

