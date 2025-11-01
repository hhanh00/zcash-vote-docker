## Build the image (both Coordinator and Validators)
- Pick either `Dockerfile.amd64` or `Dockerfile.arm64` depending on the architecture
- Build the image `docker build -f Dockerfile.arm64 -t vs .`
- **set and export TS_AUTHKEY** with Tailscale auth token (provided by the Coordinator)

## Coordinator

- Make a staging directory `node1`
- Collect and prepare the election files
    - Copy the election files into `node1/data`
- Add the env variable BOOT_COORDINATOR=1 to vote-server.yml
- Run `docker-compose -f vote-server.yml up`

It should exit quickly and print something like:
```
Attaching to cometbft-1
cometbft-1  | I[2025-11-01|03:20:34.350] Generated private validator                  module=main keyFile=/root/.cometbft/config/priv_validator_key.json stateFile=/root/.cometbft/data/priv_validator_state.json
cometbft-1  | I[2025-11-01|03:20:34.350] Generated node key                           module=main path=/root/.cometbft/config/node_key.json
cometbft-1  | I[2025-11-01|03:20:34.350] Generated genesis file                       module=main path=/root/.cometbft/config/genesis.json
cometbft-1  | 2025-11-01T03:20:34.361123Z  INFO zcash_vote_server::election: Election ID: 4ee80d7a329b2e83144ba2f384b3024a4398c2a7c66c7d742eaebe940b21ad27
cometbft-1  | 2025-11-01T03:20:34.361149Z  INFO zcash_vote_server: # elections = 1
cometbft-1 exited with code 0
```

- Cleanup the config files by running `clean-config.sh`
- The config files are in the directory `root` now

## Validators

### Run 1
- Add the env variable BOOT_VALIDATOR=1 to vote-server.yml
- Make sure TS_AUTHKEY is set
- Run `docker-compose -f vote-server.yml up`
```
...
cometbft-1  | 4d0ab1fb5ba109cd0ca827ae001fb1b060e8afaf
cometbft-1  |     {
cometbft-1  |       "address": "E174B5234747DFC34DE099CCB0DCA6A59EF30C37",
cometbft-1  |       "pub_key": {
cometbft-1  |         "type": "tendermint/PubKeyEd25519",
cometbft-1  |         "value": "QgaM4opBTTdnDrKCgk6fL5K14l2Um9Lu1ps3C4+cUW0="
cometbft-1  |       },
cometbft-1  |       "power": "10",
cometbft-1  |       "name": ""
cometbft-1  |     }
```

Gives this info to the coordinator.

## Coordinator
- A new machine should be registered on tailscale
- Edit `config.toml` / `persistent_peers` from the staging directory
    - ex: 4d0ab1fb5ba109cd0ca827ae001fb1b060e8afaf@node1:26656
- Merge the validator entry into `genesis.json`
- Repeat with the other nodes

- Distribute the `root` directory to each participant (as a zip, tar, etc)

### Validator
- Overwrite the content of `node1` with the `root` directory from the coordinator
- Remove `BOOT_VALIDATOR=1` from `vote-server.yml`
- **Edit `config.toml` and remove your own node address from the `persistent_peers` list**
- Run `docker-compose -f vote-server.yml up -d` (from top dir. Notice the **-d**)

### Test
- Connect to container `docker exec -it cometbft-1 /bin/bash`
- Run `supervisorctl`
- Check that every service is running
- `tail -f cometbft`
- Blocks should be producing
