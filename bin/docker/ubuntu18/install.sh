#!/bin/sh
# ./bin/docker/ubuntu18/install.sh
################################################################################
#      Copyright (C) 2020        Sebastian Francisco Colomar Bauza             #
#      SPDX-License-Identifier:  GPL-2.0-only                                  #
################################################################################
set -x                                                                         ;
################################################################################
sudo apt-get update                                                            ;
sudo apt-get install -y docker.io                                              ;
sudo systemctl enable --now docker                                             ;
################################################################################
