#!/bin/sh
#########################################################################
#      Copyright (C) 2020        Sebastian Francisco Colomar Bauza      #
#      SPDX-License-Identifier:  GPL-2.0-only                           #
#########################################################################
set -x                                                                  ;
#########################################################################
sudo yum update -y							;
sudo yum install -y python3						;
region=$( 								\
	curl -s 							\
	http://169.254.169.254/latest/dynamic/instance-identity/document\
	|								\
	awk -F '"' /region/'{ print $4 }' 				\
)									;
path=amazon-ssm-${region}/latest/linux_amd64/amazon-ssm-agent.rpm	;
sudo yum install -y 							\
	https://s3.${region}.amazonaws.com/${path}			;
#########################################################################
