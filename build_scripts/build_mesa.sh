./configure --enable-opengl --disable-gles1 --disable-gles2   \
            --disable-va --disable-xvmc --disable-vdpau       \
            --enable-shared-glapi                             \
            --disable-texture-float                           \
            --enable-gallium-llvm --enable-llvm-shared-libs   \
            --with-gallium-drivers=swrast,swr                 \
            --disable-dri --with-dri-drivers=                 \
            --disable-egl --with-egl-platforms= --disable-gbm \
            --disable-glx                                     \
            --disable-osmesa --enable-gallium-osmesa          \
            ac_cv_path_LLVM_CONFIG=llvm-config-6.0
make -j8
sudo make install
