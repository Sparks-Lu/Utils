sudo apt update
sudo add-apt-repository -y ppa:deadsnakes/ppa && sudo apt update
sudo apt install -y software-properties-common
sudo apt install -y python3.9 python3.9-distutils
mkdir ~/.pip

cat << EOF > ~/.pip/pip.conf
[global]
index-url=https://mirrors.aliyun.com/pypi/simple

[install]
trusted-host=mirrors.aliyun.com
EOF

sudo python3.9 -m pip install --upgrade pip
sudo sudo python3.9 -m pip uninstall -y setuptools
sudo python3 -m pip install setuptools
sudo apt install -y virtualenv virtualenvwrapper
sudo python3 -m pip install virtualenvwrapper
cat << END >> ~/.bashrc
export WORKON_HOME=~/.virtualenvs
export PROJECT_HOME=~/workspace
export VIRTUALENVWRAPPER_PYTHON=/usr/bin/python3
source /usr/local/bin/virtualenvwrapper.sh
END
