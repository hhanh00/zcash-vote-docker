## Coordinator

- Collect and prepare the election files
    - On a clean vote-server, copy the `*.json` into `data/`
    - Run `zcash-vote-server`
    - Copy `data/` and `vote.db` to a staging directory
- Prepare the cometbft blockchain
    - Initialize `cometbft init`
    - Edit `.cometbft/config/config.toml` and remove the `moniker`
    - Copy `config.toml` and `genesis.json` to the staging directory

## Validators

- Pick either `Dockerfile.amd64` or `Dockerfile.arm64` depending on the architecture
- Build the image `docker build -f Dockerfile.arm64 -t vs .`
- set and export TS_AUTHKEY with Tailscale auth token (provided by the Coordinator)

### Run 1
- `docker-compose -f vote-server.yml up`
```
cometbft-1  | I[2025-10-31|06:39:40.636] Generated node key                           module=main path=/root/.cometbft/config/node_key.json
cometbft-1  | I[2025-10-31|06:39:40.637] Generated genesis file                       module=main path=/root/.cometbft/config/genesis.json
cometbft-1  | cb0596033c299dd6dfab6f49b3658d7d6f042a38
cometbft-1  | logtail started
```

Write down `cb0596033c299dd6dfab6f49b3658d7d6f042a38`, send it to the coordinator

- A new machine should be registered on tailscale
- Rename it to nodeX
- *Coordinator*: Edit `config.toml` / persisted_peers from the staging directory
    - ex: cb0596033c299dd6dfab6f49b3658d7d6f042a38@node1:26656
- Get the validator setting
    - `tail -n 20 node1/cometbft/config/genesis.json`
    - Give the `validators` item to the coordinator
- *Coordinator*: merge the validator entry into `genesis.json`
    in the staging directory
- Repeat with the other nodes

- The coordinator should have in the staging area:
    - `genesis.json`
    - `config.toml`
    - `vote.db`
    - `data/`
- Combine these files in an archive: `tar cvzf config.tgz *`
- Distribute to every participant

### Run 2
- Decompress `config.tgz` in `node1/config`
- Rerun `docker-compose -f vote-server.yml up` (from top dir)
- It copies the config to the container and exits

### Run 3
- Rerun `docker-compose -f vote-server.yml up -d` (from top dir)

### Test
- Connect to container `docker exec -it cometbft-1 /bin/bash`
- Run `supervisorctl`
- Check that every service is running
- `tail -f cometbft`
- Blocks should be producing
