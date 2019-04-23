#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

function check_err() {
if [ $1 -ne 0 ]; then
  echo -e "${RED}=========\nFailed\n=========${NC}"
  exit 1;
fi
echo -e "${GREEN}===========\nSuccess!!!\n===========${NC}"
}

echo "Installing MongoDB"

echo "Step 1. Add repo"
sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv EA312927 && \
sudo bash -c 'echo "deb http://repo.mongodb.org/apt/ubuntu xenial/mongodb-org/3.2 multiverse" > /etc/apt/sources.list.d/mongodb-org-3.2.list'

check_err $? 

#if [ $? -ne 0 ]; then
#  echo "Repo install error: $repo"
#  exit 1;
#fi

echo "Step 2. Install mongo"
sudo apt update && sudo apt install -y mongodb-org 
check_err $?

echo "Step 3. Copy mongo config"
sudo cp /tmp/mongod.conf /etc/mongod.conf
check_err $?

echo "Step 4. Start mongodb"
sudo systemctl start mongod && sudo systemctl enable mongod
check_err $?



