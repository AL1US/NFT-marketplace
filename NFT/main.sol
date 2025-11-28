// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "./ERC/Xcoin.sol";
import "./ERC/NFT.sol";

// Эта штука как то решает проблему с тем, что этот контракт не может принимать nft
import "@openzeppelin/contracts/token/ERC1155/utils/ERC1155Holder.sol";


contract Main is Xcoin, XcoinNFT, ERC1155Holder {

    // Нужен для того, чтобы если несколько юзеров захотели добавить nft с одинаковым id в магазин,
    // то данные в мапинге не перезаписались, а добавились новые
    uint256 public indexNFTInStore;
    uint256 public unicueCollectionNFTInStore;

    /* Струкутры
    * Для того чтобы не засорять магазин ненужными данными, можно создать структуру только с теми данными
    * которые будет нам нужны
    */ 

    struct structNFTsInStore {
        uint256 id;
        address owner;
        uint256 amount;
        uint256 price;
    }

    struct structCollectionInStore {
        uint256 id;
        address owner;
        uint256 price;
    }

    /*
    * Мапинги
    */ 

    mapping(uint256 => structNFTsInStore) public storeNFT; // index => struct
    mapping(uint256 => structCollectionInStore) public storeCollectionNFT;

    /*
    * Get функции с nft и коллекциями в магазине
    */ 

    // Геттер nft в магазине по индексу
    function getStoreNFT(uint256 _index) public view returns (structNFTsInStore memory) {
        return storeNFT[_index];
    }

    /*
    * Мульти функции совмещающие работу двух стандартов токенов
    */

    // Добавить nft в магазин по id
    function setNFTInStore(uint256 _id, uint256 _amount, uint256 _price) public {
        require(NFT[msg.sender][_id].amount >= _amount, "You don't have this NFT");
        require(_amount > 0, "Amount must be > 0");
        require( isApprovedForAll(msg.sender, address(this)), "Please approve the marketplace");

        
        bytes memory data = "";

        // Добавлем в мапинг. index => id => structNFTInStore
        storeNFT[indexNFTInStore] = structNFTsInStore(
            _id,
            msg.sender,
            _amount,
            _price
        );

        // Переводим наши нфт контракту. Что-то типа листинга
        safeTransferFrom(msg.sender, address(this), _id, _amount, data);
        // safeTransferFrom(from, to, id, value, data);

        // вычитаем все добавленные nft
        NFT[msg.sender][_id].amount -= _amount;

        // Если nft у юзера закончились, то мы удаляем их
        if (NFT[msg.sender][_id].amount == 0) {
            delete NFT[msg.sender][_id];
        }

        indexNFTInStore ++;

    }


    // Покупка nft по id.                                                   
    function buyNFT(uint256 _index, uint256 _amount) public payable {

        uint256 _id = storeNFT[_index].id;

        structNFT memory myNewNFT = allNFT[_id];
        uint256 priceNFT = storeNFT[_index].price * _amount;
        uint256 amountNFT = storeNFT[_index].amount;
        address ownerNFT = storeNFT[_index].owner;
        bytes memory data = "";

        require(storeNFT[_index].owner != msg.sender, "The owner of the nft cannot buy it from himself");
        require(balanceOf(msg.sender) >= priceNFT, "You dot't have ehougn Xcoin");
        require(amountNFT >= _amount, "Your chosen amount increases the number of tokens in the store.");
        require(amountNFT != 0, "This nft does not exist");

        // перевод токенов овнеру nft
        transfer(ownerNFT, priceNFT);

        // перевод самих nft
        _safeTransferFrom(address(this), msg.sender, _id, _amount, data);


        // вычитание _amount из amount
        storeNFT[_index].amount -= _amount;

        // Если такой nft уже есть у юзера, то мы добавляем просто цифорки к количеству его nft
        if (NFT[msg.sender][_id].amount > 0) {
            NFT[msg.sender][_id].amount += _amount;
        } else {
            NFT[msg.sender][_id] = myNewNFT;
            NFT[msg.sender][_id].amount = _amount;
        }

        // if amount in store == 0 -> del this nft 
        if (storeNFT[_index].amount == 0) {
            delete storeNFT[_index];
        }

    }

    function setCollectionInStore(uint256 _id, uint256 _price) public {

        require(collectionNFTs[msg.sender][_id].existence, "You don't have this collection");
        require(!collectionNFTs[msg.sender][_id].state, "Collection already in store");
        require(isApprovedForAll(msg.sender, address(this)), "Please approve the marketplace");

        // Создаём объект для удобной работы с ним
        structNFTsInCollection[] storage col = collectionNFTs[msg.sender][_id].NFTInCollection;
        require(col.length > 0, "Collection is empty");

        // Собираем массивы для batch transfer
        uint256[] memory ids = new uint256[](col.length);
        uint256[] memory amounts = new uint256[](col.length);

        for (uint256 i = 0; i < col.length; i++) {
            ids[i] = col[i].id;
            amounts[i] = col[i].amount;
        }

        // Передаём всю коллекцию контракту
        safeBatchTransferFrom(msg.sender, address(this), ids, amounts, "");

        // Сохраняем коллекцию в магазин
        storeCollectionNFT[unicueCollectionNFTInStore] = structCollectionInStore(
            _id,
            msg.sender,
            _price
        );

        // Отмечаем что она в магазине
        collectionNFTs[msg.sender][_id].state = true;

        unicueCollectionNFTInStore++;
    }

    function buyCollection(uint256 _index) public payable {
        // Достаём данные из магазина
        structCollectionInStore memory colStore = storeCollectionNFT[_index];

        address ownerCol = colStore.owner;
        uint256 idCol = colStore.id;
        uint256 price = colStore.price;
        structCollectionNFT memory myNewCollection = allCollection[idCol];

        // Проверки
        require(ownerCol != address(0), "Collection does not exist");
        require(ownerCol != msg.sender, "Owner cannot buy own collection");
        require(balanceOf(msg.sender) >= price, "Not enough Xcoin");

        // Перевод денег владельцу
        transfer(ownerCol, price);

        // Достаём nft внутри коллекции
        structNFTsInCollection[] storage col = collectionNFTs[ownerCol][idCol].NFTInCollection;

        uint256[] memory ids = new uint256[](col.length);
        uint256[] memory amounts = new uint256[](col.length);

        for (uint256 i = 0; i < col.length; i++) {
            ids[i] = col[i].id;
            amounts[i] = col[i].amount;
        }

        // Перевод NFT с контракта покупателю
        safeBatchTransferFrom(address(this), msg.sender, ids, amounts, "");

        // Удаляем коллекцию из старого владельца
        delete collectionNFTs[ownerCol][idCol];

        // Передаём коллекцию покупателю
        collectionNFTs[msg.sender][idCol] = myNewCollection;

        // Удаляем коллекцию из магазина
        delete storeCollectionNFT[_index];
    }

    // Эта штука как то решает проблему с тем, что этот контракт не может принимать nft
    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override(ERC1155, ERC1155Holder)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }


    // Тут мы вручную вносим адрес, чтомы при деплое родительских контрактов, их овнером был не сам контракт,
    // а адрес того кто деплоит
    constructor(address initialOwner) Xcoin(initialOwner) XcoinNFT(initialOwner) {

    }
} 
