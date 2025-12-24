from web3 import Web3
from pathlib import Path
import json

BASE_DIR = "../blockchain/artifacts/contracts"
node_blockchain = "http://127.0.0.1:8545"

class ContractClient():
    
    def __init__(self, provider: str, json_contract_path: str):
        self.w3 = Web3(Web3.HTTPProvider(provider))
        self.pk = None
        
        with open(Path(json_contract_path)) as f:
            config = json.load(f)
            
        if not self.w3.is_connected():
            raise ConnectionError("HOOOOLY SHIT: No blockchain connection")
        print("WE IN NETWORK!")
            
        self.contract = self.w3.eth.contract(
            address=config["address"],   
            abi=config["abi"]
        )
        
    def set_account(self, pk: str):
        self.pk = self.w3.to_checksum_address(pk)
        self.w3.eth.default_account = self.pk

    def unset_account(self):
        self.pk = None
        self.w3.eth.default_account = None


contract_client = ContractClient(
    provider=node_blockchain,
    json_contract_path=f"{BASE_DIR}/Contract.sol/Contract.json"
)