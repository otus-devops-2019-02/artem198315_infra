#!/bin/bash

echo "Installing ruby"

sudo apt update && \
sudo apt install -y ruby-full ruby-bundler build-essential &&\
bundler -v

if [ $? -ne 0 ] ;then 
  echo "Install error"
  exit 1;
fi

echo -e "=========\nSuccess!!!!\n=========="
