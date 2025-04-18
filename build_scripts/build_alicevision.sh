#!/bin/bash

git clone https://github.com/jlblancoc/nanoflann.git
cd nanoflann && \
    mkdir build && \
    cd build && \
    cmake .. && \
    make -j && \
    sudo make install && \
    cd ../../

sudo apt-get install -y libpng-dev \
    libjpeg-dev \
    libtiff-dev \
    libxxf86vm1 \
    libxxf86vm-dev \
    libxi-dev \
    libxrandr-dev \
    libboost-all-dev \
    libopenimageio-dev \
    graphviz

git clone --recursive https://github.com/alicevision/AliceVision.git && \
    cd AliceVision && \
    mkdir build && \
    cd build && \
    cmake -DALICEVISION_BUILD_TESTS=OFF -DAV_BUILD_OPENEXR=OFF -DALICEVISION_BUILD_DEPENDENCIES=ON -DCMAKE_INSTALL_PREFIX=$PWD/install ../ && \
    make -j \
    sudo make install
