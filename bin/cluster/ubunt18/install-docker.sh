#!/bin/sh
# ./bin/cluster/ubuntu18/install-docker.sh
#########################################################################
#      Copyright (C) 2020        Sebastian Francisco Colomar Bauza      #
#      SPDX-License-Identifier:  GPL-2.0-only                           #
#########################################################################
set -x                                                                  ;
#########################################################################
log=/tmp/install-docker.log                                             ;
#########################################################################
sudo apt-get update                                                     ;
sudo apt-get install -y docker.io                                       \
        2>& 1                                                           \
|                                                                       \
tee --append $log                                                       ;
sudo systemctl enable --now docker                                      \
        2>& 1                                                           \
|                                                                       \
tee --append $log                                                       ;
#########################################################################

