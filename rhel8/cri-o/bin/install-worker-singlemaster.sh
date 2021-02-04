#!/bin/bash -x
#	./rhel8-containerd/bin/install-worker-singlemaster.sh
#########################################################################
#      Copyright (C) 2020        Sebastian Francisco Colomar Bauza      #
#      SPDX-License-Identifier:  GPL-2.0-only                           #
#########################################################################
set -v                                                                  ;
set -x                                                                  ;
#########################################################################
test -n "$ip_master1"           || exit 301                             ;
test -n "$kube"                 || exit 302                             ;
test -n "$token_discovery"      || exit 303                             ;
test -n "$token_token"          || exit 304                             ;
#########################################################################
log=/tmp/install-worker.log                                             ;
sleep=10                                                                ;
#########################################################################
echo                                                                    \
        $ip_master1                                                     \
        $kube                                                           \
|                                                                       \
sudo tee --append                                                       \
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
        break                                                           ;
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
        tee --append $log                                               ;
        grep 'This node has joined the cluster' $log                    \
        &&                                                              \
        break                                                           ;
        sleep $sleep                                                    ;
done                                                                    ;
#########################################################################
