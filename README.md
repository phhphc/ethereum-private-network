# Create Ethereum Private Network

## Bootnode
Bootnode is a lightweight application used for the Node Discovery Protocol. Bootnodes do not sync chain data. Using a UDP-based Kademlia-like RPC protocol, Ethereum will connect and interrogate these bootnodes for the location of potential peers.

## Persistence enode URL
Enode URL will be recreate after geth database is reset. 

To fixed enode URL, first create P2P node key file
```sh
$ bootnode -genkey boot.key 
```
Specify key file to geth using option `--nodekey`
```sh
$ geth [OPTION] --nodekey boot.key
```

## Enode URL vs ENR
### Enode URL
The Enode scheme is typically used in the discovery process and when specifying bootstrap nodes.

Consider this example of an ethereum node’s enode:// URL:
```
enode://11501bf6f21a04763aedb7b408c14b514de61c29eb9bd902a0884b2f9a2653d5b49fbf0a5019aa707e0fac1efca56c2a4e14293c579eaa3f353cdbafb22d253b@192.168.86.67:13000?discport=30301
```
- URL-scheme: enode
- IPv4 network address: 192.168.86.67 (DNS Domain Names not allowed)
- Transport protocol, listening port (TCP): 13000
- Discovery protocol port (UDP): 30301
- P2P Node’s public-key in hex-encoded format: 11501bf6f21a04763aedb7b408c14b514de61c29eb9bd902a0884b2f9a2653d5b49fbf0a5019aa707e0fac1efca56c2a4e14293c579eaa3f353cdbafb22d253b


### ENR
ENR’s are specific to the Ethereum network and used by a node to share information about itself. For example, a node can pack arbitrary key-value pairs along with a sequence number into a record and sign it. When ENR information is relayed in the P2P network, each node can verify the authenticity of the record. The record’s sequence number allows peers to detect that their cached record is outdated. Peers can also passively learn from relayed ENRs about other nodes in the network and decide if they want to peer with them. Ideally, the node record would include more information like the purpose of a node on the network, e.g. what network they’re on, their last head, etc.

The data structure is prefixed by `enr:` followed by a base64 encoded RLP list containing:
```
[signature, seq, k=id, v=scheme, (k, v)* ]
```
- A cryptographic signature of the record contents
- A sequence number versioning the record
- Arbitrary key-value pairs like:
    - required: id - the identity scheme
    - the following keys have a pre-defined meaning: secp256k1, ip, tcp, udp, ip6, tcp6, udp6

A record is validated according to the identity scheme (id) specified in the record.

## Static node
Static Nodes are pre-configured connections which are always maintained and re-connected on disconnects by Ethereum nodes. As static nodes will be connected to directly, no UDP discovery is required. 

Static node can be configured by supplying a “static-nodes.json” file in the Geth data directory:
```sh
$ cat GETH-DATA-DIR/static-nodes.json
[
"enode://pubkey@ip:port"
]
```

## Trusted node (trusted-nodes.json file config not work)
Similar to Static Nodes, Trusted Nodes are pre-configured peers which Geth will always try to stay connected to even after the peer limit has been reached. The peer limit is a limit to the number of peers that a Geth node can connect to; the default value is 25, but it can be configured using the `--maxpeers` flag. 

Trusted Nodes can be configured by supplying a “trusted-nodes.json” file in the Geth data directory: 
```sh
$ cat GETH-DATA-DIR/trusted-nodes.json 
[
"enode://pubkey@ip:port"
]
```

## Configuration file
Command line options can be specify in a TOML configuration file. To do this, specify options on the command line, and use the dumpconfig command to print the options into a new TOML configuration file.
```sh
$ geth [OPTIONS] dumpconfig > <TOML-CONFIG-FILE>
```
The configuration file contains your specified options and other default options.

You can reuse the configuration file across node startups. To specify the configuration file, use the --config option.
```sh
$ geth --config=<TOML-CONFIG-FILE>
```
To override an option specified in the configuration file, specify the same option on the command line.

## References
- https://geth.ethereum.org/docs/interface/private-network
- https://ethereum.stackexchange.com/questions/15541/how-to-add-new-sealer-in-geth-1-6-proof-of-authority
- https://medium.com/shyft-network/understanding-ethereums-p2p-network-86eeaa3345
- https://devblogs.microsoft.com/cse/2018/06/01/creating-private-ethereum-consortium-kubernetes/
- https://consensys.net/docs/goquorum/en/latest/configure-and-manage/configure/use-configuration-file/
- https://consensys.net/diligence/blog/2020/09/libp2p-multiaddr-enode-enr/