#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

function check_err() {
if [ $1 -ne 0 ]; then
  echo -e "${RED}=========Failed=========${NC}"
  exit 1;
fi
echo -e "${GREEN}===========\nSuccess!!!\n===========${NC}"
}

echo -e "Start deploy"

cd /opt && rm -rf reddit &&\
sudo git clone -b monolith https://github.com/express42/reddit.git && \
cd reddit && sudo bundle install &&\
sudo mv /tmp/puma.service /etc/systemd/system/puma.service && \
sudo systemctl daemon-reload && sudo systemctl start puma && sudo systemctl enable puma

check_err $?



