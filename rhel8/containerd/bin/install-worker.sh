#!/bin/bash -x
#	./bin/cluster/ubuntu18/install-worker.sh
#########################################################################
#      Copyright (C) 2020        Sebastian Francisco Colomar Bauza      #
#      SPDX-License-Identifier:  GPL-2.0-only                           #
#########################################################################
set -x                                                                  ;
#########################################################################
test -n "$ip_master1"           || exit 301                             ;
test -n "$ip_master2"           || exit 302                             ;
test -n "$ip_master3"           || exit 303                             ;
test -n "$kube"                 || exit 304                             ;
test -n "$token_discovery"      || exit 305                             ;
test -n "$token_token"          || exit 306                             ;
#########################################################################
log=/tmp/install-worker.log                                             ;
port_master=6443                                                        ;
sleep=10                                                                ;
uuid=/tmp/$( uuidgen )                                                  ;
#########################################################################
sudo sed --in-place                                                     \
        /$kube/d                                                        \
        /etc/hosts                                                      ;
#########################################################################
token_discovery="$(                                                     \
        echo $token_discovery                                           \
        |                                                               \
        base64 --decode                                                 \
)"                                                                      ;
token_token="$(                                                         \
        echo $token_token                                               \
        |                                                               \
        base64 --decode                                                 \
)"                                                                      ;
#########################################################################
while true                                                              ;
do                                                                      \
        sudo systemctl is-enabled kubelet                               \
        |                                                               \
        grep enabled                                                    \
        &&                                                              \
        break                                                           \
                                                                        ;
        sleep $sleep                                                    ;
done                                                                    ;
#########################################################################
while true                                                              ;
do                                                                      \
        sudo                                                            \
                $token_token                                            \
                $token_discovery                                        \
                --ignore-preflight-errors all                           \
                2>&1                                                    \
        |                                                               \
        tee --append $log                                               \
                                                                        ;
        grep 'This node has joined the cluster' $log                    \
        &&                                                              \
        break                                                           \
                                                                        ;
        sleep $sleep                                                    ;
done                                                                    ;
#########################################################################
