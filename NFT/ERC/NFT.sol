// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";

contract XcoinNFT is ERC1155 {

    // Обычные переменные
    address public ownerERC1155;

    // Своего рода id для nft и коллекций
    uint public unicueNFT; 
    uint public unicueCollectionNFT;

    /*
    * Все структуры
    */ 

    // Для того чтобы можно было помещать nft в коллекцию
    struct structNFTsInCollection {
        uint256 id;
        uint256 amount; 
    }

    // Обычные nft
    struct structNFT {
        uint256 id;
        string name;
        string description;
        string imgPath;
        uint256 price; // Заполняется только после помещения в магазин
        uint256 amount; // Также выступает в роли проверки существования nft
        uint256 creationDate;
    }

    // Коллекции. По сути это просто метаданные, которые ни как не влияют на обычные nft, но благодоря коллекциями
    // nft можно объединять, опять же только по метаданным, на сами nft по токену это не как не влияет
    struct structCollectionNFT {
        uint256 id;
        string name;
        string description;
        uint256 price; // Заполняется только после помещения в магазин
        structNFTsInCollection[] NFTInCollection;
        bool state; // Нужно для того чтобы понять в магазине или нет
        bool existence; // Нужно для проверки того, есть ли такая коллекция у юзера
        uint256 creationDate;
    }



    /*
    * Мапинги
    */ 

    // Используются именно мапинги, а не массивы, для того чтобы не нагружать контракт циклами,
    // для оптимизации использования газа, и легкости контрактка (кода соответсвтенно становится меньше)

    mapping(address => mapping(uint256 => structNFT)) public NFT;
    mapping(address => mapping(uint256 => structCollectionNFT)) public collectionNFTs;

    // Используется для того, чтобы понять какие вобще nft существют. Особенно помогает когда юзер
    // Покупает nft после чего, к нему в мапинг его nft можно просто и удобно добавить по id его куплленный. 
    mapping(uint256 => structNFT) public allNFT;
    mapping(uint256 => structCollectionNFT) public allCollection;

    /*
    * Get функции с nft и коллекциями
    */ 

    // Геттер nft по id 
    function getNFT(uint256 _id) public view returns(structNFT memory) {
        return NFT[msg.sender][_id];
    }

    // Геттер коллекции по id
    function getCollection(uint256 _id) public view returns(structCollectionNFT memory) {
        return collectionNFTs[msg.sender][_id];
    }



    /*
    * Set функции с nft и коллекциями
    */

    // Создать nft
    function setNFT(
        string memory _name,
        string memory _description,
        string memory _imgPath,
        uint256 _amount
    ) public {

        _mint(msg.sender, unicueNFT, _amount, ""); // Создание nft в системе. Последний параметр принимает комментарий

        // Добавление в мапинг юзера
        NFT[msg.sender][unicueNFT] = structNFT(
            unicueNFT,
            _name,
            _description,
            _imgPath,
            0,
            _amount,
            block.timestamp
        );

        // Добавление в мапинг всех NFT
        allNFT[unicueNFT] = structNFT(
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
            new structNFTsInCollection[](0), // нужно для id и количства
            false, // в магазине -> true / не в магазине -> false
            true, // Означет, что коллекция существует
            block.timestamp
        );

        // Добавление в мапинг всех коллекций
        allCollection[unicueCollectionNFT] = structCollectionNFT(
            unicueCollectionNFT,
            _name,
            _description,
            0,
            new structNFTsInCollection[](0),
            false, 
            true, 
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
        require(!collectionNFTs[msg.sender][_idCollection].state, "Collection already in store");

        require(_amount > 0, "Amount must be > 0");

        // Добавление выбраннх nft в коллекцию
        collectionNFTs[msg.sender][_idCollection].NFTInCollection.push(
            structNFTsInCollection(_idNFT, _amount)
        );

        // вычитаем все добавленные nft
        NFT[msg.sender][_idNFT].amount -= _amount;

        // Если nft у юзера закончились, то мы удаляем их
        if (NFT[msg.sender][_idNFT].amount == 0) {
            delete NFT[msg.sender][_idNFT];
        }

    }

    constructor(address _owner) ERC1155("./images/") {
        ownerERC1155 = _owner;
    }

}
