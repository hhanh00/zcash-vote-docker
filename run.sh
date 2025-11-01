#!/bin/bash

if [ -n "$BOOT_COORDINATOR" ]; then
    cometbft init
    (cd /root/zcash-vote-server && ./zcash-vote-server -q)
elif [ -n "$BOOT_VALIDATOR" ]; then
    cometbft init
    tailscaled &
    sleep 5
    tailscale login --auth-key=$TS_AUTHKEY --hostname=$NODE
    tailscale up
    cometbft show-node-id
    tail -n 12 /root/.cometbft/config/genesis.json | head -9
else
    cp /root/supervisord.conf /etc/
    /usr/bin/supervisord -c /etc/supervisord.conf -n
fi
