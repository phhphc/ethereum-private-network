include .env

NET_ID=123454321

ADDR_1=0x40f922b761f27a8fc38bd26e33af795930aee7a0
ADDR_2=0x2adef4022acd11a9b8c1bd49e40134688063667d
ADDR_3=0x2247BC77A8777326230aadC1F11ADD399CC52BC9
ADDR_4=0x856A08fFC8f38f31748be2E0fB4AEb50476385D4
ADDR_5=0x59f775Ba6690eD52164817884b5d342338630C91

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

bootnode: # generate a bootnode 
	bootnode -nodekey ./.bootnode/boot.key -addr $(IP):30305

node1:
		# --bootnodes $(ENODE_URL) \
	geth --datadir node-1 --networkid $(NET_ID) \
		--port 30306 --authrpc.port 8551 \
		--unlock $(ADDR_1)  --password node-1/password.txt \
		--mine --miner.threads=1 --miner.etherbase=$(ADDR_1) \
		--nodekey node-1/boot.key \
		--nat extip:$(IP) \
		$(OPTION)

node2:
		# --bootnodes $(ENODE_URL) \
	geth --datadir node-2 --networkid $(NET_ID) \
		--port 30307 --authrpc.port 8552 \
	  	--unlock $(ADDR_2) --password node-2/password.txt \
		--mine --miner.threads=1 --miner.etherbase=$(ADDR_2) \
		--nodekey node-2/boot.key \
		--nat extip:$(IP) \
		$(OPTION)

node3:
	geth --datadir node-3 --networkid $(NET_ID) \
		--bootnodes $(ENODE_URL) \
		--port 30308 --authrpc.port 8553 \
	  	--unlock $(ADDR_3) --password node-3/password.txt \
		--mine --miner.threads=1 --miner.etherbase=$(ADDR_3) \
		--nodekey node-3/boot.key \
		--nat extip:$(IP) \
		$(OPTION)

node4:
	geth --datadir node-4 --networkid $(NET_ID) \
		--bootnodes $(ENODE_URL) \
		--port 30309 --authrpc.port 8554 \
	  	--unlock $(ADDR_4) --password node-4/password.txt \
		--mine --miner.threads=1 --miner.etherbase=$(ADDR_4) \
		--nodekey node-4/boot.key \
		--nat extip:$(IP) \
		$(OPTION) 

node5:
	geth --datadir node-5 --networkid $(NET_ID) \
		--port 30310 --authrpc.port 8555 \
	  	--unlock $(ADDR_5) --password node-5/password.txt \
		--nodekey node-5/boot.key \
		--nat extip:$(IP) \
		$(OPTION) 
