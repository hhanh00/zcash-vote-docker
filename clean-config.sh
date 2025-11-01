#!/bin/bash

pushd node1
rm -rf cometbft/data
rm cometbft/config/node_key.json cometbft/config/priv_validator_key.json
grep -v '^moniker = ' cometbft/config/config.toml > tmpfile && mv tmpfile cometbft/config/config.toml
popd
mv node1 root
