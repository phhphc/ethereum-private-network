include .env

NET_ID=7388

ADDR_1=0x40f922b761f27a8fc38bd26e33af795930aee7a0
ADDR_2=0x2adef4022acd11a9b8c1bd49e40134688063667d

BOOTNODE_PUBKEY=fd787a05f278ee308db905d0941a4038fa13aada261fa6c4248c6ef3461d07593430a1287dbd0a9edfff46c7ab6232a6b8c49a7b6c1b37b44e3999bbba48f767

GENESIS_FILE_1=genesis-1.json
GENESIS_FILE_2=genesis-2.json

GETH_ENV_FILE=services/geth.env
INSTALL_DIR=/usr/lib/systemd/system

clean:
	rm -rf node-1/geth
	rm -rf node-2/geth
	
	rm node-1/static-nodes.json

init-1: $(POA_FILE)
	geth init --datadir node-1 $(GENESIS_FILE_1)      
	geth init --datadir node-2 $(GENESIS_FILE_1)      

init-2: $(POW_FILE)
	geth init --datadir node-1 $(GENESIS_FILE_2)  
	geth init --datadir node-2 $(GENESIS_FILE_2)

node-2/static-nodes.json:
	echo [\"enode://$(BOOTNODE_PUBKEY)@$(BOOTNODE_IP):30303\"] > node-2/static-nodes.json

geth-env:
	echo "WORK_DIR=$(shell pwd)" > $(GETH_ENV_FILE)
	echo "NET_ID=$(NET_ID)" >> $(GETH_ENV_FILE)
	echo "IP=$(IP)" >> $(GETH_ENV_FILE)
	echo "ADDR_1=$(ADDR_1)" >> $(GETH_ENV_FILE)
	echo "ADDR_2=$(ADDR_2)" >> $(GETH_ENV_FILE)
	echo "" >> $(GETH_ENV_FILE)

signer:
	geth --datadir node-1 \
        --networkid $(NET_ID) \
        --unlock $(ADDR_1) --password node-1/password.txt \
        --mine --miner.etherbase=$(ADDR_1) \
        --nodekey node-1/boot.key \
        --nat extip:$(IP)

member: node-2/static-nodes.json
	geth --datadir node-2 \
        --networkid $(NET_ID) \
        --http --http.addr $(IP) --http.corsdomain '*' \
        --nodekey node-2/boot.key \
        --nat extip:$(IP)

install: /usr/local/bin/geth geth-env
	sudo cp $(GETH_ENV_FILE) $(INSTALL_DIR)
	sudo cp services/geth-signer.service $(INSTALL_DIR)
	sudo cp services/geth-member.service $(INSTALL_DIR)