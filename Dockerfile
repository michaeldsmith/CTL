FROM ubuntu:focal

RUN apt-get update

# disable interactive install 
ENV DEBIAN_FRONTEND noninteractive

# install developement tools
RUN apt-get -y install cmake
RUN apt-get -y install g++
RUN apt-get -y install valgrind
RUN apt-get -y install git

# install CTL dependencies
#RUN apt-get -y install libilmbase-dev
#RUN apt-get -y install libopenexr-dev
RUN apt-get -y install zlib1g-dev
WORKDIR /usr/src/
RUN git clone https://github.com/AcademySoftwareFoundation/openexr.git
WORKDIR /usr/src/openexr
RUN git checkout RB-2.5 
WORKDIR /usr/src/openexr/build
RUN cmake ..
RUN make
RUN make install

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

