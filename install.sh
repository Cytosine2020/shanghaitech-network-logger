#!/bin/sh

if [ ! -z $(which apt) ]; then
  apt install -y curl mailutils || exit 1
elif [ ! -z $(which yum) ]; then
  yum install -y curl mailx || exit 1
fi

cd watchdog
./uninstall.sh
./install.sh
cd - > /dev/null

if [ -f /usr/local/bin/network-logger.py ] || [ -f /lib/systemd/system/network-logger@.service ]; then
  echo "Already installed, please uninstall first to reinstall!"
  exit 1
fi

cp -n network-logger.py /usr/local/bin/
cp -n network-logger@.service /lib/systemd/system/

mkdir -p /etc/network-logger

if [ ! -f /etc/network-logger/example.toml ]; then
  cp -n example.toml /etc/network-logger
fi

systemctl daemon-reload
