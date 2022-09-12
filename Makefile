include .env

NET_ID=58544

ADDR_1=0x40f922b761f27a8fc38bd26e33af795930aee7a0
ADDR_2=0x2adef4022acd11a9b8c1bd49e40134688063667d
ADDR_3=0x2247BC77A8777326230aadC1F11ADD399CC52BC9
ADDR_4=0x856A08fFC8f38f31748be2E0fB4AEb50476385D4

POA_FILE=genesis-poa.json
POW_FILE=genesis-pow.json

clean:
	@rm -rf node-1/geth
	@rm -rf node-2/geth
	@rm -rf node-3/geth
	@rm -rf node-4/geth
	@rm -rf node-5/geth

PoA: $(POA_FILE) # initializing the Geth database (proof of authority)
	geth init --datadir node-1 $(POA_FILE)      
	geth init --datadir node-2 $(POA_FILE)      
	geth init --datadir node-3 $(POA_FILE)      
	geth init --datadir node-4 $(POA_FILE)      
	geth init --datadir node-5 $(POA_FILE)      

PoW: $(POW_FILE) # initializing the Geth database (proof of work) 
	geth init --datadir node-1 $(POW_FILE)  
	geth init --datadir node-2 $(POW_FILE) 
	geth init --datadir node-3 $(POW_FILE)
	geth init --datadir node-4 $(POW_FILE)
	geth init --datadir node-5 $(POW_FILE)

boot:
	bootnode -nodekey node-1/boot.key -addr $(IP):30303

bootnode: # generate a bootnode 
	geth --datadir node-1 --networkid $(NET_ID) \
		--nodekey node-1/boot.key \
		--nat extip:$(IP) \
		$(OPTION)

signer1:
	geth --datadir node-2 --networkid $(NET_ID) \
		--bootnodes $(ENODE_URL) \
	  	--unlock $(ADDR_2) --password node-2/password.txt \
		--mine --miner.threads=1 --miner.etherbase=$(ADDR_2) \
		--nodekey node-2/boot.key \
		$(OPTION)

signer2:
	geth --datadir node-3 --networkid $(NET_ID) \
		--bootnodes $(ENODE_URL) \
	  	--unlock $(ADDR_3) --password node-3/password.txt \
		--mine --miner.threads=1 --miner.etherbase=$(ADDR_3) \
		--nodekey node-3/boot.key \
		$(OPTION)

member1:
	geth --datadir node-4 --networkid $(NET_ID) \
		--http --http.addr $(IP) --http.corsdomain '*' \
		--nodekey node-4/boot.key \
		--nat extip:$(IP) \
		$(OPTION)


services/geth-bootnode.env:
	echo "DATA_DIR=$(shell pwd)/node-1" > services/geth-bootnode.env
	echo "NET_ID=$(NET_ID)" >> services/geth-bootnode.env
	echo "NODE_KEY=$(pwd)/node-1/boot.key" >> services/geth-bootnode.env
	echo "IP=$(IP)" >> services/geth-bootnode.env

install-bootnode: /usr/local/bin/geth services/geth-bootnode.env
	sudo mv services/geth-bootnode.env /usr/lib/systemd/system
	sudo cp services/geth-bootnode.service /usr/lib/systemd/system

test: install-bootnode
	sudo systemctl daemon-reload
	sudo systemctl start geth-bootnode.service
	sudo systemctl status geth-bootnode.service