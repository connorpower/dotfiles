#!/usr/bin/env bash

tmux new-window -n 'HyDRA' \; \
  send-keys "cd '${HOME}/Developer/ditto/ditto/hydra'" C-m \; \
  split-window -h -p 25 \; \
  send-keys 'zookeeper-server-start /usr/local/etc/zookeeper/zoo.cfg' C-m \; \
  split-window -v -p 50 \; \
  send-keys 'sleep 10; kafka-server-start /usr/local/etc/kafka/server.properties' C-m \; \
  select-pane -t 0 \; \
  send-keys 'sleep 20; ./script/dev' C-m \;

