#!/bin/bash

if [[ -s /root/config/vote.db && ! -s /root/zcash-vote-server/db/vote.db ]]; then
    cp /root/config/config.toml /root/.cometbft/config/
    cp /root/config/genesis.json /root/.cometbft/config/
    cp /root/config/vote.db /root/zcash-vote-server/db/vote.db
    cp -r /root/config/data /root/zcash-vote-server/
    cp /root/supervisord.conf /etc/
elif [ -s /root/zcash-vote-server/db/vote.db ]; then
    cp /root/supervisord.conf /etc/
    /usr/bin/supervisord -c /etc/supervisord.conf
    echo "Running"
    /bin/bash
elif [ ! -s /root/.cometbft/config/genesis.json ]; then
    cometbft init
    cometbft show-node-id
    tailscaled &
    sleep 5
    tailscale login --auth-key=$TS_AUTHKEY --hostname=$NODE
    tailscale up
fi
