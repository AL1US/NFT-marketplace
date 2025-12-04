// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "./ERC/contractXcoin.sol";
import "./ERC/contractNFT.sol";

import "./Interface/INFT.sol";
import "./Interface/IXcoin.sol";

contract Main {

    IXcoin public token;
    INFT public nft;

    address ownerMain;

    constructor() {

        ownerMain = 0x5B38Da6a701c568545dCfcB03FcB875f56beddC4;

        token = IXcoin(address(new contractXcoin()));
        nft = INFT(address(new contractNFT()));

        setNFT("myNFT0", "desc", "imgPath", 10);
        setNFT("myNFT1", "desc", "imgPath", 10);
        setNFT("myNFT2", "desc", "imgPath", 10);
        setNFT("myNFT3", "desc", "imgPath", 10);


        setCollection("myCol0", "description");
        setCollection("myCol1", "description");
        setNFTInCollection(0, 0, 5); // id col, id nft, amount
        setNFTInCollection(0, 1, 3);
    }

    /*
    * get функции 
    */

    function balanceOfXcoin(address _address) public view returns(uint256) {
        return token.balanceOf(_address);
    }

    function balanceOfNFT(address _account, uint256 _nft) public view returns(uint256) {
        return nft.balanceOf(_account, _nft);
    }

    function getNFT(uint256 _id) public view returns(INFT.structNFT memory) {
        return nft.getNFT(msg.sender, _id);
    }
    
    function getCollection(uint256 _id) public view returns(INFT.structCollectionNFT memory) {
        return nft.getCollection(msg.sender, _id);
    }    


    /*
    * get STORE
    */

    function getStoreNFT(uint256 _index) public view returns (INFT.structNFTsInStore memory) {
        return nft.getStoreNFT(_index);
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
        nft.setNFT(msg.sender, _name, _description, _imgPath, _amount);
    }

    function setCollection(string memory _name, string memory _description) public {
        nft.setCollection(msg.sender, _name, _description);
    }

    function setNFTInCollection(
        uint256 _idCollection,
        uint256 _idNFT,
        uint256 _amount
    ) public {
        nft.setNFTInCollection(msg.sender, _idCollection, _idNFT, _amount);
    }

    /*
    * Set функции с nft и коллекциями в магазине
    */

    function approveNFT() public {
        nft.setApprovalForAll(address(this), true);
    }
    function approveXcoin() public {
        token.approve(address(this), type(uint256).max);
    }    


    function setNFTInStore(uint256 _id, uint256 _amount, uint256 _price) public {
        bytes memory data = "";

        nft.setNFTInStore(msg.sender, _id, _amount, _price);
        token.safeTransferFrom(msg.sender, address(this), _id, _amount, data);
    }






}
