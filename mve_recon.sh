#!/bin/sh
cwd=`pwd`

build_mve() {
    git clone https://github.com/simonfuhrmann/mve.git
    cd mve
    make -j
    cd $cwd
}

recon() {
    $img_dir=$1
    $scene_dir=$2
    if [ -d $scene_dir ]; then
        mkdir $scene_dir
    fi
    apps/makescene/makescene -i $img_dir $scene_dir
    apps/sfmrecon/sfmrecon $scene_dir
    apps/dmrecon/dmrecon -s2 $scene_dir
    apps/scene2pset/scene2pset -F2 $scene_dir $scene_dir/pset-L2.ply
    apps/fssrecon/fssrecon $scene_dir/pset-L2.ply $scene_dir/surface-L2.ply
    apps/meshclean/meshclean -t10 $scene_dir/surface-L2.ply $scene_dir/surface-L2-clean.ply
}


img_dir=$1
scene_dir=$1/../mve
# build_mve
recon $img_dir $scene_dir 
