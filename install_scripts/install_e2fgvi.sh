# git clone https://github.com/MCG-NKU/E2FGVI.git
# check cuda version by nvidia-smi
pip3 install torch torchvision torchaudio --extra-index-url https://download.pytorch.org/whl/cu114
pip install mmcv-full -f https://download.openmmlab.com/mmcv/dist/cu101/torch1.5/index.html
pip install tensorboard matplotlib scikit-image==0.16.2
pip install tqdm
