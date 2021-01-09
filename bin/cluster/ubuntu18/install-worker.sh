#!/bin/bash -x
#	./bin/cluster/ubuntu18/install-worker.sh
#########################################################################
#      Copyright (C) 2020        Sebastian Francisco Colomar Bauza      #
#      SPDX-License-Identifier:  GPL-2.0-only                           #
#########################################################################
set +x && test "$debug" = true && set -x                                ;
#########################################################################
test -n "$kube"                 || exit 100                             ;
test -n "$token_discovery"      || exit 100                             ;
test -n "$token_token"          || exit 100                             ;
#########################################################################
compose=etc/docker/swarm/docker-compose.yaml                            ;
log=/tmp/install-worker.log                                             ;
sleep=10                                                                ;
uuid=/tmp/$( uuidgen )                                                  ;
#########################################################################
git clone                                                               \
        --single-branch --branch v1.1                                   \
        https://github.com/secobau/nlb                                  \
        $uuid                                                           ;
sed --in-place s/worker/manager/ $uuid/$compose                         ;
sudo cp --recursive --verbose $uuid/run/* /run                          ;
sudo docker swarm init                                                  ;
sudo docker stack deploy --compose-file $uuid/$compose nlb              ;
rm --recursive --force $uuid                                            ;
while true                                                              ;
do                                                                      \
  sleep 1                                                               ;
  sudo docker service ls | grep '\([0-9]\)/\1' && break                 ;
done                                                                    ;
sudo rm --recursive --force /run/secrets /run/configs                   ;
#########################################################################
sudo sed --in-place                                                     \
        /$kube/d                                                        \
        /etc/hosts                                                      ;
sudo sed --in-place                                                     \
        /127.0.0.1.*localhost/s/$/' '$kube/                             \
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
