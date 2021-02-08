#!/bin/sh
#########################################################################
#      Copyright (C) 2020        Sebastian Francisco Colomar Bauza      #
#      SPDX-License-Identifier:  GPL-2.0-only                           #
#########################################################################
set -x                                                                  ;
#########################################################################
engine=docker                                                           ;
log=/tmp/install-docker-ubuntu18.sh.log                                 ;
#########################################################################
sudo apt-get update                                                     ;
sudo apt-get install -y ${engine}.io                                    \
        2>& 1                                                           \
|                                                                       \
tee --append ${log}                                                     ;
sudo systemctl enable --now ${engine}                                   \
        2>& 1                                                           \
|                                                                       \
tee --append ${log}                                                     ;
#########################################################################
sleep=10                                                                ;
#########################################################################
while true                                                              ;
do                                                                      \
        systemctl status ${engine}                                      \
        |                                                               \
        grep running                                                    \
        &&                                                              \
        break                                                           ;
        sleep ${sleep}                                                  ;
done                                                                    ;
#########################################################################
