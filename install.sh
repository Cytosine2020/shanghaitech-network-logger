#!/bin/sh


if [ ! -z $(which apt) ]; then
  apt install -y python3 python3-pip curl mailutils || exit 1
elif [ ! -z $(which yum) ]; then
  yum install -y python3 python3-pip curl mailx || exit 1
fi

python3 -m pip install toml || exit 1

if [ -f /usr/local/bin/network-logger.sh ] || [ -f /lib/systemd/system/network-logger@.service ]; then
  echo "Already installed, please uninstall first to reinstall!"
  exit 1
fi

cp -n network-logger.sh /usr/local/bin/
cp -n network-logger@.service /lib/systemd/system/

mkdir -p /etc/network-logger

if [ ! -f /usr/local/bin/network-logger.sh ]; then
  cp -an example.toml /etc/network-logger
fi
