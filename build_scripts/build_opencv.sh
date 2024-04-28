#!/bin/bash

version=4.6.0
cwd=`pwd`
install_deps() {
    sudo apt -y remove x264 libx264-dev

    ## Install dependencies
    sudo apt -y install build-essential checkinstall cmake pkg-config yasm
    sudo apt -y install git gfortran
    sudo apt -y install libjpeg8-dev libpng-dev

    sudo apt -y install software-properties-common
    sudo add-apt-repository "deb http://security.ubuntu.com/ubuntu xenial-security main"
    sudo apt -y update

    sudo apt -y install libjasper1
    sudo apt -y install libtiff-dev

    sudo apt -y install libavcodec-dev libavformat-dev libswscale-dev libdc1394-22-dev
    sudo apt -y install libxine2-dev libv4l-dev
    cd /usr/include/linux
    sudo ln -s -f ../libv4l1-videodev.h videodev.h
    cd "$cwd"

    sudo apt -y install libgstreamer1.0-dev libgstreamer-plugins-base1.0-dev
    sudo apt -y install libgtk2.0-dev libtbb-dev qt5-default
    sudo apt -y install libatlas-base-dev
    sudo apt -y install libfaac-dev libmp3lame-dev libtheora-dev
    sudo apt -y install libvorbis-dev libxvidcore-dev
    sudo apt -y install libopencore-amrnb-dev libopencore-amrwb-dev
    sudo apt -y install libavresample-dev
    sudo apt -y install x264 v4l-utils

    # Optional dependencies
    sudo apt -y install libprotobuf-dev protobuf-compiler
    sudo apt -y install libgoogle-glog-dev libgflags-dev
    sudo apt -y install libgphoto2-dev libeigen3-dev libhdf5-dev doxygen
}

echo "Installing dependencies..."
# install_deps
echo "Downloading opencv $version..."
# wget https://codeload.github.com/opencv/opencv/tar.gz/refs/tags/$version -O opencv-$version.tgz
# tar zxvf opencv-$version.tgz
# echo "Cloning opencv git repository v$version..."
# git clone https://github.com/opencv/opencv
# cd opencv && git checkout $version && cd ..
echo "Downloading opencv_contrib v$version..."
# wget https://codeload.github.com/opencv/opencv_contrib/tar.gz/refs/tags/$version -O opencv-contrib-$version.tgz
# tar zxvf opencv-contrib-$version.tgz
# echo "Cloning opencv_contrib git repository v$version..."
# git clone https://github.com/opencv/opencv_contrib
# cd opencv_contrib && git checkout $version && cd ..

rm -rf opencv_build
mkdir opencv_build
cd opencv_build
echo "Building opencv v$version..."
cmake -D CMAKE_BUILD_TYPE=RELEASE \
    -D WITH_TBB=ON \
    -D WITH_V4L=OFF \
    -D WITH_LIBV4L=ON \
    -D WITH_QT=ON \
    -D WITH_OPENGL=ON \
    -D OPENCV_EXTRA_MODULES_PATH=../opencv_contrib-$version/modules \
    -D WITH_OPENCL=OFF ../opencv-$version/ >cmake.out 2>&1 && \
    make -j >make.out 2>&1 && \
    sudo make install
