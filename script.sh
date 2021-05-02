#!/bin/bash
# Author: Miroslaw Wiacek

echo -e "\033[1;31mBSK lab5 fix by Mirek Wiacek B)\033[0m"

# ensure root
if [ "$EUID" -ne 0 ]
  then echo -e "\033[0;31mMialo byc \"sudo bash ./script.sh \" :|\033[0m"
  exit
fi

# ensure home folder is working dir
cd ~/


# install all required dependencies
echo -e "\033[1;36m>>>>Installing updates and dependencies...\033[0m"
apt-get -y update
apt-get -y upgrade
apt-get -y install python-dev
apt-get -y install libssl-dev
apt-get -y install libpcap-dev

# clone and build pyrit
echo -e "\033[1;36m>>>>Installing Pyrit...\033[0m"
git clone https://github.com/JPaulMora/Pyrit.git --depth=1
sed -i "s/COMPILE_AESNI/COMPILE_AESNIX/" Pyrit/cpyrit/_cpyrit_cpu.c


cd Pyrit
python setup.py clean
python setup.py build
python setup.py install
cd ..

rm -rf Pyrit

# get setuptools and pip for python2.7 (required for pyrit)
echo -e "\033[1;36m>>>>Installing pip and scapy\033[0m"
wget https://bootstrap.pypa.io/pip/2.7/get-pip.py
python2.7 get-pip.py
rm -rf get-pip.py

git clone https://github.com/secdev/scapy
cd scapy
python2.7 setup.py build
python2.7 setup.py install

cd ..
rm -rf scapy


# Fix bug in pyrit
echo -e "\033[1;36m>>>>Patching pyrit...\033[0m"
sudo sed -i 's/if val not in field.i2s/if True/' /usr/local/lib/python2.7/dist-packages/cpyrit/pckttools.py 

# Check if installation was successful
pyr=$(pyrit | wc -l)


if [ $pyr -ge 5 ]; then
        echo -e "\033[1;32m>>>>Pyrit was installed correctly!\033[0m"
else
        echo -e "\033[1;31m>>>>Pyrit wasn't installed correctly. Clean install of kali is recommended\033[0m"
fi