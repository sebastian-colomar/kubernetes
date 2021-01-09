#!/bin/sh
# ./bin/docker/ubuntu18/install.sh
################################################################################
#      Copyright (C) 2020        Sebastian Francisco Colomar Bauza             #
#      SPDX-License-Identifier:  GPL-2.0-only                                  #
################################################################################
set -x                                                                         ;
                                                                               #
apt-get update                                                                 ;
apt-get install -y docker.io                                                   ;
systemctl enable docker                                                        ;
systemctl start docker                                                         ;
while true                                                                     ;
  do                                                                           \
    service docker status | grep running -q && break                           ;
    sleep 10                                                                   ;
  done                                                                         ;
################################################################################
