from web3 import Web3
from web3.exceptions import ContractLogicError
from pathlib import Path

import json

BASE_DIR = "../blockchain/artifacts/contracts"

# Основной класс для взаимодействия с контрактом

# web3 — это клиент
# provider — транспорт
# node — исполнитель
# EVM — вычислитель
# контракт — просто код в блокчейне

# [ Python code ]
#       │
#       ▼
# [ web3.py ]
#       │  (ABI encode)
#       ▼
# [ Provider ]
#       │  (JSON-RPC)
#       ▼
# [ Blockchain Node ]
#       │
#       ▼
# [ EVM ]
#       │
#       ▼
# [ Smart Contract ]
#       │
#       ▼
# [ State / Result ]

class ContractClient:
    def __init__(self, provider_url: str, contract_json_path: str):
        # Этот провайдер обрабатывает взаимодействие с сервером JSON-RPC на основе HTTP или HTTPS.
        self.w3 = Web3(Web3.HTTPProvider(provider_url)) # Создаём и связываем наш атрибут класса w3 с блокчейном

        # Достаём данные из контракта и сохраняем их для дальнейшего взаимодействия
        with open(Path(contract_json_path)) as f:
            config = json.load(f) 
        # Создаём локальный интерфейс для взаимодействия с контрактом по ABI и адресу
        self.contract = self.w3.eth.contract(
            address=config["address"],
            abi=config["abi"]
        )

        self.public_key = None  

    def _set_account(self, public_key: str):
        self.public_key = self.w3.to_checksum_address(public_key)
        self.w3.eth.default_account = self.public_key

    def unset_account(self):
        self.public_key = None
        self.w3.eth.default_account = None

    def authorization_user(self, public_key: str):
        try:
            self._set_account(public_key)
            res = self.call("Auth")
            if res[0][0] == "":
                self.unset_account()
                return "Not authorized"
            return res
        except Exception as e:
            return e
        
    def to_transact(self, method_name: str, args: list = None, is_transact: bool = False, value_wei: int = 0):
        try:
            method = getattr(self.contract.functions, method_name)
            #getattr(myobj, 'myattr')
            # То же, что и
            # myobj.myattr
            function = method(*args) if args else method()
            tx_params = {'from': self.public_key} # tx - транзакция
            
            if value_wei:
                tx_params['value'] = value_wei

            return function.transact(tx_params) if is_transact else function.call(tx_params)
        except ContractLogicError as e:
            return e
        except Exception as e:
            return e


contract_client = ContractClient(
    provider_url="http://127.0.0.1:8545",
    contract_json_path=f"{BASE_DIR}/contract.sol/Contract.json"
)