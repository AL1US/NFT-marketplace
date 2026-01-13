from web3 import Web3
from pathlib import Path
import json

BASE_DIR = "../blockchain/artifacts/contracts"
node_blockchain = "http://127.0.0.1:8545"

class ContractClient():

    def __init__(self, provider: str, json_contract_path: str):
        self.w3 = Web3(Web3.HTTPProvider(provider))
        self.public_key = None
        
        with open(Path(json_contract_path)) as f:
            config = json.load(f)
            
        if not self.w3.is_connected():
            raise ConnectionError("HOOOOLY SHIT: No blockchain connection")
        print("WE IN NETWORK!")
            
        self.contract = self.w3.eth.contract(
            address=config["address"],   
            abi=config["abi"]
        )
        
        self.marketplace_address = self.contract.address
        
    def set_account(self, public_key: str):
        self.public_key = self.w3.to_checksum_address(public_key)
        self.w3.eth.default_account = self.public_key

    def unset_account(self):
        self.public_key = None
        self.w3.eth.default_account = None

    def to_transact(self, method_name: str, args: list = None, is_transact: bool = False, value_wei: int = 0):
        method = getattr(self.contract.functions, method_name)
        func = method(*(args or []))
        tx_params = {"from": self.public_key}
        if value_wei:
            tx_params["value"] = value_wei

        if is_transact:
            return func.transact(tx_params)
        return func.call()
    
    
    def approve_nft_contract(self):
        if not self.public_key:
            raise ValueError("Account not set")
            
        return self.to_transact(
            method_name="setApprovalForAll",
            args=[
                self.marketplace_address,
                True
            ],
            is_transact=True
        )

contract_client = ContractClient(
    provider=node_blockchain,
    json_contract_path=f"{BASE_DIR}/Contract.sol/Contract.json"
)