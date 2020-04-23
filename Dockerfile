FROM debian:buster

RUN apt-get update
RUN apt-get -y install git
RUN git clone https://github.com/WiringPi/WiringPi.git
RUN sed -i -e 's/gcc/..\/..\/tools\/arm-bcm2708\/arm-linux-gnueabihf\/bin\/arm-linux-gnueabihf-gcc/g' WiringPi/wiringPi/Makefile

RUN git clone https://github.com/madler/zlib.git
RUN git clone --recursive https://github.com/awstanley/deps-zlib-libpng.git
RUN git clone https://github.com/raspberrypi/tools.git

COPY toolchain-rpi.cmake .
RUN apt-get -y install zlib1g-dev libpng-dev

RUN apt-get -y install make cmake
RUN cd WiringPi/wiringPi && make && ln -sf libwiringPi.so.2.* libwiringPi.so

RUN mkdir -p zlib/build_arm && cd zlib/build_arm && cmake .. -DCMAKE_TOOLCHAIN_FILE=../toolchain-rpi.cmake && make
RUN ln -rsf zlib/build_arm/zconf.h tools/arm-bcm2708/arm-linux-gnueabihf/arm-linux-gnueabihf/include
RUN ln -rsf zlib/zlib.h tools/arm-bcm2708/arm-linux-gnueabihf/arm-linux-gnueabihf/include

RUN ln -rsf zlib/build_arm/zconf.h tools/arm-bcm2708/arm-linux-gnueabihf/include
RUN ln -rsf zlib/zlib.h tools/arm-bcm2708/arm-linux-gnueabihf/include

RUN cd deps-zlib-libpng && git submodule init && git submodule update --init --recursive && git submodule update --remote

RUN mkdir -p build_libpng && cd build_libpng && cmake ../deps-zlib-libpng -DCMAKE_TOOLCHAIN_FILE=../toolchain-rpi.cmake && make

LABEL maintainer="mh@0x25.net"

RUN apt-get -y install g++