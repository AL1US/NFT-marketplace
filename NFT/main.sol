// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "./ERC/Xcoin.sol";
import "./ERC/NFT.sol";

// Эта штука как то решает проблему с тем, что этот контракт не может принимать nft
import "@openzeppelin/contracts/token/ERC1155/utils/ERC1155Holder.sol";


contract Main is Xcoin, XcoinNFT, ERC1155Holder {

    // Для того чтобы не засорять магазин ненужными данными, можно создать структуру только с теми данными
    // которые будет нам нужны
    struct structNFTsInStore {
        uint256 id;
        address owner;
        uint256 amount;
        uint256 price;
    }

    mapping(uint256 => structNFTsInStore) public storeNFT; // айди => наш продукт в магазине
    mapping(uint256 => structNFTsInStore) public storeCollectionNFT;

    /*
    * Get функции с nft и коллекциями в магазине
    */ 

    // Геттер nft в магазине по id
    function getStoreNFT(uint256 _id) public view returns (structNFTsInStore memory) {
        return storeNFT[_id];
    }

    /*
    * Мульти функции совмещающие работу двух стандартов токенов
    */

    // Добавить nft в магазин по id
    function setNFTInStore(uint256 _id, uint256 _amount, uint256 _price) public {
        require(NFT[msg.sender][_id].amount >= _amount, "You don't have this NFT");
        require(_amount > 0, "Amount must be > 0");
        
        bytes memory data = "";

        // Добавлем в мапинг. id => structNFTInStore
        storeNFT[_id] = structNFTsInStore(
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

    }

    function buyNFT(uint256 _id, uint256 _amount) public payable {

        structNFT memory myNewNFT = allNFT[_id];
        uint256 priceNFT = storeNFT[_id].price * _amount;
        uint256 amountNFT = storeNFT[_id].amount;
        address ownerNFT = storeNFT[_id].owner;
        bytes memory data = "";

        require(storeNFT[_id].owner != msg.sender, "The owner of the nft cannot buy it from himself");
        require(balanceOf(msg.sender) >= priceNFT, "You dot't have ehougn Xcoin");
        require(amountNFT >= _amount, "Your chosen amount increases the number of tokens in the store.");
        require(amountNFT != 0, "This nft does not exist");

        // перевод токенов овнеру nft
        transfer(ownerNFT, priceNFT);

        // перевод самих nft
        _safeTransferFrom(address(this), msg.sender, _id, _amount, data);


        // вычитание _amount из amount
        storeNFT[_id].amount -= _amount;

        // Если такой nft уже есть у юзера, то мы добавляем просто цифорки к количеству его nft
        if (NFT[msg.sender][_id].amount > 0) {
            NFT[msg.sender][_id].amount += _amount;
        } else {
            NFT[msg.sender][_id] = myNewNFT;
        }

        // if amount in store == 0 -> del this nft 
        if (storeNFT[_id].amount == 0) {
            delete storeNFT[_id];
        }


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
