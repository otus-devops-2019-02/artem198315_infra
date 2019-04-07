#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

echo -e "${GREEN}===========\nCreate vm\n============${NC}"

gcloud compute instances create reddit-app \
--boot-disk-size=10GB \
--image-family reddit-full \
--machine-type=g1-small \
--tags puma-server \
--restart-on-failure \
--zone="europe-west3-c" \
--network-tier=STANDARD \
--preemptible \
&&
gcloud compute firewall-rules create \
default-puma-server --allow=tcp:9292 --direction=ingress \
--source-ranges=0.0.0.0/0 --target-tags=puma-server

