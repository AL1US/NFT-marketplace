// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

interface INFT {

    /*
    * Более подробные комментарии можно найти contractNFT.sol
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
        uint256 price; 
        uint256 amount;
        uint256 creationDate;
    }

    // Коллекции nft
    struct structCollectionNFT {
        uint256 id;
        string name;
        string description;
        uint256 price; 
        structNFTsInCollection[] NFTInCollection;
        bool state;
        bool existence;
        uint256 creationDate;
    }

    /*
    * structSTORE
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
    * GET
    */ 

    // обычный balanceOf
    function balanceOf(address _account, uint256 _nft) external view returns(uint256);

    // Геттер nft по id 
    function getNFT(address _sender, uint256 _id) external view returns(structNFT memory);

    // Геттер коллекции по id
    function getCollection(address _sender, uint256 _id) external view returns(structCollectionNFT memory);

    /*
    * GET STORE
    */ 

    function getStoreNFT(uint256 _index) external view returns (structNFTsInStore memory);

    /*
    * Set функции с nft и коллекциями
    */

    // Создать nft
    function setNFT(
        address _sender, 
        string memory _name,
        string memory _description,
        string memory _imgPath,
        uint256 _amount
    ) external;

    // Создать коллекцию
    function setCollection(
        address _sender, 
        string memory _name,
        string memory _description
    ) external;

    // Добавить nft в коллекцию
    function setNFTInCollection(
        address _sender, 
        uint256 _idCollection,
        uint256 _idNFT,
        uint256 _amount
    ) external;

    /*
    * SET STORE
    */ 

    function setApprovalForAll(address _account, bool _operator) external;

    function setNFTInStore(address _sender, uint256 _id, uint256 _amount, uint256 _price) external;

}
