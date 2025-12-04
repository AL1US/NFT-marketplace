// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";

contract contractNFT is ERC1155 {

    /*
    * ПЕРЕМЕННЫЕ
    */ 
    
    address ownerNFT;

    // Своего рода id для nft и коллекций
    uint public unicueNFT; 
    uint public unicueCollectionNFT;

    uint256 public indexNFTInStore;
    uint256 public unicueCollectionNFTInStore;


    /*
    * ВСЕ СТРУКТУРЫ
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
    * structSTORE
    */


    // Для того чтобы не засорять магазин ненужными данными, можно создать структуру только с теми данными
    // которые будет нам нужны

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
    * ВСЕ МАПИНГИ
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
    * mapping STORE
    */ 

    mapping(uint256 => structNFTsInStore) public storeNFT; // index => struct
    mapping(uint256 => structCollectionInStore) public storeCollectionNFT;


    /*
    * GET FUNCTIONS
    */

    // Геттер nft по id 
    function getNFT(address _sender, uint256 _id) public view returns(structNFT memory) {
        return NFT[_sender][_id];
    }

    // Геттер коллекции по id
    function getCollection(address _sender, uint256 _id) public view returns(structCollectionNFT memory) {
        return collectionNFTs[_sender][_id];
    }

    /*
    * GET STORE
    */ 

    // Геттер nft в магазине по индексу
    function getStoreNFT(uint256 _index) public view returns (structNFTsInStore memory) {
        return storeNFT[_index];
    }

    /*
    * SET FUNCTIONS
    */

    // Создать nft
    function setNFT(
        address _sender,
        string memory _name,
        string memory _description,
        string memory _imgPath,
        uint256 _amount
    ) public {

        _mint(_sender, unicueNFT, _amount, ""); // Создание nft в системе. Последний параметр принимает комментарий

        // Добавление в мапинг юзера
        NFT[_sender][unicueNFT] = structNFT(
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
        address _sender,
        string memory _name,
        string memory _description
    ) public {
        collectionNFTs[_sender][unicueCollectionNFT] = structCollectionNFT(
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
        address _sender,
        uint256 _idCollection,
        uint256 _idNFT,
        uint256 _amount
    ) public {
        // Проверка на то есть ли NFT у юзера
        require(NFT[_sender][_idNFT].amount >= _amount, "You don't have this NFT");
        require(collectionNFTs[_sender][_idCollection].existence, "You don't have this collection");
        require(!collectionNFTs[_sender][_idCollection].state, "Collection already in store");

        require(_amount > 0, "Amount must be > 0");

        // Добавление выбраннх nft в коллекцию
        collectionNFTs[_sender][_idCollection].NFTInCollection.push(
            structNFTsInCollection(_idNFT, _amount)
        );

        // вычитаем все добавленные nft
        NFT[_sender][_idNFT].amount -= _amount;

        // Если nft у юзера закончились, то мы удаляем их
        if (NFT[_sender][_idNFT].amount == 0) {
            delete NFT[_sender][_idNFT];
        }

    }


    /*
    * SET FUNCTIONS FOR STORE
    */

    // Добавить nft в магазин по id
    function setNFTInStore(address _sender, uint256 _id, uint256 _amount, uint256 _price) public {

        require(NFT[_sender][_id].amount >= _amount, "You don't have this NFT");
        require(_amount > 0, "Amount must be > 0");
        require(isApprovedForAll(_sender, address(this)), "Please approve the marketplace");

        // Добавлем в мапинг. index => id => structNFTInStore
        storeNFT[indexNFTInStore] = structNFTsInStore(
            _id,
            _sender,
            _amount,
            _price
        );

        // Переводим наши нфт контракту. Что-то типа листинга. Реализуется в main
        // safeTransferFrom(from, to, id, value, data);

        // вычитаем все добавленные nft
        NFT[_sender][_id].amount -= _amount;

        // Если nft у юзера закончились, то мы удаляем их
        if (NFT[_sender][_id].amount == 0) {
            delete NFT[_sender][_id];
        }

        indexNFTInStore ++;

    }

    
    constructor() ERC1155("./images/") {
        ownerNFT = 0x5B38Da6a701c568545dCfcB03FcB875f56beddC4;
    }


}