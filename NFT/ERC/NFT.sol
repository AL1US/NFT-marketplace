// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";

contract XcoinNFT is ERC1155 {

    // Обычные переменные
    address public ownerERC1155;

    // Своего рода id для nft и коллекций
    uint public unicueNFT; 
    uint public unicueCollectionNFT;

    // Структуры
    // Структура, для того чтобы можно было только по id и количеству помещать NFT в магазин, коллекцию или аукцион
    struct structNFTsInSomething {
        uint256 id;
        address owner;
        uint256 amount; // Работает только у NFT, у коллекций по умолчанию будет 1
    }

    struct structNFT {
        uint256 id;
        string name;
        string description;
        string imgPath;
        uint256 price; // Заполняется только после помещения в магазин
        uint256 amount;
        uint256 creationDate;
    }

    struct structCollectionNFT {
        uint256 id;
        string name;
        string description;
        uint256 price; // Заполняется только после помещения в магазин
        structNFTsInSomething[] NFTInCollection;
        bool state;
        bool existence;
        uint256 creationDate;
    }

    // Мапинги
    mapping(address => mapping(uint256 => structNFT)) public NFT;
    mapping(address => mapping(uint256 => structCollectionNFT)) public collectionNFTs;

    // Геттер nft по id 
    function getNFT(uint256 _id) public view returns(structNFT memory) {
        return NFT[msg.sender][_id];
    }

    // Геттер коллекции по id
    function getCollection(uint256 _id) public view returns(structCollectionNFT memory) {
        return collectionNFTs[msg.sender][_id];
    }
    
    // Создать nft
    function setNFT(
        string memory _name,
        string memory _description,
        string memory _imgPath,
        uint256 _amount
    ) public {

        _mint(msg.sender, unicueNFT, _amount, ""); // Создание nft в системе. Последний параметр принимает комментарий

        // Добавление в мапинг всех нфт, просто чтобы можно было легко понять сколько их и тп
        NFT[msg.sender][unicueNFT] = structNFT(
            unicueNFT,
            _name,
            _description,
            _imgPath,
            0,
            _amount,
            block.timestamp
        );

        unicueNFT++;
    }

    // Создать коллекцию
    function setCollection(
        string memory _name,
        string memory _description
    ) public {
        collectionNFTs[msg.sender][unicueCollectionNFT] = structCollectionNFT(
            unicueCollectionNFT,
            _name,
            _description,
            0, // цена указывается после выставления её на продажу
            new structNFTsInSomething[](0), // нужно для id и количства
            false, // в магазине -> true / не в магазине -> false
            true, // Означет, что коллекция существует
            block.timestamp
        );

        unicueCollectionNFT++;
    }

    // Добавить nft в коллекцию
    function setNFTInCollection(
        uint256 _idCollection,
        uint256 _idNFT,
        uint256 _amount
    ) public {
        // Проверка на то есть ли NFT у юзера
        require(NFT[msg.sender][_idNFT].amount >= _amount, "You don't have this NFT");
        require(collectionNFTs[msg.sender][_idCollection].existence, "You don't have this collection");
        require(_amount > 0, "Amount must be > 0");

        // Добавление выбраннх nft в коллекцию
        collectionNFTs[msg.sender][_idCollection].NFTInCollection.push(
            structNFTsInSomething(_idNFT, msg.sender, _amount)
        );

        // вычитаем все добавленные nft
        NFT[msg.sender][_idNFT].amount -= _amount;

        // Если nft у юзера закончились, то мы удаляем их
        if (NFT[msg.sender][_idNFT].amount == 0) {
            delete NFT[msg.sender][_idNFT];
        }

    }



    // XcoinNFT.sol
    constructor(address _owner) ERC1155("./images/") {
        ownerERC1155 = _owner;
    }

}